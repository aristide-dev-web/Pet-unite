import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'social_notification_model.g.dart';

@HiveType(typeId: 5)
class SocialNotification extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String fromUserId;
  
  @HiveField(2)
  final String fromUsername;
  
  @HiveField(3)
  final String? fromUserPhoto;
  
  @HiveField(4)
  final String type; // 'tag', 'like', 'comment', 'sos'
  
  @HiveField(5)
  final String text; // es: "ti ha taggato in un post"
  
  @HiveField(6)
  final String? postId;
  
  @HiveField(7)
  final DateTime timestamp;
  
  @HiveField(8)
  bool isRead;

  SocialNotification({
    required this.id,
    required this.fromUserId,
    required this.fromUsername,
    this.fromUserPhoto,
    required this.type,
    required this.text,
    this.postId,
    required this.timestamp,
    this.isRead = false,
  });

  factory SocialNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SocialNotification(
      id: doc.id,
      fromUserId: data['fromUserId'] ?? '',
      fromUsername: data['fromUsername'] ?? 'Qualcuno',
      fromUserPhoto: data['fromUserPhoto'],
      type: data['type'] ?? 'info',
      text: data['text'] ?? '',
      postId: data['postId'],
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
    );
  }
}
