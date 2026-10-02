import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../components/sections/sitter_ui_helpers.dart';
import '../components/professional_calendar.dart';

class StepCalendarSelection extends StatelessWidget {
  final List<DateTime> selectedDays;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final int timesPerDay;
  final String userLocation;
  final Function({List<DateTime>? days, DateTime? start, DateTime? end, required DateTime focusedDay}) onSelectionChanged;
  final Function(int) onTimesPerDayChanged;
  final Function(String) onLocationChanged;
  final bool Function(DateTime) isDayOccupied;

  const StepCalendarSelection({
    super.key,
    required this.selectedDays,
    required this.rangeStart,
    required this.rangeEnd,
    required this.timesPerDay,
    required this.userLocation,
    required this.onSelectionChanged,
    required this.onTimesPerDayChanged,
    required this.onLocationChanged,
    required this.isDayOccupied,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(25),
      children: [
        _buildHeaderSection("booking_step_calendar_title".tr(), "booking_step_calendar_sub".tr()),
        
        const SizedBox(height: 25),
        
        // 📍 CAMPO LUOGO INTEGRATO (STILE ELEGANTE)
        _buildLocationInput(),

        const SizedBox(height: 30),

        ProfessionalCalendar(
          focusedDay: rangeStart ?? (selectedDays.isNotEmpty ? selectedDays.first : DateTime.now()), 
          selectedDays: selectedDays,
          rangeStart: rangeStart,
          rangeEnd: rangeEnd,
          onSelectionChanged: onSelectionChanged, 
          isDayOccupied: isDayOccupied,
        ),
        
        const SizedBox(height: 50),
      ],
    );
  }

  Widget _buildHeaderSection(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 5, height: 24, decoration: BoxDecoration(color: SitterUIHelpers.primaryIndigo, borderRadius: BorderRadius.circular(10))),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: SitterUIHelpers.textColor)),
          ],
        ),
        const SizedBox(height: 6),
        Text(subtitle, style: TextStyle(color: SitterUIHelpers.secondaryTextColor, fontSize: 13, fontWeight: FontWeight.w500, height: 1.4)),
      ],
    );
  }

  Widget _buildLocationInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: SitterUIHelpers.primaryIndigo.withOpacity(0.08), 
            blurRadius: 20, 
            offset: const Offset(0, 8)
          )
        ],
        border: Border.all(color: SitterUIHelpers.primaryIndigo.withOpacity(0.15), width: 2),
      ),
      child: TextField(
        onChanged: onLocationChanged,
        controller: TextEditingController(text: userLocation)..selection = TextSelection.fromPosition(TextPosition(offset: userLocation.length)),
        decoration: InputDecoration(
          hintText: "booking_calendar_location_hint".tr(),
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.w600),
          prefixIcon: Icon(Icons.location_on_rounded, color: SitterUIHelpers.primaryIndigo, size: 20),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          border: InputBorder.none,
        ),
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: SitterUIHelpers.textColor),
      ),
    );
  }
}
