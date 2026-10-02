import 'dart:typed_data';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';
import 'package:easy_localization/easy_localization.dart';

class AIService {
  final GenerativeModel _model;
  ChatSession? _chat;
  String? _petContext;
  String? _cachedLocation;

  AIService() : _model = FirebaseVertexAI.instance.generativeModel(
    model: 'gemini-2.5-flash',
    generationConfig: GenerationConfig(
      temperature: 0.7,
      topK: 40,
      topP: 0.95,
      maxOutputTokens: 1024,
    ),
    systemInstruction: Content.system('''
      Sei PetPing AI, l'assistente d'eccellenza multilingua per il mondo animale. 
      Segui rigorosamente queste regole di comunicazione:

      1. FORMATTAZIONE E STILE:
         - NON usare mai gli asterischi (*) per grassetti, elenchi o enfasi.
         - Usa esclusivamente le EMOJI per dare struttura e tono.
         - Procedi sempre per STEP chiari, sequenziali e numerati (es. Step 1, Step 2...).
         - Mantieni un tono professionale, elegante, ma allo stesso tempo empatico.

      2. SET DI EMOJI CONSENTITO:
         - Professionale/Elegante: 💼 🖋️ 📘 📚 📊 📈 📉 🗒️ 📝 🏛️ 🧾 🪶
         - Collaborativo/Rispettoso: 🤝 🙏 🤲 🫱🏻‍🫲🏽 🫶 💬 🗣️ 🫡 🧑‍💼 👥
         - Intelligente/Didattico: 💡 🔍 🧪 🧠 🧱 🧰 🛠️ 📐 📏 Compass 🧭 🧑‍🏫
         - Motivante/Positivo: 🚀 🌟 ✨ 💫 🔥 🌈 🏆 🎯 💪 🌱 🌞
         - Calmo/Rassicurante: 🧘 🌿 🍃 🌙 🕊️ 🪷 🫧 ☕ 🕯️ 🎐 🌤️
         - Tecnico/Guida: 🧱 🧩 🗂️ 🗃️ ⚙️ 🖥️ 📡 🛰️ 🧭 🏛️ 🛡️ 🏅 🧑‍💼 📣
         - Empatico/Umano: ❤️ 💛 💙 🤍 🫶 🤗 🌸 🌷 🫂
         - Narrativo/Creativo: 🧵 📜 🪶 ✒️ 📖 🎨 🧵 🪡 🎭 🌌

      3. CONTENUTO E LIMITAZIONI MEDICHE:
         - Rispondi sempre nella lingua dell'utente.
         - Se l'utente fornisce il permesso, puoi consultare le cartelle cliniche caricate per fornire spiegazioni scientifiche generali.
         - Il tuo ruolo è esclusivamente informativo e didattico, come un manuale scientifico.
         - Puoi spiegare il significato dei termini (es. cosa sono le proteine o i valori di riferimento) e indicare i parametri normali.
         - NON sostituire mai il parere di un veterinario.
         - NON fornire diagnosi, non prescrivere cure e non dare interpretazioni cliniche definitive.
         - Se un valore è fuori norma (es. fegato alto, proteine elevate), spiega cosa significa scientificamente ma concludi SEMPRE consigliando di consultare un veterinario.
         - Esempio: "Le proteine trasportano sostanze nel sangue; un valore eccessivo può indicare un sovraccarico. Consulta il tuo veterinario per approfondire."
         - Se hai bisogno della posizione per consigli locali, chiedila cortesemente.
         - Fornisci informazioni precise e strutturate in modo che siano immediatamente comprensibili.
    '''),
  );

  void startHistoryChat(List<Content> history) {
    _chat = _model.startChat(history: history);
  }

  void setPetContext(String context) {
    _petContext = context;
  }

  Future<void> _updateLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
        List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          _cachedLocation = "ai_location_label".tr(args: [placemarks[0].locality ?? '', placemarks[0].country ?? '']);
        }
      } else {
        _cachedLocation = "";
      }
    } catch (e) {
      debugPrint("GPS Error: $e");
      _cachedLocation = "";
    }
  }

  Future<String> sendMessage(String message, {Uint8List? imageBytes, bool isRaw = false}) async {
    try {
      _chat ??= _model.startChat();
      
      String finalPrompt;
      if (isRaw) {
        finalPrompt = message;
      } else {
        if (_cachedLocation == null || _cachedLocation!.isEmpty) {
          await _updateLocation();
        }

        final String safeLocation = _cachedLocation ?? "";
        final String safePetContext = _petContext ?? "";
        final String userPrefix = "ai_user_question_prefix".tr(args: [message]);
        finalPrompt = "$safeLocation$safePetContext\n$userPrefix";
      }
      
      debugPrint("🚀 PROMPT INVIATO: $finalPrompt");

      final List<Part> parts = [TextPart(finalPrompt)];
      if (imageBytes != null) {
        parts.add(InlineDataPart('image/jpeg', imageBytes));
      }

      final response = await _chat!.sendMessage(Content.multi(parts));

      if (response.text == null || response.text!.isEmpty) {
        return "ai_error_no_response".tr();
      }
      
      return response.text!;
    } catch (e, stack) {
      debugPrint("🔥 ERRORE REALE AI: $e");
      debugPrint("📌 STACK: $stack");
      
      return "ai_error_communication".tr(args: [e.toString()]);
    }
  }

  void resetChat() {
    _chat = null;
    _petContext = null;
    _cachedLocation = null;
  }
}
