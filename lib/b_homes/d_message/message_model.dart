import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'message_model.g.dart';

@HiveType(typeId: 0)
class Message extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String senderId;

  @HiveField(2)
  final String receiverId;

  @HiveField(3)
  final String text;

  @HiveField(4)
  final DateTime timestamp;

  @HiveField(5)
  final bool isRead;

  @HiveField(6)
  final String? type; // 'text', 'booking_request'

  @HiveField(7)
  final Map<String, dynamic>? bookingData; 

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.timestamp,
    this.isRead = false,
    this.type = 'text',
    this.bookingData,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    // Gestione sicura del timestamp per evitare crash durante la sincronizzazione
    DateTime parsedTime;
    if (map['timestamp'] == null) {
      parsedTime = DateTime.now();
    } else if (map['timestamp'] is Timestamp) {
      parsedTime = (map['timestamp'] as Timestamp).toDate();
    } else {
      parsedTime = DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now();
    }

    return Message(
      id: map['id']?.toString() ?? '',
      senderId: map['senderId']?.toString() ?? '',
      receiverId: map['receiverId']?.toString() ?? '',
      text: map['text']?.toString() ?? '',
      timestamp: parsedTime,
      isRead: map['isRead'] ?? false,
      type: map['type'] ?? 'text',
      bookingData: map['bookingData'] is Map ? Map<String, dynamic>.from(map['bookingData']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'type': type,
      'bookingData': bookingData,
    };
  }
}
