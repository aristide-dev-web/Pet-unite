import 'package:cloud_firestore/cloud_firestore.dart';
class BlockedUser {
  final String blockerId;
  final String blockedId;
  final DateTime timestamp;

  BlockedUser({
    required this.blockerId,
    required this.blockedId,
    required this.timestamp,
  });

  factory BlockedUser.fromMap(Map<String, dynamic> map) {
    return BlockedUser(
      blockerId: map['blockerId'] as String,
      blockedId: map['blockedId'] as String,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'blockerId': blockerId,
      'blockedId': blockedId,
      'timestamp': timestamp,
    };
  }
}