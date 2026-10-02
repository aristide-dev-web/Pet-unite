import 'package:cloud_firestore/cloud_firestore.dart';

class UserFollowService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // currentUserId: chi preme il tasto
  // targetUserId: chi viene seguito
  Future<void> segui(String currentUserId, String targetUserId) async {
    final batch = _db.batch();

    // 1. Aggiungi il target ai "seguiti" dell'utente corrente
    final currentUserRef = _db.collection('utenti').doc(currentUserId);
    batch.update(currentUserRef, {
      'following': FieldValue.arrayUnion([targetUserId])
    });

    // 2. Aggiungi l'utente corrente ai "follower" del target
    final targetUserRef = _db.collection('utenti').doc(targetUserId);
    batch.update(targetUserRef, {
      'followers': FieldValue.arrayUnion([currentUserId])
    });

    await batch.commit();
  }

  Future<void> smettiDiSeguire(String currentUserId, String targetUserId) async {
    final batch = _db.batch();

    // 1. Rimuovi il target dai "seguiti"
    final currentUserRef = _db.collection('utenti').doc(currentUserId);
    batch.update(currentUserRef, {
      'following': FieldValue.arrayRemove([targetUserId])
    });

    // 2. Rimuovi l'utente corrente dai "follower"
    final targetUserRef = _db.collection('utenti').doc(targetUserId);
    batch.update(targetUserRef, {
      'followers': FieldValue.arrayRemove([currentUserId])
    });

    await batch.commit();
  }
}
