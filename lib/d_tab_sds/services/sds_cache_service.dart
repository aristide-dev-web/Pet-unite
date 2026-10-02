import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:petping/d_tab_sds/models/sds_models.dart';
import 'package:petping/social/post/social_post_model.dart';
import 'package:petping/social/story/social_story_model.dart';
import 'package:petping/b_homes/c_datianimale/diariopet/back_diario.dart';

class SDSCacheService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String lostBoxName = 'lost_animals_box';
  static const String custodiaBoxName = 'custodia_animals_box';
  static const String adozioneBoxName = 'adozione_animals_box';
  static const String postsBoxName = 'social_posts_box';
  static const String storiesBoxName = 'social_stories_box';

  static Future<void> sincronizzaTutto() async {
    // Apriamo i box immediatamente per evitare crash nell'UI o caricamenti infiniti
    await Hive.openBox<LostAnimal>(lostBoxName);
    await Hive.openBox<CustodiaAnimal>(custodiaBoxName);
    await Hive.openBox<AdozioneAnimal>(adozioneBoxName);
    await Hive.openBox<SocialPost>(postsBoxName);
    await Hive.openBox<SocialStory>(storiesBoxName);
    await Hive.openBox<Animale>(animaliBoxName);

    _sincronizzaSmarriti();
    _sincronizzaCustodia();
    _sincronizzaAdozioni();
    _sincronizzaSocialPosts();
    _sincronizzaSocialStories();
    _sincronizzaMieiAnimali();
  }

  static void _sincronizzaSmarriti() {
    _db.collection('animali_smarriti').orderBy('timestamp', descending: true).limit(10).snapshots().listen((snapshot) async {
      var box = Hive.box<LostAnimal>(lostBoxName);
      for (var change in snapshot.docChanges) {
        if (change.type != DocumentChangeType.removed) {
          await box.put(change.doc.id, LostAnimal.fromFirestore(change.doc));
        }
      }
    });
  }

  static Future<void> caricaBatchSmarriti({int limit = 6}) async {
    final box = Hive.box<LostAnimal>(lostBoxName);
    Query query = _db.collection('animali_smarriti').orderBy('timestamp', descending: true).limit(limit);

    var cached = box.values.toList();
    if (cached.isNotEmpty) {
      cached.sort((a, b) => (b.timestamp ?? DateTime(2000)).compareTo(a.timestamp ?? DateTime(2000)));
      final oldestTimestamp = cached.last.timestamp;
      if (oldestTimestamp != null) {
        query = query.startAfter([Timestamp.fromDate(oldestTimestamp)]);
      }
    }

    final snapshot = await query.get();
    for (var doc in snapshot.docs) {
      await box.put(doc.id, LostAnimal.fromFirestore(doc));
    }
  }

  static void _sincronizzaCustodia() {
    _db.collection('animali_custodia').orderBy('timestamp', descending: true).limit(10).snapshots().listen((snapshot) async {
      var box = Hive.box<CustodiaAnimal>(custodiaBoxName);
      for (var change in snapshot.docChanges) {
        if (change.type != DocumentChangeType.removed) {
          await box.put(change.doc.id, CustodiaAnimal.fromFirestore(change.doc));
        }
      }
    });
  }

  static void _sincronizzaAdozioni() {
    _db.collection('animali_adozione').orderBy('timestamp', descending: true).limit(10).snapshots().listen((snapshot) async {
      var box = Hive.box<AdozioneAnimal>(adozioneBoxName);
      for (var change in snapshot.docChanges) {
        if (change.type != DocumentChangeType.removed) {
          await box.put(change.doc.id, AdozioneAnimal.fromFirestore(change.doc));
        }
      }
    });
  }

  static void _sincronizzaSocialPosts() {
    _db.collection('post').orderBy('timestamp', descending: true).limit(10).snapshots().listen((snapshot) async {
      var box = Hive.box<SocialPost>(postsBoxName);
      for (var change in snapshot.docChanges) {
        if (change.type != DocumentChangeType.removed) {
          await box.put(change.doc.id, SocialPost.fromFirestore(change.doc));
        }
      }
    });
  }

  static void _sincronizzaSocialStories() {
    final String? currentUid = FirebaseAuth.instance.currentUser?.uid;
    final DateTime limit = DateTime.now().subtract(const Duration(hours: 24));

    _db.collection('storie')
      .where('timestamp', isGreaterThan: Timestamp.fromDate(limit))
      .snapshots().listen((snapshot) async {
        var box = Hive.box<SocialStory>(storiesBoxName);
        
        final now = DateTime.now();
        final expiredKeys = box.values
            .where((s) => s.uid != currentUid && (s.timestamp == null || now.difference(s.timestamp!).inHours >= 24))
            .map((s) => s.id)
            .toList();
        for (var key in expiredKeys) {
          await box.delete(key);
        }

        for (var change in snapshot.docChanges) {
          if (change.type != DocumentChangeType.removed) {
             await box.put(change.doc.id, SocialStory.fromFirestore(change.doc));
          } else {
             await box.delete(change.doc.id);
          }
        }
    });

    if (currentUid != null) {
      _db.collection('storie')
        .where('uid', isEqualTo: currentUid)
        .snapshots().listen((snapshot) async {
          var box = Hive.box<SocialStory>(storiesBoxName);
          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.removed) {
              await box.delete(change.doc.id);
            } else {
              await box.put(change.doc.id, SocialStory.fromFirestore(change.doc));
            }
          }
      });
    }
  }

  static void _sincronizzaMieiAnimali() {
    final String? currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) return;

    _db.collection('animali')
      .where('userId', isEqualTo: currentUid)
      .snapshots().listen((snapshot) async {
        var box = Hive.box<Animale>(animaliBoxName);
        for (var change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.removed) {
            await box.delete(change.doc.id);
          } else {
            await box.put(change.doc.id, Animale.fromFirestore(change.doc));
          }
        }
    });
  }
}
