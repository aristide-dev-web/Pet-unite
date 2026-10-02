import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/sitter_model.dart';
import '../models/booking_model.dart';

class AvailabilityService {
  /// Genera gli slot di orario disponibili per un determinato giorno e servizio.
  static List<TimeOfDay> getAvailableSlots({
    required SitterProfile sitter,
    required DateTime date,
    required int durationMinutes,
    String? serviceName,
  }) {
    List<TimeOfDay> availableSlots = [];
    
    // ✅ NOME ESATTO: "Pensione Pet Stop"
    bool isPensione = serviceName != null && 
        (serviceName.contains('Pensione Pet Stop') || serviceName.toLowerCase().contains('pensione'));

    for (int h = 0; h < 24; h++) {
      for (int m = 0; m < 60; m += 30) {
        TimeOfDay slot = TimeOfDay(hour: h, minute: m);
        
        if (isPensione) {
          availableSlots.add(slot);
        } else {
          if (_isBlockFree(sitter.uid, date, slot, durationMinutes)) {
            availableSlots.add(slot);
          }
        }
      }
    }

    return availableSlots;
  }

  static bool isNightSlot(TimeOfDay time) {
    double timeDouble = time.hour + (time.minute / 60.0);
    return timeDouble >= 22.0 || timeDouble < 6.5;
  }

  static bool _isBlockFree(String sitterUid, DateTime date, TimeOfDay start, int duration) {
    if (!Hive.isBoxOpen('bookings_box')) {
      return true; 
    }

    final box = Hive.box<PetBooking>('bookings_box');
    
    DateTime blockStart = DateTime(date.year, date.month, date.day, start.hour, start.minute);
    DateTime blockEnd = blockStart.add(Duration(minutes: duration));

    for (var b in box.values) {
      if (b.sitterId != sitterUid || b.status != BookingStatus.accepted) continue;

      // ✅ SE LA PRENOTAZIONE ESISTENTE È UNA PENSIONE, non blocca i singoli slot orari
      if (b.serviceType.contains('Pensione Pet Stop') || b.serviceType.toLowerCase().contains('pensione')) {
        continue;
      }

      final bIn = b.checkInTime.split(':');
      final bOut = b.checkOutTime.split(':');
      
      if (bIn.length < 2 || bOut.length < 2) continue;

      DateTime existingStart = DateTime(b.startDate.year, b.startDate.month, b.startDate.day, 
          int.parse(bIn[0]), int.parse(bIn[1]));
      DateTime existingEnd = DateTime(b.endDate.year, b.endDate.month, b.endDate.day, 
          int.parse(bOut[0]), int.parse(bOut[1]));

      if (blockStart.isBefore(existingEnd) && blockEnd.isAfter(existingStart)) {
        return false;
      }
    }

    return true;
  }
}
