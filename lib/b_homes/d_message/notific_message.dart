import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:petping/b_homes/d_message/chat_preview.dart';


// -------------------------------------------------------------
// 🔥 HANDLER BACKGROUND FCM (DEVE RESTARE TOP-LEVEL)
// -------------------------------------------------------------
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  try {
    final data = message.data;
    final msg = {
      'messageId': data['messageId'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'chatId': data['chatId'],
      'senderId': data['senderId'],
      'text': data['text'] ?? message.notification?.body ?? '',
      'timestamp': data['timestamp'] ?? FieldValue.serverTimestamp(),
      'raw': data,
    };
    await FirebaseFirestore.instance.collection('pendingMessages').add(msg);
  } catch (e) {
    print('Background handler error: $e');
  }
}



// -------------------------------------------------------------
// 🔥 NOTIFICATION SERVICE (MESSAGGI + NOTIFICHE LOCALI)
// -------------------------------------------------------------
class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin localNotifications = FlutterLocalNotificationsPlugin();

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> initialize({required void Function(Map<String, dynamic>) onOpen}) async {
    // 1) Permessi FCM
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    // 2) Inizializzazione notifiche locali
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);

    await localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null) {
          try {
            final data = jsonDecode(details.payload!);
            onOpen(Map<String, dynamic>.from(data));
          } catch (e) {
            onOpen({'type': 'calendar', 'id': details.payload});
          }
        }
      },
    );

    // 3) Canali Android
    const String channelId = 'high_importance_channel';
    const String channelName = 'Notifiche Importanti';

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId,
      channelName,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    const AndroidNotificationChannel calendarChannel = AndroidNotificationChannel(
      'calendario_animali',
      'Calendario Animali',
      importance: Importance.max,
    );

    final platform = localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(channel);
    await platform?.createNotificationChannel(calendarChannel);

    // 4) Listener FCM in background
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 5) Listener FCM in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final data = message.data;
      final String title = data['title'] ?? message.notification?.title ?? 'Nuovo messaggio';
      final String body = data['text'] ?? message.notification?.body ?? '';
      final String payload = jsonEncode(data);

      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        importance: Importance.max,
        priority: Priority.high,
        styleInformation: BigTextStyleInformation(body),
        icon: '@mipmap/ic_launcher',
      );

      final details = NotificationDetails(android: androidDetails);

      await localNotifications.show(
        id: message.hashCode,
        title: title,
        body: body,
        notificationDetails: details,
        payload: payload,
      );

      await _syncMessageToHive(message);
    });

    // 6) Listener apertura notifica
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      try {
        onOpen(message.data);
      } catch (_) {}
    });

    // 7) Token FCM
    await updateToken();
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await _saveTokenToFirestore(newToken);
    });

    // 8) Sincronizza messaggi pendenti
    await _syncPendingMessagesToHive();
  }



  // -------------------------------------------------------------
  // 🔄 SINCRONIZZAZIONE MESSAGGI
  // -------------------------------------------------------------
  Future<void> _syncMessageToHive(RemoteMessage message) async {
    final chatId = message.data['chatId'];
    final senderId = message.data['senderId'];
    final text = message.data['text'] ?? message.notification?.body ?? '';
    final messageId = message.data['messageId'] ?? DateTime.now().millisecondsSinceEpoch.toString();

    if (chatId == null || senderId == null) return;

    if (!Hive.isBoxOpen('chatPreviews')) {
      await Hive.openBox<ChatPreview>('chatPreviews');
    }
    final box = Hive.box<ChatPreview>('chatPreviews');

    final messagesBoxName = 'messages_$chatId';
    if (!Hive.isBoxOpen(messagesBoxName)) {
      await Hive.openBox(messagesBoxName);
    }
    final messagesBox = Hive.box(messagesBoxName);

    if (messagesBox.containsKey(messageId)) return;

    String username = 'Utente';
    try {
      final userDoc = await FirebaseFirestore.instance.collection('utenti').doc(senderId).get();
      username = userDoc.data()?['username'] ?? username;
    } catch (_) {}

    final preview = ChatPreview(
      chatId: chatId,
      otherUserId: senderId,
      otherUsername: username,
      lastMessage: text,
      lastTimestamp: DateTime.now(),
    );
    preview.isRead = false;

    await box.put(chatId, preview);
    await messagesBox.put(messageId, {
      'messageId': messageId,
      'chatId': chatId,
      'senderId': senderId,
      'text': text,
      'timestamp': DateTime.now().toIso8601String(),
      'synced': false,
    });
  }



  // -------------------------------------------------------------
  // 🔑 TOKEN FCM
  // -------------------------------------------------------------
  Future<void> updateToken() async {
    final token = await _fcm.getToken();
    if (token != null) await _saveTokenToFirestore(token);
  }

  Future<void> _saveTokenToFirestore(String token) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await FirebaseFirestore.instance.collection('token').doc(uid).set({'fcmToken': token}, SetOptions(merge: true));
    } catch (e) {
      print('Save token failed: $e');
    }
  }



  // -------------------------------------------------------------
  // 🔄 SINCRONIZZAZIONE MESSAGGI PENDENTI
  // -------------------------------------------------------------
  Future<void> _syncPendingMessagesToHive() async {
    try {
      final snap = await FirebaseFirestore.instance.collection('pendingMessages').get();
      for (final doc in snap.docs) {
        final data = doc.data();
        final chatId = data['chatId'];
        final senderId = data['senderId'];
        final text = data['text'] ?? '';
        final messageId = data['messageId'] ?? doc.id;

        await _syncMessageToHive(RemoteMessage(
          data: {
            'messageId': messageId,
            'chatId': chatId,
            'senderId': senderId,
            'text': text,
          },
        ));

        await doc.reference.delete();
      }
    } catch (e) {
      print('Sync pending failed: $e');
    }
  }
}