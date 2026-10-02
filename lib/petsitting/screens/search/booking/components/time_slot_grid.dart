import 'package:flutter/material.dart';
import '../../../../services/availability_service.dart';
import '../../../../models/sitter_model.dart';

class TimeSlotGrid extends StatelessWidget {
  final SitterProfile sitter;
  final DateTime date;
  final int durationMinutes;
  final String? serviceName;
  final List<TimeOfDay> selectedTimes;
  final Function(TimeOfDay) onTimeToggle;
  final String filterRange; // 'morning' o 'night'

  const TimeSlotGrid({
    super.key,
    required this.sitter,
    required this.date,
    required this.durationMinutes,
    required this.onTimeToggle,
    required this.filterRange,
    this.serviceName,
    this.selectedTimes = const [],
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final bool isToday = date.year == now.year && date.month == now.month && date.day == now.day;

    // 1. Prendiamo tutti gli slot disponibili dal servizio
    final allSlots = AvailabilityService.getAvailableSlots(
      sitter: sitter,
      date: date,
      durationMinutes: durationMinutes,
      serviceName: serviceName,
    );

    // 2. Filtriamo gli slot in base al range selezionato (Morning o Night) E all'orario attuale se è oggi
    final filteredSlots = allSlots.where((slot) {
      // Se è oggi, nascondiamo gli slot passati (con un margine di 30 min)
      if (isToday) {
        final slotTime = DateTime(date.year, date.month, date.day, slot.hour, slot.minute);
        if (slotTime.isBefore(now.add(const Duration(minutes: 30)))) {
          return false;
        }
      }

      if (filterRange == 'morning') {
        // Morning: 07:00 - 21:30
        double time = slot.hour + (slot.minute / 60.0);
        return time >= 7.0 && time <= 21.5;
      } else {
        // Night: 22:00 - 06:30
        return AvailabilityService.isNightSlot(slot);
      }
    }).toList();

    if (filteredSlots.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            isToday && allSlots.any((s) => (s.hour + s.minute/60) < (now.hour + now.minute/60))
                ? "Gli orari disponibili per oggi sono terminati."
                : "Nessuna fascia oraria disponibile in questa fascia.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selectedTimes.isNotEmpty) ...[
          Text(
            "${selectedTimes.length} SESSIONI SELEZIONATE",
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFF6366F1), letterSpacing: 1),
          ),
          const SizedBox(height: 10),
        ],
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 2.0,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: filteredSlots.length,
          itemBuilder: (context, index) {
            final slot = filteredSlots[index];
            final isSelected = selectedTimes.any((t) => t.hour == slot.hour && t.minute == slot.minute);
            final isNight = AvailabilityService.isNightSlot(slot);
            final primaryColor = const Color(0xFF6366F1);
            final nightColor = const Color(0xFF1E293B);

            return GestureDetector(
              onTap: () => onTimeToggle(slot),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? (isNight ? nightColor : primaryColor) 
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected 
                        ? (isNight ? nightColor : primaryColor) 
                        : Colors.grey.shade200, 
                    width: 1.5
                  ),
                  boxShadow: isSelected ? [BoxShadow(color: (isNight ? nightColor : primaryColor).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
                ),
                child: Center(
                  child: Text(
                    "${slot.hour.toString().padLeft(2, '0')}:${slot.minute.toString().padLeft(2, '0')}",
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
