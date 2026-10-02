import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:petping/petsitting/models/sitter_model.dart';

class SitterService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _sitterBoxName = 'sitters_box';
  static const String _settingsBoxName = 'settings_box';

  /// Verifica se un campo deve essere bloccato nella Bios generale
  static bool isFieldLocked(String fieldName, bool isPetSitterActive) {
    if (!isPetSitterActive) return false;
    const lockedFields = ['bio', 'citta', 'nome', 'cognome', 'username'];
    return lockedFields.contains(fieldName);
  }

  static String getLockedReason() {
    return "Questo campo è gestito dal tuo profilo Pet Sitter e deve rimanere pubblico.";
  }

  /// Recupera il profilo sitter, usando Hive come cache
  Future<SitterProfile?> getSitterProfile(String uid) async {
    final box = Hive.box<SitterProfile>(_sitterBoxName);
    if (box.containsKey(uid)) return box.get(uid);

    try {
      final doc = await _firestore.collection('sitters').doc(uid).get();
      if (doc.exists) {
        final profile = SitterProfile.fromFirestore(doc);
        await box.put(uid, profile);
        return profile;
      }
    } catch (e) {
      print("Errore nel recupero profilo sitter: $e");
    }
    return null;
  }

  /// Forza l'aggiornamento della cache Hive da Firebase
  Future<void> syncProfile(String uid) async {
    try {
      final doc = await _firestore.collection('sitters').doc(uid).get();
      if (doc.exists) {
        final profile = SitterProfile.fromFirestore(doc);
        final box = Hive.box<SitterProfile>(_sitterBoxName);
        await box.put(uid, profile);
        
        // Sincronizza anche il flag isPetSitter nella cache settings
        final settingsBox = await Hive.openBox(_settingsBoxName);
        await settingsBox.put('isPetSitter_$uid', true);
      }
    } catch (e) {
      print("Errore sincronizzazione profilo: $e");
    }
  }

  Future<void> deleteSitterProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('utenti').doc(user.uid).update({'isPetSitter': false});
    await _firestore.collection('sitters').doc(user.uid).delete();

    final box = Hive.box<SitterProfile>(_sitterBoxName);
    await box.delete(user.uid);
    
    final settingsBox = await Hive.openBox(_settingsBoxName);
    await settingsBox.put('isPetSitter_${user.uid}', false);
  }

  /// ✅ NUOVO: Verifica lo stato usando Hive come cache per velocità istantanea
  Future<bool> checkSitterStatus() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    
    final settingsBox = await Hive.openBox(_settingsBoxName);
    final cacheKey = 'isPetSitter_${user.uid}';

    // Se abbiamo il valore in cache, lo restituiamo subito
    if (settingsBox.containsKey(cacheKey)) {
      return settingsBox.get(cacheKey);
    }

    // Altrimenti leggiamo da Firestore e aggiorniamo la cache
    final doc = await _firestore.collection('utenti').doc(user.uid).get();
    final bool isSitter = doc.data()?['isPetSitter'] ?? false;
    
    await settingsBox.put(cacheKey, isSitter);
    return isSitter;
  }
}
