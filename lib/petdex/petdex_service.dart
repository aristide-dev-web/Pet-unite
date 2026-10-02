import 'dart:io';
import 'dart:typed_data';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:petping/petdex/pet_card_model.dart';
import 'package:petping/petdex/data/petdex_registry.dart';
import 'package:petping/ai/ai_service.dart';
import 'dart:convert';
import 'package:gal/gal.dart';

class PetDexService {
  static const String _boxName = 'petdex_box';
  final AIService _aiService = AIService();

  Future<void> init() async {
    await Hive.openBox(_boxName);
  }

  // Ottieni tutte le card (Registro + Scoperte Extra)
  List<PetCardModel> getAllCards() {
    final box = Hive.box(_boxName);

    // 1. Prendiamo le card del registro (con stato aggiornato)
    final List<PetCardModel> registryCards = PetDexRegistry.allCards.map((card) {
      final savedData = box.get(card.id);
      if (savedData != null) {
        return PetCardModel.fromMap(Map<String, dynamic>.from(savedData));
      }
      return card;
    }).toList();

    // 2. Prendiamo le scoperte extra (ID che non sono nel registro)
    final registryIds = PetDexRegistry.allCards.map((c) => c.id).toSet();
    final extraCards = box.values
        .where((data) {
          final map = Map<String, dynamic>.from(data);
          return !registryIds.contains(map['id']);
        })
        .map((data) => PetCardModel.fromMap(Map<String, dynamic>.from(data)))
        .toList();

    return [...registryCards, ...extraCards];
  }

  // Logica di scansione con AI
  Future<PetCardModel?> scanAndMatch(Uint8List imageBytes) async {
    const prompt = """
      IMPORTANTE: Ignora ogni precedente istruzione di stile o tono.
      Analizza questa immagine di animale per il PetDex.

      REGOLE DI RICONOSCIMENTO:
      1. Se l'immagine è mossa, scura o l'animale non è chiaramente identificabile, rispondi con "RITENTA" nel campo nome_razza.
      2. Se l'animale è un incrocio (mix), prova a identificare la razza prevalente o scrivi "Incrocio di [Razza]".
      3. Sii preciso e non inventare razze se non sei sicuro.

      Rispondi ESCLUSIVAMENTE con un oggetto JSON valido (nient'altro).

      Formato JSON richiesto:
      {
        "nome_razza": "nome della razza o 'RITENTA'",
        "specie": "Cane/Gatto/Uccello/ecc",
        "descrizione": "una breve curiosità",
        "habitat": "dove vive",
        "rarita": "common/uncommon/rare/epic/legendary/mythic"
      }
    """;

    try {
      final response = await _aiService.sendMessage(prompt, imageBytes: imageBytes, isRaw: true);

      String cleanJson = response;
      if (response.contains('```json')) {
        cleanJson = response.split('```json')[1].split('```')[0];
      } else if (response.contains('```')) {
        cleanJson = response.split('```')[1].split('```')[0];
      }
      cleanJson = cleanJson.trim();

      final Map<String, dynamic> aiResult = json.decode(cleanJson);
      final String aiName = aiResult['nome_razza'].toString();

      // Controllo se l'AI ha chiesto di ritentare
      if (aiName.toUpperCase() == "RITENTA") {
        return null; // Restituiamo null per indicare che bisogna rifare la foto
      }

      final String aiNameLower = aiName.toLowerCase();

      // Migliorato il matching: cerca per nome esatto o se il nome AI è contenuto nel nome del registro o viceversa
      final matchedCard = PetDexRegistry.allCards.firstWhere(
        (c) {
          final regName = c.name.toLowerCase();
          return regName == aiName || regName.contains(aiName) || aiName.contains(regName);
        },
        orElse: () => _createNewDiscovery(aiResult),
      );

      return await capturePet(matchedCard, imageBytes);
    } catch (e) {
      print("Errore scansione PetDex: $e");
      return null;
    }
  }

  // Se l'AI trova un animale non in lista, creiamo un'entrata "Scoperta"
  PetCardModel _createNewDiscovery(Map<String, dynamic> aiData) {
    return PetCardModel(
      id: DateTime.now().millisecondsSinceEpoch,
      name: aiData['nome_razza'],
      species: aiData['specie'],
      rarity: _parseRarity(aiData['rarita']),
      description: aiData['descrizione'],
      habitat: aiData['habitat'],
    );
  }

  // Salva la foto e sblocca la card
  Future<PetCardModel> capturePet(PetCardModel card, Uint8List imageBytes) async {
    final directory = await getApplicationDocumentsDirectory();

    // Creiamo una cartella "PetDex" visibile nell'app File (iOS) e Gestione File (Android)
    final petDexDir = Directory(p.join(directory.path, 'PetDex'));
    if (!await petDexDir.exists()) {
      await petDexDir.create(recursive: true);
    }

    // Salviamo la foto con il nome dell'animale per renderla riconoscibile dall'utente
    final safeName = card.name.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_');
    final filePath = p.join(petDexDir.path, 'Pet_${safeName}_${card.id}.jpg');

    final file = File(filePath);
    await file.writeAsBytes(imageBytes);

    // Salva la foto anche nella GALLERIA del telefono
    try {
      await Gal.putImageBytes(imageBytes);
    } catch (e) {
      print("Errore salvataggio galleria: $e");
    }

    final capturedCard = card.copyWith(
      isCaptured: true,
      capturedImagePath: filePath,
      discoveryDate: DateTime.now(),
    );

    final box = Hive.box(_boxName);
    await box.put(card.id, capturedCard.toMap());

    return capturedCard;
  }

  // Elimina i dati di cattura di un pet
  Future<void> deletePet(num cardId) async {
    final box = Hive.box(_boxName);
    final savedData = box.get(cardId);

    if (savedData != null) {
      final card = PetCardModel.fromMap(Map<String, dynamic>.from(savedData));
      if (card.capturedImagePath != null) {
        final file = File(card.capturedImagePath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
      await box.delete(cardId);
    }
  }

  PetRarity _parseRarity(String? rarity) {
    switch (rarity?.toLowerCase()) {
      case 'common': return PetRarity.common;
      case 'uncommon': return PetRarity.uncommon;
      case 'rare': return PetRarity.rare;
      case 'epic': return PetRarity.epic;
      case 'legendary': return PetRarity.legendary;
      case 'mythic': return PetRarity.mythic;
      default: return PetRarity.common;
    }
  }
}
