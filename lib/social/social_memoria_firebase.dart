import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hive/hive.dart';
import 'post/social_post_model.dart';
import 'story/social_story_model.dart';

class SocialMemoriaFirebase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  static const String _postsBoxName = 'social_posts_box';
  static const String _storiesBoxName = 'social_stories_box';

  // --- POST ---

  /// Carica un batch di post (default 6) partendo dall'ultimo presente in cache
  Future<void> caricaBatchPost({String? categoria, int limit = 6}) async {
    final box = Hive.box<SocialPost>(_postsBoxName);
    
    Query query = _firestore.collection('post').orderBy('timestamp', descending: true).limit(limit);
    
    if (categoria != null && categoria != 'generale') {
      query = query.where('categoria', isEqualTo: categoria);
    }

    // Troviamo l'ultimo post in cache per questa categoria per sapere da dove ripartire
    var cached = box.values.where((p) {
      if (categoria == null || categoria == 'generale') return true;
      return p.categoria == categoria;
    }).toList();
    
    if (cached.isNotEmpty) {
      // Ordiniamo per timestamp decrescente (più recenti prima)
      cached.sort((a, b) => (b.timestamp ?? DateTime(2000)).compareTo(a.timestamp ?? DateTime(2000)));
      // Prendiamo il post più vecchio in cache (l'ultimo della lista ordinata) per caricare quelli ancora più vecchi
      final oldestTimestamp = cached.last.timestamp; 
      if (oldestTimestamp != null) {
        query = query.startAfter([Timestamp.fromDate(oldestTimestamp)]);
      }
    }

    final snapshot = await query.get();
    for (var doc in snapshot.docs) {
      final post = SocialPost.fromFirestore(doc);
      await box.put(post.id, post);
    }
  }

  List<SocialPost> getCachedPosts({String? categoria, String? uid}) {
    final box = Hive.box<SocialPost>(_postsBoxName);
    var posts = box.values.toList();
    
    posts.sort((a, b) {
      if (a.timestamp == null) return 1;
      if (b.timestamp == null) return -1;
      return b.timestamp!.compareTo(a.timestamp!);
    });

    if (uid != null) {
      posts = posts.where((p) => p.uid == uid).toList();
    }

    if (categoria != null && categoria != 'generale') {
      posts = posts.where((p) => p.categoria == categoria).toList();
    }
    
    return posts;
  }

  Stream<QuerySnapshot> getPostStream({String? categoria}) {
    Query query = _firestore.collection('post').orderBy('timestamp', descending: true);
    if (categoria != null && categoria != 'generale') {
      query = query.where('categoria', isEqualTo: categoria);
    }
    return query.snapshots();
  }

  Stream<QuerySnapshot> getPostStreamByUid(String uid) {
    return _firestore
        .collection('post')
        .where('uid', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> creaPost({
    required String uid,
    required String autore,
    String? fotoProfilo,
    required String testo,
    required String categoria,
    required String ruoloAutore,
    File? immagineFile,
    String? immagineUrl, 
    double? lat,
    double? lng,
    bool isShared = false,
    String? originalPostId,
    String? originalAutore,
    DateTime? eventDate,
    String? eventLocation,
    String? eventLink,
    DateTime? eventEndDate,
  }) async {
    String? finalImmagineUrl = immagineUrl;

    if (immagineFile != null) {
      final ref = _storage.ref().child('post_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(immagineFile);
      finalImmagineUrl = await ref.getDownloadURL();
    }

    final docRef = _firestore.collection('post').doc();
    final now = DateTime.now();

    // Optimistic UI: Aggiungiamo subito a Hive
    final temporaryPost = SocialPost(
      id: docRef.id,
      uid: uid,
      autore: autore,
      fotoProfilo: fotoProfilo,
      testo: testo,
      categoria: categoria,
      ruoloAutore: ruoloAutore,
      immagineUrl: finalImmagineUrl,
      timestamp: now,
      lat: lat,
      lng: lng,
      isShared: isShared,
      originalPostId: originalPostId,
      originalAutore: originalAutore,
      eventDate: eventDate,
      eventLocation: eventLocation,
      eventLink: eventLink,
      eventEndDate: eventEndDate,
    );
    
    final box = Hive.box<SocialPost>(_postsBoxName);
    await box.put(docRef.id, temporaryPost);

    await docRef.set({
      'uid': uid,
      'autore': autore,
      'fotoUrl': fotoProfilo,
      'testo': testo,
      'categoria': categoria,
      'ruoloAutore': ruoloAutore,
      'immagineUrl': finalImmagineUrl,
      'lat': lat,
      'lng': lng,
      'timestamp': FieldValue.serverTimestamp(),
      'isShared': isShared,
      'originalPostId': originalPostId,
      'originalAutore': originalAutore,
      'eventDate': eventDate != null ? Timestamp.fromDate(eventDate) : null,
      'eventLocation': eventLocation,
      'eventLink': eventLink,
      'eventEndDate': eventEndDate != null ? Timestamp.fromDate(eventEndDate) : null,
    });
  }

  Future<void> aggiornaPost({
    required String postId,
    required String testo,
    String? immagineUrl, 
    double? lat,
    double? lng,
    DateTime? eventDate,
    String? eventLocation,
    String? eventLink,
    File? nuovaImmagine,
    DateTime? eventEndDate,
  }) async {
    Map<String, dynamic> data = {
      'testo': testo,
      'lat': lat,
      'lng': lng,
      'eventDate': eventDate != null ? Timestamp.fromDate(eventDate) : null,
      'eventLocation': eventLocation,
      'eventLink': eventLink,
      'eventEndDate': eventEndDate != null ? Timestamp.fromDate(eventEndDate) : null,
    };

    if (nuovaImmagine != null) {
      final ref = _storage.ref().child('post_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(nuovaImmagine);
      data['immagineUrl'] = await ref.getDownloadURL();
    } else {
      data['immagineUrl'] = immagineUrl;
    }

    await _firestore.collection('post').doc(postId).update(data);
    
    // Aggiorniamo anche Hive localmente
    final box = Hive.box<SocialPost>(_postsBoxName);
    final post = box.get(postId);
    if (post != null) {
      final updatedPost = SocialPost(
        id: post.id,
        uid: post.uid,
        autore: post.autore,
        fotoProfilo: post.fotoProfilo,
        testo: testo,
        categoria: post.categoria,
        ruoloAutore: post.ruoloAutore,
        immagineUrl: data['immagineUrl'] ?? post.immagineUrl,
        timestamp: post.timestamp,
        lat: lat ?? post.lat,
        lng: lng ?? post.lng,
        isShared: post.isShared,
        originalPostId: post.originalPostId,
        originalAutore: post.originalAutore,
        eventDate: eventDate ?? post.eventDate,
        eventLocation: eventLocation ?? post.eventLocation,
        eventLink: eventLink ?? post.eventLink,
        eventEndDate: eventEndDate ?? post.eventEndDate,
      );
      await box.put(postId, updatedPost);
    }
  }

  Future<void> eliminaPost(String postId, String? immagineUrl) async {
    if (immagineUrl != null && immagineUrl.isNotEmpty) {
      try {
        await _storage.refFromURL(immagineUrl).delete();
      } catch (e) {
        print("Errore eliminazione immagine storage: $e");
      }
    }
    await _firestore.collection('post').doc(postId).delete();
    
    // Rimuoviamo da Hive
    final box = Hive.box<SocialPost>(_postsBoxName);
    await box.delete(postId);
  }

  Future<void> repost({
    required String uid,
    required String autore,
    String? fotoProfilo,
    required String originalPostId,
    required String originalAutore,
    required String originalText,
    String? originalImageUrl,
    double? lat,
    double? lng,
  }) async {
    final docRef = _firestore.collection('post').doc();
    
    // Optimistic UI
    final box = Hive.box<SocialPost>(_postsBoxName);
    final tempPost = SocialPost(
      id: docRef.id,
      uid: uid,
      autore: autore,
      fotoProfilo: fotoProfilo,
      testo: originalText,
      immagineUrl: originalImageUrl,
      lat: lat,
      lng: lng,
      timestamp: DateTime.now(),
      isShared: true,
      originalPostId: originalPostId,
      originalAutore: originalAutore,
      categoria: 'generale',
      ruoloAutore: 'proprietario',
    );
    await box.put(docRef.id, tempPost);

    await docRef.set({
      'uid': uid,
      'autore': autore,
      'fotoUrl': fotoProfilo,
      'testo': originalText,
      'immagineUrl': originalImageUrl,
      'lat': lat,
      'lng': lng,
      'timestamp': FieldValue.serverTimestamp(),
      'isShared': true,
      'originalPostId': originalPostId,
      'originalAutore': originalAutore,
      'categoria': 'generale',
      'ruoloAutore': 'proprietario', 
    });
  }

  // --- STORIE ---

  List<SocialStory> getCachedStories() {
    final box = Hive.box<SocialStory>(_storiesBoxName);
    var stories = box.values.toList();
    stories.sort((a, b) => (b.timestamp ?? DateTime(2000)).compareTo(a.timestamp ?? DateTime(2000)));
    return stories;
  }

  Stream<QuerySnapshot> getStorieStream() {
    final DateTime limit = DateTime.now().subtract(const Duration(hours: 24));
    return _firestore
        .collection('storie')
        .where('timestamp', isGreaterThan: Timestamp.fromDate(limit))
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> creaStoria({
    required String uid,
    required String autore,
    String? fotoProfilo,
    required File immagineFile,
    double? lat,
    double? lng,
  }) async {
    final imgRef = _storage.ref().child('storie/immagini/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await imgRef.putFile(immagineFile);
    final immagineUrl = await imgRef.getDownloadURL();

    final docRef = _firestore.collection('storie').doc();
    
    // Optimistic UI
    final box = Hive.box<SocialStory>(_storiesBoxName);
    final tempStory = SocialStory(
      id: docRef.id,
      uid: uid,
      autore: autore,
      fotoProfilo: fotoProfilo,
      immagineUrl: immagineUrl,
      lat: lat,
      lng: lng,
      timestamp: DateTime.now(),
    );
    await box.put(docRef.id, tempStory);

    await docRef.set({
      'uid': uid,
      'autore': autore,
      'fotoProfilo': fotoProfilo,
      'immagineUrl': immagineUrl,
      'lat': lat,
      'lng': lng,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
