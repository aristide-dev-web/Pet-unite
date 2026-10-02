import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:petping/notific.dart';
import 'package:petping/b_homes/c_datianimale/diariopet/calendario/notifiche_calendario.dart';
import 'package:easy_localization/easy_localization.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});


  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    setState(() {
      _notificationsEnabled = value;
    });

    // 🔔 Aggiorna il comportamento in Notific
    // Invece di Notific.initialize();
    if (value) {
      await richiediPermessiNotifica();// Chiama la funzione corretta
    }else {
      // Nessuna disattivazione diretta, ma puoi gestirlo nel listener
      debugPrint('🔕 Notifiche disattivate via impostazioni');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('settings_label_push_notif'.tr())),
      body: SwitchListTile(
        title: Text('settings_notif_enable'.tr()),
        value: _notificationsEnabled,
        onChanged: _toggleNotifications,
      ),
    );
  }
}