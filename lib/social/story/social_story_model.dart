import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'social_story_model.g.dart';

@HiveType(typeId: 14)
class SocialStory extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String uid;
  @HiveField(2)
  final String autore;
  @HiveField(3)
  final String? fotoProfilo;
  @HiveField(4)
  final String immagineUrl;
  @HiveField(5)
  final String? audioUrl;
  @HiveField(6)
  final double? lat;
  @HiveField(7)
  final double? lng;
  @HiveField(8)
  final DateTime? timestamp;

  SocialStory({
    required this.id,
    required this.uid,
    required this.autore,
    this.fotoProfilo,
    required this.immagineUrl,
    this.audioUrl,
    this.lat,
    this.lng,
    this.timestamp,
  });

  factory SocialStory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SocialStory(
      id: doc.id,
      uid: data['uid'] ?? '',
      autore: data['autore'] ?? 'Anonimo',
      fotoProfilo: data['fotoProfilo'],
      immagineUrl: data['immagineUrl'] ?? '',
      audioUrl: data['audioUrl'],
      lat: data['lat']?.toDouble(),
      lng: data['lng']?.toDouble(),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'autore': autore,
      'fotoProfilo': fotoProfilo,
      'immagineUrl': immagineUrl,
      'audioUrl': audioUrl,
      'lat': lat,
      'lng': lng,
      'timestamp': timestamp != null ? Timestamp.fromDate(timestamp!) : FieldValue.serverTimestamp(),
    };
  }
}
