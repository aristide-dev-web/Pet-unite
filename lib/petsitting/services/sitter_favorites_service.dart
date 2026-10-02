import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:petping/petsitting/models/sitter_model.dart';

class SitterFavoritesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  // Stream dei preferiti per l'utente corrente
  Stream<List<String>> getFavoritesStream() {
    if (_uid == null) return Stream.value([]);
    
    return _firestore
        .collection('utenti')
        .doc(_uid)
        .collection('sitter_preferiti')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  // Aggiungi o rimuovi dai preferiti
  Future<void> toggleFavorite(SitterProfile sitter) async {
    if (_uid == null) return;

    final docRef = _firestore
        .collection('utenti')
        .doc(_uid)
        .collection('sitter_preferiti')
        .doc(sitter.uid);

    final doc = await docRef.get();

    if (doc.exists) {
      await docRef.delete();
    } else {
      // 1. Salva su Firestore
      await docRef.set({
        'timestamp': FieldValue.serverTimestamp(),
      });
      // 2. Assicura la presenza in Hive locale per la sezione "I MIEI PET SITTER"
      final box = Hive.box<SitterProfile>('sitters_box');
      if (!box.containsKey(sitter.uid)) {
        await box.put(sitter.uid, sitter);
      }
    }
  }

  // Verifica se un sitter è preferito
  Future<bool> isFavorite(String sitterId) async {
    if (_uid == null) return false;
    
    final doc = await _firestore
        .collection('utenti')
        .doc(_uid)
        .collection('sitter_preferiti')
        .doc(sitterId)
        .get();
        
    return doc.exists;
  }
}
