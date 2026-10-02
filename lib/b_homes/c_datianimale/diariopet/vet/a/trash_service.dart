import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hive/hive.dart';
import 'esame_model.dart';

class TrashService {
  /// Elimina definitivamente un esame da Hive, Firestore e Firebase Storage
  static Future<void> eliminaEsameCompleto({
    required String animaleId,
    required String esameId,
  }) async {
    try {
      final boxName = "esami_$animaleId";
      final box = await Hive.openBox<Esame>(boxName);
      final esame = box.get(esameId);

      if (esame == null) return;

      // 1. ELIMINAZIONE FILE FISICI (Storage e Locale)
      if (esame.fileUrls.isNotEmpty) {
        for (String url in esame.fileUrls) {
          try {
            if (url.startsWith('http')) {
              // Elimina da Firebase Storage
              await FirebaseStorage.instance.refFromURL(url).delete();
            } else {
              // Elimina file locale dal telefono
              final file = File(url);
              if (await file.exists()) {
                await file.delete();
              }
            }
          } catch (e) {
            print("Errore durante l'eliminazione del file fisico: $e");
          }
        }
      }

      // 2. ELIMINAZIONE DA FIREBASE FIRESTORE
      try {
        await FirebaseFirestore.instance
            .collection('animali')
            .doc(animaleId)
            .collection('esami')
            .doc(esameId)
            .delete();
      } catch (e) {
        // Ignorato se l'esame non era ancora stato sincronizzato su Firebase
      }

      // 3. ELIMINAZIONE DA HIVE (MEMORIA LOCALE)
      await box.delete(esameId);

      print("✅ Esame $esameId eliminato correttamente da ogni sorgente.");
    } catch (e) {
      print("🚨 Errore durante l'eliminazione completa: $e");
      rethrow;
    }
  }
}
