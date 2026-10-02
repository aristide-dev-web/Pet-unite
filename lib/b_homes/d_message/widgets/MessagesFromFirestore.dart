import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:petping/b_homes/d_message/message_model.dart';

class MessageService {
  final Box<Message> _box = Hive.box<Message>('messages');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> syncMessagesFromFirestore(String chatId) async {
    final querySnapshot = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .get();

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final message = Message(
        id: data['id'],
        senderId: data['senderId'],
        receiverId: data['receiverId'],
        text: data['text'],
        timestamp: (data['timestamp'] as Timestamp).toDate(),
        isRead: data['isRead'] ?? false,
      );

      if (!_box.containsKey(message.id)) {
        await _box.put(message.id, message);
      }
    }
  }
}