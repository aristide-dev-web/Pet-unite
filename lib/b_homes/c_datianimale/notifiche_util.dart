import 'package:flutter_local_notifications/flutter_local_notifications.dart' as notif;
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:petping/main.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    show UILocalNotificationDateInterpretation;
Future<void> pianificaNotifiche(DateTime evento, String titolo, String descrizione) async {
  tzdata.initializeTimeZones(); // Inizializza i dati dei fusi orari
  tz.setLocalLocation(tz.local); // Usa il fuso orario locale del dispositivo

  final tz.TZDateTime eventoTZ = tz.TZDateTime.from(evento, tz.local);
  final tz.TZDateTime notifica24h = eventoTZ.subtract(
      const Duration(hours: 24));
  final tz.TZDateTime notifica1h = eventoTZ.subtract(const Duration(hours: 1));

  final details = notif.NotificationDetails(
    android: notif.AndroidNotificationDetails(
      'appuntamenti_channel',
      'Appuntamenti',
      channelDescription: 'Notifiche per appuntamenti',
      importance: notif.Importance.max,
      priority: notif.Priority.high,
    ),
  );
}