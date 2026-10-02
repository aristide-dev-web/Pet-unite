import 'dart:io';
import 'package:hive/hive.dart';
import 'esame_model.dart';

class EsamiLocalService {
  static const String esamiBoxPrefix = "esami_";
  static const String commentiBoxPrefix = "commenti_";

  Future<Box<Esame>> _openEsamiBox(String animaleId) async {
    final boxName = "$esamiBoxPrefix$animaleId";
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<Esame>(boxName);
    }
    return await Hive.openBox<Esame>(boxName);
  }

  Future<Box<List>> _openCommentiBox(String esameId) async {
    final boxName = "$commentiBoxPrefix$esameId";
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<List>(boxName);
    }
    return await Hive.openBox<List>(boxName);
  }

  Future<void> salvaEsame(String animaleId, Esame esame) async {
    final box = await _openEsamiBox(animaleId);
    await box.put(esame.id, esame);
  }

  Future<List<Esame>> leggiEsami(String animaleId) async {
    final box = await _openEsamiBox(animaleId);
    return box.values.toList();
  }

  Future<void> eliminaEsame(String animaleId, String esameId) async {
    final box = await _openEsamiBox(animaleId);
    final esame = box.get(esameId);

    // ✅ ELIMINA TUTTI I FILE FISICI NELLA LISTA
    if (esame != null && esame.fileUrls.isNotEmpty) {
      for (var path in esame.fileUrls) {
        try {
          final file = File(path);
          if (await file.exists()) {
            await file.delete();
            print("File eliminato: $path");
          }
        } catch (e) {
          print("Errore eliminazione file $path: $e");
        }
      }
    }

    await box.delete(esameId);

    final commentiBox = await _openCommentiBox(esameId);
    await commentiBox.deleteFromDisk();
  }

  // -----------------------------
  // COMMENTI
  // -----------------------------

  Future<void> salvaCommento(String esameId, String commento) async {
    final box = await _openCommentiBox(esameId);
    final List<dynamic> listaDinamica = box.get("lista", defaultValue: <String>[])!;
    final List<String> lista = List<String>.from(listaDinamica);
    lista.add(commento);
    await box.put("lista", lista);
  }

  Future<List<String>> leggiCommenti(String esameId) async {
    final box = await _openCommentiBox(esameId);
    final List<dynamic> listaDinamica = box.get("lista", defaultValue: <String>[])!;
    return List<String>.from(listaDinamica);
  }

  Future<int> contaCommenti(String esameId) async {
    final box = await _openCommentiBox(esameId);
    final List<dynamic> listaDinamica = box.get("lista", defaultValue: <String>[])!;
    return listaDinamica.length;
  }
}
