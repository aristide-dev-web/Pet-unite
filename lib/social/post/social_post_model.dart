import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'social_post_model.g.dart';

@HiveType(typeId: 4)
class SocialPost extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String uid;
  @HiveField(2)
  final String autore;
  @HiveField(3)
  final String? fotoProfilo;
  @HiveField(4)
  final String testo;
  @HiveField(5)
  final String categoria;
  @HiveField(6)
  final String ruoloAutore;
  @HiveField(7)
  final String? immagineUrl;
  @HiveField(8)
  final DateTime? timestamp;
  
  @HiveField(9)
  final bool isShared;
  @HiveField(10)
  final String? originalPostId;
  @HiveField(11)
  final String? originalAutore;

  @HiveField(12)
  final DateTime? eventDate;
  @HiveField(13)
  final String? eventLocation;
  @HiveField(14)
  final String? eventLink;

  // Nuovi campi per la geolocalizzazione
  @HiveField(15)
  final double? lat;
  @HiveField(16)
  final double? lng;

  @HiveField(17)
  final DateTime? eventEndDate;

  SocialPost({
    required this.id,
    required this.uid,
    required this.autore,
    this.fotoProfilo,
    required this.testo,
    required this.categoria,
    required this.ruoloAutore,
    this.immagineUrl,
    this.timestamp,
    this.isShared = false,
    this.originalPostId,
    this.originalAutore,
    this.eventDate,
    this.eventLocation,
    this.eventLink,
    this.lat,
    this.lng,
    this.eventEndDate,
  });

  factory SocialPost.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SocialPost(
      id: doc.id,
      uid: data['uid'] ?? '',
      autore: data['autore'] ?? 'Anonimo',
      fotoProfilo: data['fotoUrl'],
      testo: data['testo'] ?? '',
      categoria: data['categoria'] ?? 'generale',
      ruoloAutore: data['ruoloAutore'] ?? 'proprietario',
      immagineUrl: data['immagineUrl'],
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
      isShared: data['isShared'] ?? false,
      originalPostId: data['originalPostId'],
      originalAutore: data['originalAutore'],
      eventDate: (data['eventDate'] as Timestamp?)?.toDate(),
      eventLocation: data['eventLocation'],
      eventLink: data['eventLink'],
      lat: data['lat']?.toDouble(),
      lng: data['lng']?.toDouble(),
      eventEndDate: (data['eventEndDate'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'autore': autore,
      'fotoUrl': fotoProfilo,
      'testo': testo,
      'categoria': categoria,
      'ruoloAutore': ruoloAutore,
      'immagineUrl': immagineUrl,
      'timestamp': timestamp != null ? Timestamp.fromDate(timestamp!) : FieldValue.serverTimestamp(),
      'isShared': isShared,
      'originalPostId': originalPostId,
      'originalAutore': originalAutore,
      'eventDate': eventDate != null ? Timestamp.fromDate(eventDate!) : null,
      'eventLocation': eventLocation,
      'eventLink': eventLink,
      'lat': lat,
      'lng': lng,
      'eventEndDate': eventEndDate != null ? Timestamp.fromDate(eventEndDate!) : null,
    };
  }
}
