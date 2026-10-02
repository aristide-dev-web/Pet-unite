import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'review_model.g.dart';

@HiveType(typeId: 15)
class PetReview extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String sitterId;
  @HiveField(2)
  final String reviewerId;
  @HiveField(3)
  final String reviewerName;
  @HiveField(4)
  final double rating;
  @HiveField(5)
  final String comment;
  @HiveField(6)
  final DateTime timestamp;
  @HiveField(7)
  final String? reviewerPhotoUrl;

  PetReview({
    required this.id,
    required this.sitterId,
    required this.reviewerId,
    required this.reviewerName,
    required this.rating,
    required this.comment,
    required this.timestamp,
    this.reviewerPhotoUrl,
  });

  factory PetReview.fromMap(Map<String, dynamic> data, String id) {
    return PetReview(
      id: id,
      sitterId: data['sitterId'] ?? '',
      reviewerId: data['reviewerId'] ?? '',
      reviewerName: data['reviewerName'] ?? 'Utente',
      reviewerPhotoUrl: data['reviewerPhotoUrl'],
      rating: (data['rating'] ?? 0.0).toDouble(),
      comment: data['comment'] ?? '',
      timestamp: data['timestamp'] != null
          ? (data['timestamp'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sitterId': sitterId,
      'reviewerId': reviewerId,
      'reviewerName': reviewerName,
      'reviewerPhotoUrl': reviewerPhotoUrl,
      'rating': rating,
      'comment': comment,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}
