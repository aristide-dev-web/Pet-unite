import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petping/token.dart';

class BanService {
  static final _firestore = FirebaseFirestore.instance;

  /// Controlla se l'utente corrente o il dispositivo sono bannati
  static Future<bool> isBanned() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      
      // 1. Controllo tramite UID (se loggato)
      if (user != null) {
        final userDoc = await _firestore.collection('utenti').doc(user.uid).get();
        if (userDoc.exists && (userDoc.data()?['banned'] == true)) {
          return true;
        }
      }

      // 2. Controllo tramite Token del dispositivo (sempre)
      final token = await DeviceTokenService().getLocalToken();
      if (token != null) {
        final banDoc = await _firestore.collection('blocked_tokens').doc(token).get();
        if (banDoc.exists) {
          return true;
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Metodo per l'admin per bannare un utente (sia account che dispositivo)
  static Future<void> banUser(String uid) async {
    try {
      // 1. Segna l'utente come bannato
      await _firestore.collection('utenti').doc(uid).update({'banned': true});

      // 2. Recupera il suo token e bloccalo
      final tokenDoc = await _firestore.collection('token').doc(uid).get();
      if (tokenDoc.exists) {
        final token = tokenDoc.data()?['fcmToken'];
        if (token != null) {
          await _firestore.collection('blocked_tokens').doc(token).set({
            'uid': uid,
            'blockedAt': FieldValue.serverTimestamp(),
            'reason': 'Violazione termini',
          });
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Metodo per l'admin per sbannare un utente
  static Future<void> unbanUser(String uid) async {
    try {
      // 1. Rimuovi il flag banned dall'utente
      await _firestore.collection('utenti').doc(uid).update({'banned': false});

      // 2. Recupera il suo token e rimuovilo dai token bloccati
      final tokenDoc = await _firestore.collection('token').doc(uid).get();
      if (tokenDoc.exists) {
        final token = tokenDoc.data()?['fcmToken'];
        if (token != null) {
          await _firestore.collection('blocked_tokens').doc(token).delete();
        }
      }
    } catch (e) {
      rethrow;
    }
  }
}
