import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:petping/social/notific/social_notification_model.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';

class SocialNotificationService {
  static final SocialNotificationService _instance = SocialNotificationService._internal();
  factory SocialNotificationService() => _instance;
  SocialNotificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _boxName = 'social_notifications_box';
  
  bool _isInitialLoad = true;
  Timer? _bundleTimer;
  Map<String, List<SocialNotification>> _pendingBundles = {};

  void startListening() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _subscribeToGlobalTopics();

    _firestore
        .collection('notifiche')
        .where('toUserId', isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) async {
      final box = await Hive.openBox<SocialNotification>(_boxName);

      for (var change in snapshot.docChanges) {
        final doc = change.doc;
        if (change.type == DocumentChangeType.removed) {
          await box.delete(doc.id);
        } else {
          final notification = SocialNotification.fromFirestore(doc);
          if (box.get(doc.id) == null) {
            await box.put(doc.id, notification);
            if (change.type == DocumentChangeType.added && !notification.isRead && !_isInitialLoad) {
              _handleIncomingNotification(notification);
            }
          }
        }
      }
      _isInitialLoad = false;
    });
  }

  void _handleIncomingNotification(SocialNotification notif) {
    // SOS, TAG e Prenotazioni mostrate subito
    if (notif.type == 'sos' || notif.type == 'tag' || notif.type.contains('booking')) {
      _showLocalNotification(notif);
      return;
    }

    final key = "${notif.type}_${notif.postId}";
    if (!_pendingBundles.containsKey(key)) {
      _pendingBundles[key] = [];
    }
    _pendingBundles[key]!.add(notif);

    _bundleTimer?.cancel();
    _bundleTimer = Timer(const Duration(seconds: 2), () {
      _sendBundledNotifications();
    });
  }

  void _sendBundledNotifications() {
    _pendingBundles.forEach((key, list) {
      if (list.isEmpty) return;
      if (list.length == 1) {
        _showLocalNotification(list.first);
      } else {
        final first = list.first;
        final count = list.length - 1;
        final summaryText = list.first.type == 'like' 
            ? "e altri $count hanno messo una zampata 🐾" 
            : "e altri $count hanno commentato 💬";

        _showGenericNotification(
          id: key.hashCode,
          title: "PetPing",
          body: "${first.fromUsername} $summaryText",
          payload: jsonEncode({'postId': first.postId, 'type': 'bundle'}),
          channelId: 'social_channel',
        );
      }
    });
    _pendingBundles.clear();
  }

  void _subscribeToGlobalTopics() {
    FirebaseMessaging.instance.subscribeToTopic('sos_alerts');
    FirebaseMessaging.instance.subscribeToTopic('custodia_alerts');
    FirebaseMessaging.instance.subscribeToTopic('adozione_alerts');
  }

  Future<void> sendNotification({
    required String toUserId,
    required String type, 
    required String text,
    String? postId,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final senderDoc = await _firestore.collection('utenti').doc(currentUser.uid).get();
    final senderData = senderDoc.data() ?? {};

    await _firestore.collection('notifiche').add({
      'toUserId': toUserId,
      'fromUserId': currentUser.uid,
      'fromUsername': senderData['username'] ?? 'Qualcuno',
      'fromUserPhoto': senderData['fotoUrl'],
      'type': type,
      'text': text,
      'postId': postId,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  Future<void> _showLocalNotification(SocialNotification notification) async {
    String title = "PetPing";
    String channelId = 'social_channel';

    if (notification.type.contains('booking') || notification.type == 'payment_confirmed') {
      title = notification.type == 'payment_confirmed' ? "Pagamento Ricevuto 💳" : "Aggiornamento Prenotazione 🐾";
      channelId = 'petsitting_channel';
    } else if (notification.type == 'sos') {
      title = "SOS PetPing 🚨";
      channelId = 'high_importance_channel';
    }

    await _showGenericNotification(
      id: notification.id.hashCode,
      title: title,
      body: '${notification.fromUsername} ${notification.text}',
      payload: jsonEncode({
        'type': notification.type,
        'postId': notification.postId,
        'fromUserId': notification.fromUserId,
      }),
      channelId: channelId,
    );
  }

  Future<void> _showGenericNotification({
    required int id, 
    required String title, 
    required String body, 
    String? payload,
    required String channelId,
  }) async {
    final FlutterLocalNotificationsPlugin localNotif = FlutterLocalNotificationsPlugin();
    
    final android = AndroidNotificationDetails(
      channelId,
      channelId == 'petsitting_channel' ? 'Notifiche Petsitting' : 'Notifiche Social',
      importance: Importance.max, 
      priority: Priority.high,
      color: channelId == 'petsitting_channel' ? const Color(0xFF00AAA0) : const Color(0xFF6366F1),
    );
    
    final details = NotificationDetails(android: android);

    await localNotif.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }

  Future<void> markAsRead(String notificationId) async {
    await _firestore.collection('notifiche').doc(notificationId).update({'isRead': true});
    final box = Hive.box<SocialNotification>(_boxName);
    final notif = box.get(notificationId);
    if (notif != null) {
      notif.isRead = true;
      await notif.save();
    }
  }
}
