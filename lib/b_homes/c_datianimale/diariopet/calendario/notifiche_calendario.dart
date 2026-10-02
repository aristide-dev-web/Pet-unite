import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

import 'evento.dart';
import '../../../../notific.dart';

FlutterLocalNotificationsPlugin get notifichePlugin => NotificationService().localNotifications;

Box get notificheBox {
  if (!Hive.isBoxOpen('notifiche_box')) {
    return Hive.box('notifiche_box');
  }
  return Hive.box('notifiche_box');
}

int _generaIdUnico(String eventoId, int index) {
  return (5000 + (eventoId.hashCode + index).abs()) % 2147483647;
}

Future<void> initNotificheCalendario() async {
  tz_data.initializeTimeZones();
  try {
    final dynamic location = await FlutterTimezone.getLocalTimezone();
    String timeZoneName = (location is String) ? location : location.name.toString();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  } catch (e) {
    tz.setLocalLocation(tz.getLocation('Europe/Rome'));
  }

  if (!Hive.isBoxOpen('notifiche_box')) {
    await Hive.openBox('notifiche_box');
  }

  await reloadSavedNotifications();
}

tz.TZDateTime _assicuraDataFutura(tz.TZDateTime start, String ripetizione, tz.TZDateTime now) {
  var target = start;
  final minFuture = now.add(const Duration(minutes: 1));
  if (target.isAfter(minFuture)) return target;

  if (ripetizione == 'daily') {
    while (target.isBefore(minFuture)) { target = target.add(const Duration(days: 1)); }
  } else if (ripetizione == 'weekly') {
    while (target.isBefore(minFuture)) { target = target.add(const Duration(days: 7)); }
  } else if (ripetizione == 'monthly') {
    while (target.isBefore(minFuture)) {
      int year = target.year;
      int month = target.month + 1;
      if (month > 12) { month = 1; year++; }
      int lastDayOfMonth = DateTime(year, month + 1, 0).day;
      int day = start.day > lastDayOfMonth ? lastDayOfMonth : start.day;
      target = tz.TZDateTime(tz.local, year, month, day, target.hour, target.minute);
    }
  }
  return target;
}

Future<void> scheduleEventNotifications(Evento evento) async {
  await cancelNotificationsForEvent(evento);

  final List<DateTime> dateNotifiche = [];
  if (evento.orari != null && evento.orari!.isNotEmpty) {
    for (final oraString in evento.orari!) {
      try {
        final parts = oraString.split(':');
        dateNotifiche.add(DateTime(evento.data.year, evento.data.month, evento.data.day, int.parse(parts[0]), int.parse(parts[1])));
      } catch (_) {}
    }
  } else {
    dateNotifiche.add(evento.data);
  }

  final now = tz.TZDateTime.now(tz.local);

  for (int i = 0; i < dateNotifiche.length; i++) {
    var scheduledTime = tz.TZDateTime.from(dateNotifiche[i], tz.local);
    final String rip = evento.ripetizione;

    if (rip != 'none' && rip != '') {
      scheduledTime = _assicuraDataFutura(scheduledTime, rip, now);
    } else {
      if (scheduledTime.isBefore(now)) continue;
    }

    final id = _generaIdUnico(evento.id, i);

    String nomePet = (evento.nomeAnimale != null && evento.nomeAnimale!.isNotEmpty) ? evento.nomeAnimale! : "tuo pet";
    String categoriaEffettiva = (evento.categoria == null || evento.categoria!.isEmpty) ? "impegni" : evento.categoria!;

    String titolo = "Promemoria per $nomePet";
    String corpo = "È il momento di: ${evento.titolo}";

    switch (categoriaEffettiva) {
      case "terapie":
        titolo = "💊 Terapia: $nomePet";
        corpo = "Ricordati la somministrazione per: ${evento.titolo}";
        break;
      case "salute":
        titolo = "🩺 Salute: $nomePet";
        break;
      case "cura":
        titolo = "✨ Cura: $nomePet";
        break;
      case "alimentazione":
        titolo = "🍴 Pappa: $nomePet";
        break;
      case "documenti":
        titolo = "📂 Documenti: $nomePet";
        break;
      case "impegni":
      default:
        titolo = "🎾 Attività: $nomePet";
        break;
    }

    final String payloadData = jsonEncode({
      'eventoId': evento.id,
      'animalId': evento.animalId ?? '',
      'type': 'calendar'
    });

    try {
      await notifichePlugin.zonedSchedule(
        id: id,
        title: titolo,
        body: corpo,
        scheduledDate: scheduledTime,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'channel_petping_calendar_v5',
            'Calendario PetUnite',
            importance: Importance.max,
            priority: Priority.high,
            fullScreenIntent: true,
            category: AndroidNotificationCategory.reminder,
            visibility: NotificationVisibility.public,
            icon: '@mipmap/ic_launcher',
            styleInformation: BigTextStyleInformation(corpo),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            interruptionLevel: InterruptionLevel.active,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: (rip == 'daily') ? DateTimeComponents.time :
        (rip == 'weekly') ? DateTimeComponents.dayOfWeekAndTime :
        (rip == 'monthly') ? DateTimeComponents.dayOfMonthAndTime : null,
        payload: payloadData,
      );

      await notificheBox.put(id, {
        'eventoId': evento.id,
        'animalId': evento.animalId ?? '',
        'data': scheduledTime.toIso8601String(),
        'ripetizione': rip,
        'titolo': titolo,
        'corpo': corpo,
        'nomePet': nomePet,
        'categoria': categoriaEffettiva,
      });
    } catch (e) {
      debugPrint("❌ Errore schedule: $e");
    }
  }
}

