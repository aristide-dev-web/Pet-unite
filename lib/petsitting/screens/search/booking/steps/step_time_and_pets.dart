import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:petping/petsitting/models/sitter_model.dart';
import '../../components/sections/sitter_ui_helpers.dart';
import '../components/time_slot_grid.dart';

class StepTimeAndPets extends StatefulWidget {
  final SitterProfile sitter;
  final List<DateTime> allDays; 
  final DateTime? activeDay;    
  final List<TimeOfDay> selectedTimes;
  final String? selectedService;
  
  final Function(TimeOfDay) onTimeToggle;
  final Function(DateTime) onActiveDayChanged; 
  final VoidCallback onApplyToAllDays;         

  const StepTimeAndPets({
    super.key,
    required this.sitter,
    required this.allDays,
    required this.activeDay,
    required this.selectedTimes,
    required this.selectedService,
    required this.onTimeToggle,
    required this.onActiveDayChanged,
    required this.onApplyToAllDays,
  });

  @override
  State<StepTimeAndPets> createState() => _StepTimeAndPetsState();
}

class _StepTimeAndPetsState extends State<StepTimeAndPets> {
  String _selectedRange = 'morning'; // 'morning' o 'night'

  @override
  Widget build(BuildContext context) {
    bool showDaysHeader = widget.allDays.length > 1;

    // Controlla se il servizio selezionato ha il notturno attivo
    bool hasNightService = false;
    if (widget.selectedService != null) {
      hasNightService = widget.sitter.serviziNotturnoAttivi[widget.selectedService] ?? false;
    }

    return Column(
      children: [
        if (showDaysHeader) _buildDaysHeader(),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            children: [
              _buildHeaderSection("booking_step_time_title".tr(), showDaysHeader 
                ? "booking_step_time_sub_multi".tr()
                : "booking_step_time_sub_single".tr()),

              const SizedBox(height: 25),

              // SELETTORE MORNING / NIGHT (Visibile solo se il notturno è attivo per il servizio)
              if (hasNightService)
                _buildRangeSelector()
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.orange.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.wb_sunny_rounded, color: Colors.orange, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "booking_time_day_only".tr(),
                          style: TextStyle(color: Colors.orange.shade800, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: const Color(0xFFF1F5F9), width: 4),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionTitle(widget.activeDay != null 
                            ? "booking_time_slots_of".tr(args: [DateFormat('dd MMMM', context.locale.toString()).format(widget.activeDay!)])
                            : "booking_time_select_slots".tr()),
                          
                          if (widget.allDays.length > 1)
                            TextButton.icon(
                              onPressed: widget.onApplyToAllDays,
                              icon: const Icon(Icons.copy_all_rounded, size: 16, color: Color(0xFF6366F1)),
                              label: Text("booking_time_apply_all".tr(), style: const TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.w900, fontSize: 10)),
                              style: TextButton.styleFrom(
                                backgroundColor: const Color(0xFF6366F1).withOpacity(0.05),
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TimeSlotGrid(
                        sitter: widget.sitter,
                        date: widget.activeDay ?? DateTime.now(),
                        durationMinutes: 30,
                        selectedTimes: widget.selectedTimes,
                        serviceName: widget.selectedService,
                        onTimeToggle: widget.onTimeToggle,
                        // Passiamo il range alla grid per filtrare
                        filterRange: hasNightService ? _selectedRange : 'morning',
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRangeSelector() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Expanded(child: _buildRangeBtn("booking_time_morning".tr(), "07:00 - 21:30", Icons.wb_sunny_rounded, 'morning')),
          const SizedBox(width: 8),
          Expanded(child: _buildRangeBtn("booking_time_night".tr(), "22:00 - 06:30", Icons.nightlight_round, 'night')),
        ],
      ),
    );
  }

  Widget _buildRangeBtn(String title, String subtitle, IconData icon, String range) {
    bool isSel = _selectedRange == range;
    Color color = range == 'morning' ? Colors.orange : const Color(0xFF1E293B);

    return GestureDetector(
      onTap: () => setState(() => _selectedRange = range),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSel ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          boxShadow: isSel ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: isSel ? Colors.white : Colors.grey),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: isSel ? Colors.white : Colors.grey)),
            Text(subtitle, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8, color: isSel ? Colors.white70 : Colors.grey.shade400)),
          ],
        ),
      ),
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

  Widget _buildDaysHeader() {
    return Container(
      height: 90,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        itemCount: widget.allDays.length,
        itemBuilder: (context, index) {
          final day = widget.allDays[index];
          final bool isSelected = widget.activeDay != null && 
              day.year == widget.activeDay!.year && 
              day.month == widget.activeDay!.month && 
              day.day == widget.activeDay!.day;

          return GestureDetector(
            onTap: () => widget.onActiveDayChanged(day),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 55,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF6366F1) : Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: isSelected ? const Color(0xFF6366F1) : Colors.grey.shade200),
                boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E', context.locale.toString()).format(day).toUpperCase(),
                    style: TextStyle(color: isSelected ? Colors.white70 : Colors.grey, fontSize: 10, fontWeight: FontWeight.w900),
                  ),
                  Text(
                    "${day.day}",
                    style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(), 
      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 9, color: Colors.grey, letterSpacing: 1)
    );
  }
}
