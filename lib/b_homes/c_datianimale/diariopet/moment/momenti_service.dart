import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'modello_memoria.dart';

class MomentiService {
  Future<Directory> _getCartellaCategoria(String categoria) async {
    final baseDir = await getApplicationDocumentsDirectory();
    final cartella = Directory('${baseDir.path}/momenti/$categoria');
    if (!await cartella.exists()) {
      await cartella.create(recursive: true);
    }
    return cartella;
  }

  Future<void> salvaMemoria(Memoria memoria, List<int> imageBytes) async {
    final cartella = await _getCartellaCategoria(memoria.categoria);
    final fileName = 'foto_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final file = File('${cartella.path}/$fileName');
    await file.writeAsBytes(imageBytes);

    final memoriaConPath = memoria.copyWith(pathImmagine: file.path);
    final jsonFile = File('${cartella.path}/memorie.json');

    List<Memoria> memorie = [];
    if (await jsonFile.exists()) {
      final contenuto = await jsonFile.readAsString();
      memorie = (json.decode(contenuto) as List)
          .map((e) => Memoria.fromJson(e))
          .toList();
    }

    memorie.add(memoriaConPath);
    await jsonFile.writeAsString(json.encode(memorie.map((e) => e.toJson()).toList()));
  }

  Future<List<Memoria>> caricaMemorie(String animaleId, String categoria) async {
    final cartella = await _getCartellaCategoria(categoria);
    final jsonFile = File('${cartella.path}/memorie.json');
    if (!await jsonFile.exists()) return [];

    final contenuto = await jsonFile.readAsString();
    final lista = json.decode(contenuto) as List;

    return lista
        .map((e) => Memoria.fromJson(e))
        .where((memoria) => memoria.animaleId == animaleId)
        .toList();
  }
}