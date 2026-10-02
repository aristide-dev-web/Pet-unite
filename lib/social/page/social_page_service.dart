import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:petping/social/page/social_page_model.dart';

class SocialPageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> createPage({
    required String nome,
    required String categoria,
    String? bio,
    File? fotoProfilo,
    File? fotoCopertina,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("Utente non loggato");

    String? fotoProfiloUrl;
    String? fotoCopertinaUrl;

    if (fotoProfilo != null) {
      final ref = _storage.ref().child('pagine/profilo/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(fotoProfilo);
      fotoProfiloUrl = await ref.getDownloadURL();
    }

    if (fotoCopertina != null) {
      final ref = _storage.ref().child('pagine/copertina/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(fotoCopertina);
      fotoCopertinaUrl = await ref.getDownloadURL();
    }

    final docRef = await _firestore.collection('pagine').add({
      'creatorId': user.uid,
      'nome': nome,
      'categoria': categoria,
      'bio': bio,
      'fotoProfilo': fotoProfiloUrl,
      'fotoCopertina': fotoCopertinaUrl,
      'adminIds': [user.uid],
      'followerIds': [],
      'createdAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  Stream<List<SocialPage>> getMyPages() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('pagine')
        .where('adminIds', arrayContains: user.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => SocialPage.fromFirestore(doc)).toList());
  }

  Future<void> followPage(String pageId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _firestore.collection('pagine').doc(pageId).update({
      'followerIds': FieldValue.arrayUnion([user.uid])
    });
  }
}
