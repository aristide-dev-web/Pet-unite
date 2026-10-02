// lib/token.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';

class DeviceTokenService {
  DeviceTokenService._internal();
  static final DeviceTokenService _instance = DeviceTokenService._internal();
  factory DeviceTokenService() => _instance;

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  bool _initialized = false;

  /// Inizializza il servizio: ottiene token e registra il listener di refresh.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // Ottieni token e salvalo (locale + Firestore se utente loggato)
    await _updateToken();

    // Ascolta il refresh del token
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      print('DeviceTokenService: token refreshed: $newToken');
      await _saveToken(newToken);
    });
  }

  /// Recupera il token corrente e lo salva
  Future<void> _updateToken() async {
    try {
      final token = await _fcm.getToken();
      print('DeviceTokenService: getToken -> $token');
      await _saveToken(token);
    } catch (e) {
      if (e.toString().contains('permission-blocked')) {
        debugPrint('DeviceTokenService: getToken skipped (permission blocked)');
      } else {
        print('DeviceTokenService: _updateToken error: $e');
      }
    }
  }

  /// Salva token localmente e su Firestore se l'utente è loggato
  Future<void> _saveToken(String? token) async {
    await _saveTokenLocally(token);

    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null && token != null) {
      try {
        await FirebaseFirestore.instance
            .collection('token')
            .doc(uid)
            .set({
          'fcmToken': token,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        print('DeviceTokenService: token salvato su Firestore per $uid');
      } catch (e) {
        print('DeviceTokenService: errore salvataggio Firestore: $e');
      }
    } else {
      if (uid == null) {
        print('DeviceTokenService: utente non loggato, token salvato solo localmente.');
      }
      if (token == null) {
        print('DeviceTokenService: token è null, non salvato su Firestore.');
      }
    }
  }

  /// Salva token in Hive (box 'device')
  Future<void> _saveTokenLocally(String? token) async {
    try {
      if (!Hive.isBoxOpen('device')) await Hive.openBox('device');
      final box = Hive.box('device');

      if (token == null) {
        await box.delete('fcmToken');
        print('DeviceTokenService: token locale rimosso');
      } else {
        await box.put('fcmToken', token);
        print('DeviceTokenService: token locale salvato');
      }
    } catch (e) {
      print('DeviceTokenService: errore Hive: $e');
    }
  }

  /// Restituisce il token salvato localmente (o null)
  Future<String?> getLocalToken() async {
    try {
      if (!Hive.isBoxOpen('device')) await Hive.openBox('device');
      final box = Hive.box('device');
      return box.get('fcmToken') as String?;
    } catch (e) {
      print('DeviceTokenService: getLocalToken error: $e');
      return null;
    }
  }

  /// Chiamare dopo il login per associare il token locale all'utente
  Future<void> attachTokenToUserAfterLogin() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      print('DeviceTokenService: attachTokenToUserAfterLogin called but uid is null');
      return;
    }

    final token = await getLocalToken();
    if (token != null) {
      try {
        await FirebaseFirestore.instance
            .collection('token')
            .doc(uid)
            .set({
          'fcmToken': token,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        print('DeviceTokenService: token associato all\'utente $uid dopo login');
      } catch (e) {
        print('DeviceTokenService: errore attachTokenToUserAfterLogin: $e');
      }
    } else {
      await _updateToken();
      final newToken = await getLocalToken();
      if (newToken != null) {
        await attachTokenToUserAfterLogin();
      } else {
        print('DeviceTokenService: nessun token disponibile da associare dopo login');
      }
    }
  }

  /// Chiamare al logout per rimuovere l'associazione token -> utente
  Future<void> detachTokenOnLogout() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      try {
        await FirebaseFirestore.instance
            .collection('token')
            .doc(uid)
            .set({'fcmToken': FieldValue.delete()}, SetOptions(merge: true));

        print('DeviceTokenService: token rimosso da Firestore per $uid');
      } catch (e) {
        print('DeviceTokenService: errore detachTokenOnLogout: $e');
      }
    }

    await _saveTokenLocally(null);
  }
}
