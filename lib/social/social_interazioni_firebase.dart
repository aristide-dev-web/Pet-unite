import 'package:cloud_firestore/cloud_firestore.dart';

class SocialInterazioniFirebase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> aggiungiLike(String postId, String userId) async {
    final postRef = _firestore.collection('post').doc(postId);
    final likeRef = postRef.collection('likes').doc(userId);

    final likeSnapshot = await likeRef.get();

    if (likeSnapshot.exists) {
      await likeRef.delete(); // Rimuovi like se già esiste (toggle)
    } else {
      await likeRef.set({'timestamp': FieldValue.serverTimestamp()});
    }
  }

  Stream<int> contaLike(String postId) {
    return _firestore
        .collection('post')
        .doc(postId)
        .collection('likes')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<void> aggiungiCommento(String postId, String userId, String autore, String testo) async {
    final commentiRef = _firestore.collection('post').doc(postId).collection('commenti');

    await commentiRef.add({
      'uid': userId,
      'autore': autore,
      'testo': testo,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> leggiCommenti(String postId) {
    return _firestore
        .collection('post')
        .doc(postId)
        .collection('commenti')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}