import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:petping/petsitting/models/sitter_model.dart';

class SitterCacheService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String sitterBoxName = 'sitters_box';

  /// Inizia la sincronizzazione dei dati del Sitter corrente (se l'utente è un sitter)
  /// e dei sitter preferiti. Non sincronizziamo l'intera collezione per risparmiare risorse.
  static void sincronizzaSitters() {
    final String? currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) return;

    // 1. Sincronizza il proprio profilo Sitter (se esiste)
    _db.collection('sitters').doc(currentUid).snapshots().listen((doc) async {
      if (doc.exists) {
        final box = Hive.box<SitterProfile>(sitterBoxName);
        await box.put(currentUid, SitterProfile.fromFirestore(doc));
      }
    });

    // 2. Sincronizza i Sitter preferiti
    _db.collection('utenti')
        .doc(currentUid)
        .collection('sitter_preferiti')
        .snapshots()
        .listen((favSnapshot) async {
      
      final box = Hive.box<SitterProfile>(sitterBoxName);
      
      for (var change in favSnapshot.docChanges) {
        final sitterId = change.doc.id;
        
        if (change.type == DocumentChangeType.removed) {
          // Se rimosso dai preferiti, lo teniamo in cache per ora o lo rimuoviamo se vogliamo pulizia totale
          // await box.delete(sitterId); 
        } else {
          // Quando un sitter viene aggiunto ai preferiti o aggiornato, scarichiamo il suo profilo completo
          final sitterDoc = await _db.collection('sitters').doc(sitterId).get();
          if (sitterDoc.exists) {
            await box.put(sitterId, SitterProfile.fromFirestore(sitterDoc));
          }
        }
      }
    });
  }

  /// Recupera un sitter dalla cache o da Firebase (Cache-First)
  static Future<SitterProfile?> getSitter(String uid) async {
    final box = Hive.box<SitterProfile>(sitterBoxName);
    
    // Controlla Hive
    if (box.containsKey(uid)) {
      return box.get(uid);
    }

    // Se non in Hive, scarica da Firebase e salva in cache
    try {
      final doc = await _db.collection('sitters').doc(uid).get();
      if (doc.exists) {
        final sitter = SitterProfile.fromFirestore(doc);
        await box.put(uid, sitter);
        return sitter;
      }
    } catch (e) {
      print("Errore recupero sitter $uid: $e");
    }
    return null;
  }
}
