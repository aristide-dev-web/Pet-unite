import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SosPaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  /// Verifica se l'utente può postare gratuitamente o se ha l'abbonamento attivo
  Future<bool> canPostFree() async {
    if (_uid == null) return false;

    try {
      // 1. Controlla se l'utente è Premium SOS (Abbonato)
      final userDoc = await _firestore.collection('utenti').doc(_uid).get();
      if (userDoc.exists && (userDoc.data()?['isPremiumSOS'] == true)) {
        return true; 
      }

      // 2. Se non è abbonato, controlla se è il primo post
      final snapshot = await _firestore
          .collection('animali_smarriti')
          .where('uid_utente', isEqualTo: _uid)
          .get();

      // Se non ci sono documenti, il prossimo è il primo (gratuito)
      return snapshot.docs.isEmpty;
    } catch (e) {
      print("Errore controllo post SOS: $e");
      return false;
    }
  }
}
