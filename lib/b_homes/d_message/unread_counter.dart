import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petping/b_homes/d_message/chat_preview.dart';

class UnreadCounter {
  UnreadCounter._();
  static final UnreadCounter _instance = UnreadCounter._();
  factory UnreadCounter() => _instance;

  final ValueNotifier<int> count = ValueNotifier<int>(0);

  Future<void> init() async {
    try {
      if (!Hive.isBoxOpen('chatPreviews')) {
        await Hive.openBox<ChatPreview>('chatPreviews');
      }

      final box = Hive.box<ChatPreview>('chatPreviews');
      int unread = 0;

      for (final key in box.keys) {
        final preview = box.get(key) as ChatPreview?;
        if (preview != null && preview.isRead == false) {
          unread++;
        }
      }

      count.value = unread;

    } catch (e) {
      print('UnreadCounter init error: $e');
    }
  }

  /// 🔥 Incrementa SOLO se il messaggio è ricevuto (mittente diverso da me)
  void incrementIfReceived(String senderId) {
    final myUid = FirebaseAuth.instance.currentUser?.uid;
    
    // Se il messaggio è stato inviato da ME → non incrementare nulla
    if (senderId == myUid) {
      print('UnreadCounter: Messaggio inviato da me, ignoro.');
      return;
    }

    // Se l'ID è diverso (messaggio ricevuto) → incrementa il badge
    count.value = count.value + 1;
    print('UnreadCounter: Messaggio ricevuto, incremento badge.');
  }

  void increment() => count.value = count.value + 1;
  void decrement() => count.value = (count.value - 1).clamp(0, 9999);
  void set(int v) => count.value = v < 0 ? 0 : v;
}
