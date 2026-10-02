import 'package:hive/hive.dart';

part 'chat_preview.g.dart';

@HiveType(typeId: 1)
class ChatPreview extends HiveObject {
  @HiveField(0)
  final String chatId;

  @HiveField(1)
  final String otherUserId;

  @HiveField(2)
  final String otherUsername;

  @HiveField(3)
  final String lastMessage;

  @HiveField(4)
  final DateTime lastTimestamp;

  @HiveField(5)
  bool isRead;

  @HiveField(6)
  final bool isBookingChat;

  @HiveField(7)
  final String? otherUserPhotoUrl; // ✅ Foto profilo dell'altro utente

  ChatPreview({
    required this.chatId,
    required this.otherUserId,
    required this.otherUsername,
    required this.lastMessage,
    required this.lastTimestamp,
    this.isRead = true,
    this.isBookingChat = false,
    this.otherUserPhotoUrl,
  });
}