Future<void> cancelNotificationsForEvent(Evento evento) async {
  final box = notificheBox;
  final keysToDelete = [];
  for (final key in box.keys) {
    final data = box.get(key);
    if (data is Map && data['eventoId'] == evento.id) {
      if (key is int) {
        await notifichePlugin.cancel(id: key);
      }
      keysToDelete.add(key);
    }
  }
  for (var k in keysToDelete) await box.delete(k);
}

Future<void> reloadSavedNotifications() async {
  final box = notificheBox;
  final now = tz.TZDateTime.now(tz.local);
  final eventsBox = Hive.box('calendar_events');

  for (final key in box.keys.toList()) {
    final data = box.get(key);
    if (data == null || data is! Map || key is! int) continue;

    final String? eventoId = data['eventoId'];
    if (eventoId != null) {
      final eventoRaw = eventsBox.get(eventoId);
      
      // GARANZIA: Se l'evento è stato eliminato o il ciclo è finito, puliamo tutto
      bool daCancellare = false;
      if (eventoRaw == null) {
        daCancellare = true;
      } else {
        final evento = Evento.fromMap(Map<String, dynamic>.from(eventoRaw));
        if (evento.durataGiorni != null && evento.durataGiorni! > 0) {
          final DateTime inizio = DateTime(evento.data.year, evento.data.month, evento.data.day);
          final DateTime fine = inizio.add(Duration(days: evento.durataGiorni! - 1));
          if (DateTime.now().isAfter(fine.add(const Duration(days: 1)))) {
            daCancellare = true;
          }
        }
      }

      if (daCancellare) {
        await notifichePlugin.cancel(id: key);
        await box.delete(key);
        continue;
      }
    }

    var scheduledTime = tz.TZDateTime.parse(tz.local, data['data']);
    final String rip = data['ripetizione'] ?? 'none';

    if (scheduledTime.isBefore(now) && (rip == 'none' || rip == '')) {
      await box.delete(key);
      continue;
    }

    scheduledTime = _assicuraDataFutura(scheduledTime, rip, now);

    final String payloadData = jsonEncode({
      'eventoId': data['eventoId'],
      'animalId': data['animalId'] ?? '',
      'type': 'calendar'
    });

    try {
      await notifichePlugin.zonedSchedule(
        id: key,
        title: data['titolo'],
        body: data['corpo'],
        scheduledDate: scheduledTime,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'channel_petping_calendar_v5',
            'Calendario PetUnite',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: (rip == 'daily') ? DateTimeComponents.time :
        (rip == 'weekly') ? DateTimeComponents.dayOfWeekAndTime : null,
        payload: payloadData,
      );
    } catch (_) {}
  }
}

Future<void> richiediPermessiNotifica() async {
  if (Platform.isAndroid) {
    final android = notifichePlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();
  }
}