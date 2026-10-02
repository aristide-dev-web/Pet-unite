import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petping/b_homes/d_message/message_model.dart';
import 'package:petping/b_homes/b_user/blockuser/block_user_service.dart';
import 'chat_preview.dart';
import 'dart:async';
import 'package:petping/notific.dart'; 
import 'package:flutter_local_notifications/flutter_local_notifications.dart' hide Message; 
import 'dart:developer' as dev;
import 'package:hive/hive.dart';

class MessageService {
  Box<ChatPreview> get _previewBox => Hive.box<ChatPreview>('chatPreviews');

  MessageService();

  Stream<List<Message>> getMessages(String chatId) {
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            try {
              return Message.fromMap(doc.data());
            } catch (e) {
              dev.log("DEBUG_MSG: Errore parsing messaggio: $e");
              return null;
            }
          }).whereType<Message>().toList();
        });
  }

  StreamSubscription startChatListListener(String currentUserId) {
    return FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .snapshots()
        .listen((chatSnapshot) {
      for (var chatDoc in chatSnapshot.docs) {
        _updateLocalPreviewFromDoc(chatDoc, currentUserId);
      }
    });
  }

  Future<void> _updateLocalPreviewFromDoc(DocumentSnapshot chatDoc, String currentUserId) async {
    try {
      final data = chatDoc.data() as Map<String, dynamic>?;
      if (data == null) return;

      final String chatId = chatDoc.id;
      final List<String> participants = List<String>.from(data['participants'] ?? []);
      if (participants.isEmpty) return;
      
      final String otherId = participants.firstWhere((id) => id != currentUserId, orElse: () => '');
      if (otherId.isEmpty) return;

      // ✅ SE L'UTENTE È BLOCCATO (o mi ha bloccato), non mostriamo la preview
      final isBlocked = await BlockUserService.isBlocked(currentUserId: currentUserId, otherUserId: otherId);
      if (isBlocked) {
        _previewBox.delete(chatId);
        return;
      }

      final existing = _previewBox.get(chatId);
      final String lastMsg = data['lastMessage'] ?? '';
      
      // Recupero info profilo dal documento Firestore
      final Map<String, dynamic> displayNames = Map<String, dynamic>.from(data['displayNames'] ?? {});
      final Map<String, dynamic> photoUrls = Map<String, dynamic>.from(data['photoUrls'] ?? {});
      
      final String otherUsername = displayNames[otherId] ?? existing?.otherUsername ?? 'Utente';
      final String? otherPhotoUrl = photoUrls[otherId] ?? existing?.otherUserPhotoUrl;

      // ✅ PARACADUTE LOGICA: Se la chat è già booking, rimane booking
      final bool isBooking = (data['isBookingChat'] == true) || (existing?.isBookingChat == true);

      final preview = ChatPreview(
        chatId: chatId,
        otherUserId: otherId,
        otherUsername: otherUsername,
        lastMessage: lastMsg,
        lastTimestamp: (data['lastTimestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
        isBookingChat: isBooking,
        otherUserPhotoUrl: otherPhotoUrl,
      );

      if (data['senderId'] != currentUserId && (existing == null || existing.lastMessage != lastMsg)) {
        preview.isRead = false;
        
        NotificationService().localNotifications.show(
          id: chatId.hashCode,
          title: '${isBooking ? "🐾 " : ""}Messaggio da ${preview.otherUsername}',
          body: lastMsg,
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'Notifiche Importanti',
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
          payload: '{"chatId":"$chatId", "otherUserId":"$otherId", "otherUsername":"${preview.otherUsername}"}',
        );
      } else {
        preview.isRead = existing?.isRead ?? true;
      }
      
      await _previewBox.put(chatId, preview);
    } catch (e) {
      dev.log("DEBUG_MSG: Errore aggiornamento preview locale: $e");
    }
  }

  Future<void> sendMessage(
    String chatId, 
    Message message, {
    bool isBooking = false,
    String? senderName,
    String? senderPhotoUrl,
    String? receiverName,
    String? receiverPhotoUrl,
  }) async {
    try {
      dev.log("DEBUG_MSG: Inizio invio messaggio a $chatId");

      // ✅ CONTROLLO BLOCCO PRIMA DI INVIARE
      final isBlocked = await BlockUserService.isBlocked(currentUserId: message.senderId, otherUserId: message.receiverId);
      if (isBlocked) {
        throw Exception("Impossibile inviare messaggi a un utente bloccato.");
      }

      final messageMap = message.toMap();
      
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(message.id)
          .set(messageMap);

      final bool isNewBooking = isBooking || (message.type == 'booking_request');

      // 1. Assicuriamoci che il documento chat esista
      final Map<String, dynamic> chatBase = {
        'participants': FieldValue.arrayUnion([message.senderId, message.receiverId]),
      };
      
      // ✅ LOGICA PARACADUTE: Se il messaggio è di tipo booking o il flag è true, attiviamo il flag.
      // Se è un messaggio normale, NON sovrascriviamo il flag esistente (merge: true non toccherà il campo se non lo inviamo).
      if (isNewBooking) {
        chatBase['isBookingChat'] = true;
      }

      await FirebaseFirestore.instance.collection('chats').doc(chatId).set(chatBase, SetOptions(merge: true));

      // 2. Aggiorniamo i campi dinamici (lastMessage e profili)
      final Map<String, dynamic> chatUpdate = {
        'lastMessage': message.text,
        'lastTimestamp': FieldValue.serverTimestamp(),
        'senderId': message.senderId,
      };

      if (senderName != null) chatUpdate['displayNames.${message.senderId}'] = senderName;
      if (senderPhotoUrl != null) chatUpdate['photoUrls.${message.senderId}'] = senderPhotoUrl;
      if (receiverName != null) chatUpdate['displayNames.${message.receiverId}'] = receiverName;
      if (receiverPhotoUrl != null) chatUpdate['photoUrls.${message.receiverId}'] = receiverPhotoUrl;

      await FirebaseFirestore.instance.collection('chats').doc(chatId).update(chatUpdate);

      if (isNewBooking) {
        await FirebaseFirestore.instance
            .collection('chatRequests')
            .doc(message.receiverId)
            .collection('requests')
            .doc(chatId)
            .set({
          'fromUserId': message.senderId,
          'message': message.text,
          'timestamp': FieldValue.serverTimestamp(),
          'isBooking': true,
          'bookingId': message.bookingData?['id'],
        }, SetOptions(merge: true));
      }

      // Aggiornamento Hive locale immediato
      final existingPreview = _previewBox.get(chatId);
      final newPreview = ChatPreview(
        chatId: chatId,
        otherUserId: message.receiverId,
        otherUsername: receiverName ?? existingPreview?.otherUsername ?? 'Utente',
        lastMessage: message.text,
        lastTimestamp: DateTime.now(),
        // ✅ Mantieni lo stato booking se già esistente
        isBookingChat: isNewBooking || (existingPreview?.isBookingChat ?? false),
        isRead: true,
        otherUserPhotoUrl: receiverPhotoUrl ?? existingPreview?.otherUserPhotoUrl,
      );
      await _previewBox.put(chatId, newPreview);

      dev.log("DEBUG_MSG: Messaggio inviato con successo");

    } catch (e) {
      dev.log("DEBUG_MSG: ERRORE DURANTE L'INVIO: $e");
      rethrow;
    }
  }

  Future<void> updateBookingStatus({
    required String chatId,
    required String bookingId,
    required String newStatus,
    required String senderId,
    required String receiverId,
    double? newPrice,
    Map<String, dynamic>? bookingData,
  }) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('bookings').doc(bookingId);

      if ((newStatus == 'accepted' || newStatus == 'pagata') && bookingData != null) {
        bookingData['status'] = newStatus;
        await docRef.set(bookingData, SetOptions(merge: true));
      } else {
        await docRef.update({
          'status': newStatus,
          if (newPrice != null) 'totalPrice': newPrice,
        }).catchError((e) {
          dev.log("DEBUG_BOOKING: Documento non ancora esistente, normale se non ancora pagato.");
          return null;
        });
      }

      String text = "";
      if (newStatus == 'accepted') text = "✅ Ho accettato la tua richiesta!";
      else if (newStatus == 'rejected') text = "❌ Mi dispiace, non posso accettare.";
      else if (newStatus == 'controproposta') text = "💰 Ho inviato una controproposta.";
      else if (newStatus == 'pagata') text = "💳 Pagamento confermato! La prenotazione è ora ufficiale. 🎉";

      final sysMsgId = "sys_${DateTime.now().millisecondsSinceEpoch}";
      await FirebaseFirestore.instance.collection('chats').doc(chatId).collection('messages').doc(sysMsgId).set({
        'id': sysMsgId,
        'senderId': senderId,
        'receiverId': receiverId,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'text',
      });
      
      await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
        'lastMessage': text,
        'lastTimestamp': FieldValue.serverTimestamp(),
        'senderId': senderId,
        'isBookingChat': true,
      }, SetOptions(merge: true));

    } catch (e) {
      dev.log("DEBUG_BOOKING_UPDATE: $e");
    }
  }

  Future<void> markChatAsRead(String chatId) async {
    final preview = _previewBox.get(chatId);
    if (preview != null) {
      preview.isRead = true;
      await _previewBox.put(chatId, preview);
    }
  }
}

extension StreamStartWith<T> on Stream<T> {
  Stream<T> startWith(T value) async* {
    yield value;
    yield* this;
  }
}
