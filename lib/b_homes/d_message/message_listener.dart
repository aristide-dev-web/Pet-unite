import 'dart:async';
import 'package:petping/b_homes/d_message/message_service.dart';

class MessageListener {
  static final MessageListener _instance = MessageListener._internal();
  factory MessageListener() => _instance;

  MessageListener._internal();

  StreamSubscription? _chatListSub;
  String? _currentUserId;

  void start(String userId) {
    if (_currentUserId == userId) return;

    stop(); 

    _currentUserId = userId;
    final service = MessageService();

    // Ascolta SOLO le anteprime per la lista chat
    _chatListSub = service.startChatListListener(userId);

    print("🚀 Listener anteprime avviato per: $userId");
  }

  void stop() {
    _chatListSub?.cancel();
    _chatListSub = null;
    _currentUserId = null;
    print("🛑 Listener anteprime fermato.");
  }
}
