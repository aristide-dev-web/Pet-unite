import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../components/sections/sitter_ui_helpers.dart';

enum CalendarSelectionMode { single, multi, range }

class ProfessionalCalendar extends StatefulWidget {
  final DateTime focusedDay;
  final List<DateTime> selectedDays;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final Function({List<DateTime>? days, DateTime? start, DateTime? end, required DateTime focusedDay}) onSelectionChanged;
  final bool Function(DateTime) isDayOccupied;

  const ProfessionalCalendar({
    super.key,
    required this.focusedDay,
    required this.selectedDays,
    required this.rangeStart,
    required this.rangeEnd,
    required this.onSelectionChanged,
    required this.isDayOccupied,
  });

  @override
  State<ProfessionalCalendar> createState() => _ProfessionalCalendarState();
}

class _ProfessionalCalendarState extends State<ProfessionalCalendar> {
  CalendarSelectionMode _mode = CalendarSelectionMode.multi;

  final Color coral = const Color(0xFFFB7185);
  final Color sky = const Color(0xFF0EA5E9);
  final Color indigo = const Color(0xFF6366F1);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✈️ SELECTOR MODALITÀ STILE "AEROPORTO" (COMPRESSO)
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: indigo.withOpacity(0.1), width: 1.5),
          ),
          child: Row(
            children: [
              _buildCompactModeBtn(CalendarSelectionMode.single, Icons.calendar_today_rounded, "SINGOLO"),
              _buildCompactModeBtn(CalendarSelectionMode.multi, Icons.grid_view_rounded, "MULTIPLE"),
              _buildCompactModeBtn(CalendarSelectionMode.range, Icons.date_range_rounded, "PERIODO"),
            ],
          ),
        ),

        const SizedBox(height: 25),

        // 📅 PANNELLO CALENDARIO PRINCIPALE
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: indigo.withOpacity(0.15), 
                blurRadius: 25, 
                offset: const Offset(0, 12)
              ),
            ],
            border: Border.all(color: indigo.withOpacity(0.2), width: 2.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(35),
            child: TableCalendar(
              firstDay: today,
              lastDay: today.add(const Duration(days: 365)),
              focusedDay: widget.focusedDay,
              locale: 'it_IT',
              startingDayOfWeek: StartingDayOfWeek.monday,
              rowHeight: 58,
              
              // Impedisce la selezione di giorni già occupati
              enabledDayPredicate: (day) => !widget.isDayOccupied(day),
              
              rangeSelectionMode: _mode == CalendarSelectionMode.range ? RangeSelectionMode.toggledOn : RangeSelectionMode.disabled,
              
              selectedDayPredicate: (day) {
                if (_mode == CalendarSelectionMode.range) return false;
                return widget.selectedDays.any((d) => isSameDay(d, day));
              },
              
              rangeStartDay: _mode == CalendarSelectionMode.range ? widget.rangeStart : null,
              rangeEndDay: _mode == CalendarSelectionMode.range ? widget.rangeEnd : null,

              onDaySelected: (selectedDay, focusedDay) {
                if (_mode == CalendarSelectionMode.range) return;
                if (widget.isDayOccupied(selectedDay)) return; // Sicurezza extra

                List<DateTime> newSelection = List.from(widget.selectedDays);
                if (_mode == CalendarSelectionMode.single) {
                  newSelection = [selectedDay];
                } else {
                  bool exists = newSelection.any((d) => isSameDay(d, selectedDay));
                  if (exists) {
                    newSelection.removeWhere((d) => isSameDay(d, selectedDay));
                  } else {
                    newSelection.add(selectedDay);
                  }
                }
                widget.onSelectionChanged(days: newSelection, focusedDay: focusedDay);
              },

              onRangeSelected: (start, end, focusedDay) {
                if (_mode == CalendarSelectionMode.range) {
                  // Se il range include un giorno occupato, potresti voler gestire l'errore qui
                  widget.onSelectionChanged(start: start, end: end, focusedDay: focusedDay);
                }
              },

              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(fontWeight: FontWeight.w900, color: indigo, fontSize: 17, letterSpacing: 0.5),
                leftChevronIcon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: indigo.withOpacity(0.08), shape: BoxShape.circle),
                  child: Icon(Icons.chevron_left_rounded, color: indigo, size: 20),
                ),
                rightChevronIcon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: indigo.withOpacity(0.08), shape: BoxShape.circle),
                  child: Icon(Icons.chevron_right_rounded, color: indigo, size: 20),
                ),
                headerPadding: const EdgeInsets.symmetric(vertical: 20),
              ),
              
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5),
                weekendStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5),
              ),

              calendarBuilders: CalendarBuilders(
                // Costruttore speciale per giorni occupati (OSCURATI)
                disabledBuilder: (context, day, focusedDay) => _buildDayItem(day, isOccupied: true),
                selectedBuilder: (context, day, focusedDay) => _buildDayItem(day, isSelected: true),
                rangeStartBuilder: (context, day, focusedDay) => _buildDayItem(day, isSelected: true),
                rangeEndBuilder: (context, day, focusedDay) => _buildDayItem(day, isSelected: true),
                withinRangeBuilder: (context, day, focusedDay) => _buildDayItem(day, isInRange: true),
                todayBuilder: (context, day, focusedDay) => _buildDayItem(day, isToday: true),
                defaultBuilder: (context, day, focusedDay) => _buildDayItem(day),
                outsideBuilder: (context, day, focusedDay) => Opacity(opacity: 0.2, child: _buildDayItem(day)),
              ),
            ),
          ),
        ),

        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildCompactModeBtn(CalendarSelectionMode mode, IconData icon, String label) {
    final isSelected = _mode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _mode = mode);
          widget.onSelectionChanged(days: [], start: null, end: null, focusedDay: widget.focusedDay);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected ? [
              BoxShadow(color: indigo.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4))
            ] : [],
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? indigo : Colors.grey, size: 18),
              const SizedBox(height: 4),
              Text(
                label, 
                style: TextStyle(
                  fontSize: 8, 
                  fontWeight: FontWeight.w900, 
                  letterSpacing: 0.5,
                  color: isSelected ? indigo : Colors.grey
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayItem(DateTime day, {bool isSelected = false, bool isInRange = false, bool isToday = false, bool isOccupied = false}) {
    Color bg = Colors.transparent;
    Color text = SitterUIHelpers.textColor;
    
    if (isOccupied) {
      bg = Colors.grey.withOpacity(0.1);
      text = Colors.grey.shade400;
    } else if (isSelected) { 
      bg = indigo; 
      text = Colors.white; 
    } else if (isInRange) { 
      bg = indigo.withOpacity(0.15); 
      text = indigo; 
    } else if (isToday) { 
      bg = sky.withOpacity(0.15); 
      text = sky; 
    }

    return Center(
      child: Container(
        width: 42, height: 42,
        decoration: BoxDecoration(
          color: bg, 
          shape: isSelected ? BoxShape.circle : BoxShape.rectangle, 
          borderRadius: isSelected ? null : BorderRadius.circular(15),
          boxShadow: isSelected ? [
            BoxShadow(color: indigo.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))
          ] : null,
          border: isOccupied ? Border.all(color: Colors.grey.withOpacity(0.2), width: 1) : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              "${day.day}", 
              style: TextStyle(
                color: text, 
                fontWeight: (isSelected || isToday) ? FontWeight.w900 : FontWeight.w800, 
                fontSize: 14,
                decoration: isOccupied ? TextDecoration.lineThrough : null,
              )
            ),
            if (isOccupied)
              Positioned(
                bottom: 6,
                child: Icon(Icons.lock_outline_rounded, size: 8, color: Colors.grey.shade400),
              ),
          ],
        ),
      ),
    );
  }
}
