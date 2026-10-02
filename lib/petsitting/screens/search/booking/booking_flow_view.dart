import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:petping/petsitting/models/sitter_model.dart';
import '../components/sections/sitter_ui_helpers.dart';
import 'steps/step_pet_selection.dart';
import 'steps/step_service_selection.dart';
import 'steps/step_calendar_selection.dart';
import 'steps/step_time_and_pets.dart';
import 'components/booking_summary_step.dart';
import 'package:petping/b_homes/c_datianimale/diariopet/back_diario.dart';

class BookingFlowView extends StatelessWidget {
  final SitterProfile sitter;
  final int currentStep;
  final PageController pageController;
  
  final List<Animale> selectedPets;
  final List<String> selectedPetIds; 
  final Function(Animale) onPetToggleWithObject;
  
  final Map<String, int> manualPets;
  final Map<String, List<String>> manualBreeds; 
  final String manualSize;
  final Function(Map<String, int> pets, Map<String, List<String>> breeds, String size) onManualPetChanged; 

  final List<String> selectedServices;
  final Map<String, int> selectedDurations; 
  final Map<String, List<String>> selectedSizes; 
  final List<DateTime> selectedDays;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final List<TimeOfDay> selectedTimes;
  final int timesPerDay;
  final double totalPrice;

  final String userNotes;
  final Function(String) onUserNotesChanged;

  final String userLocation; 
  final Function(String) onLocationChanged; 

  final List<DateTime> allDays;
  final DateTime? activeDay;
  
  final Function(String) onServiceToggle;
  final Function(String, String) onSizeSelected; 
  final Function(String, int) onDurationSelected; 
  final Function({List<DateTime>? days, DateTime? start, DateTime? end, required DateTime focusedDay}) onSelectionChanged;
  final Function(TimeOfDay) onTimeToggle;
  final Function(int) onTimesPerDayChanged;
  final Function(DateTime) onActiveDayChanged;
  final Function(double, double, String, String)? onTaxiLocationChanged;
  final VoidCallback onApplyToAllDays;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onConfirm;
  
  final bool Function(DateTime) isDayOccupied;

  const BookingFlowView({
    super.key,
    required this.sitter,
    required this.currentStep,
    required this.pageController,
    required this.selectedPets,
    required this.selectedPetIds,
    required this.onPetToggleWithObject,
    required this.manualPets,
    required this.manualBreeds,
    required this.manualSize,
    required this.onManualPetChanged, 
    required this.selectedServices,
    required this.selectedDurations, 
    required this.selectedSizes, 
    required this.selectedDays,
    required this.rangeStart,
    required this.rangeEnd,
    required this.selectedTimes,
    required this.totalPrice,
    required this.timesPerDay,
    required this.userNotes,
    required this.onUserNotesChanged,
    required this.userLocation, 
    required this.onLocationChanged, 
    required this.allDays,
    required this.activeDay,
    required this.onServiceToggle,
    required this.onSizeSelected, 
    required this.onDurationSelected, 
    required this.onSelectionChanged,
    required this.onTimeToggle,
    required this.onTimesPerDayChanged,
    required this.onActiveDayChanged,
    required this.onApplyToAllDays,
    required this.onNext,
    required this.onBack,
    required this.onConfirm,
    required this.isDayOccupied, 
    this.onTaxiLocationChanged,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryIndigo = const Color(0xFF6366F1);
    final Color secondaryIndigo = const Color(0xFF818CF8);

    return Scaffold(
      backgroundColor: SitterUIHelpers.bgLight,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 40, bottom: 8, left: 10, right: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primaryIndigo, secondaryIndigo],
              ),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(25)),
              boxShadow: [
                BoxShadow(color: primaryIndigo.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                      onPressed: onBack,
                    ),
                    Text(
                      "ps_booking_title".tr().toUpperCase(),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.2),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                _buildGettoneStepBar(),
              ],
            ),
          ),
          
          Expanded(
            child: PageView(
              controller: pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                StepPetSelection(
                  selectedPetIds: selectedPetIds,
                  onPetToggle: onPetToggleWithObject,
                  manualPets: manualPets,
                  manualBreeds: manualBreeds,
                  manualSize: manualSize,
                  onManualChanged: onManualPetChanged,
                ),
                StepServiceSelection(
                  sitter: sitter,
                  selectedServices: selectedServices,
                  selectedSizes: selectedSizes, 
                  selectedDurations: selectedDurations, 
                  onServiceToggle: onServiceToggle,
                  onSizeSelected: onSizeSelected, 
                  onDurationSelected: onDurationSelected,
                  onTaxiLocationChanged: onTaxiLocationChanged,
                ),
                StepCalendarSelection(
                  selectedDays: selectedDays,
                  rangeStart: rangeStart,
                  rangeEnd: rangeEnd,
                  timesPerDay: timesPerDay,
                  userLocation: userLocation,
                  onSelectionChanged: onSelectionChanged,
                  onTimesPerDayChanged: onTimesPerDayChanged,
                  onLocationChanged: onLocationChanged,
                  isDayOccupied: isDayOccupied, 
                ),
                StepTimeAndPets(
                  sitter: sitter,
                  allDays: allDays,
                  activeDay: activeDay,
                  selectedTimes: selectedTimes,
                  selectedService: selectedServices.isNotEmpty ? selectedServices.first : null,
                  onTimeToggle: onTimeToggle,
                  onActiveDayChanged: onActiveDayChanged,
                  onApplyToAllDays: onApplyToAllDays,
                ),
                _buildStepRiepilogo(context),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildGettoneStepBar() {
    final List<Map<String, dynamic>> steps = [
      {'label': 'ps_booking_step_pet', 'icon': Icons.pets_rounded},
      {'label': 'ps_booking_step_services', 'icon': Icons.category_rounded},
      {'label': 'ps_booking_step_dates', 'icon': Icons.calendar_month_rounded},
      {'label': 'ps_booking_step_times', 'icon': Icons.schedule_rounded},
      {'label': 'ps_booking_step_summary', 'icon': Icons.assignment_outlined},
    ];

    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: steps.length,
        itemBuilder: (context, index) {
          bool isActive = currentStep == index;
          bool isCompleted = currentStep > index;
          
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isActive ? Colors.white : (isCompleted ? Colors.white.withOpacity(0.3) : Colors.transparent),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isCompleted ? Icons.check_rounded : steps[index]['icon'],
                  size: 12,
                  color: isActive ? const Color(0xFF6366F1) : Colors.white,
                ),
                const SizedBox(width: 5),
                Text(
                  steps[index]['label'].toString().tr().toUpperCase(),
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: isActive ? const Color(0xFF6366F1) : Colors.white,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatTimes(List<TimeOfDay> times) {
    if (times.isEmpty) return "ps_booking_msg_to_arrange".tr();

    List<TimeOfDay> sorted = List.from(times)
      ..sort((a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));

    List<String> ranges = [];
    TimeOfDay start = sorted.first;
    TimeOfDay last = sorted.first;

    for (int i = 1; i < sorted.length; i++) {
      TimeOfDay current = sorted[i];
      int diff = (current.hour * 60 + current.minute) - (last.hour * 60 + last.minute);

      if (diff == 30) {
        last = current;
      } else {
        ranges.add(_formatRange(start, last));
        start = current;
        last = current;
      }
    }
    ranges.add(_formatRange(start, last));

    return ranges.join("\n");
  }

  String _formatRange(TimeOfDay start, TimeOfDay last) {
    final endTotalMins = last.hour * 60 + last.minute + 30;
    final endHour = (endTotalMins ~/ 60) % 24;
    final endMin = endTotalMins % 60;

    final s = "${start.hour}:${start.minute.toString().padLeft(2, '0')}";
    final e = "${endHour.toString().padLeft(2, '0')}:${endMin.toString().padLeft(2, '0')}";

    return "🔹 ${"event_time_range".tr(args: [s, e])}";
  }

  Widget _buildStepRiepilogo(BuildContext context) {
    List<String> displayServices = [];
    for (var s in selectedServices) {
      String desc = s.tr();
      if (selectedDurations.containsKey(s)) {
        desc += " (${selectedDurations[s]} min)";
      }
      if (selectedSizes.containsKey(s) && selectedSizes[s]!.isNotEmpty) {
        desc += " [${selectedSizes[s]!.join(", ")}]";
      }
      displayServices.add(desc);
    }

    int totalDays = rangeStart != null && rangeEnd != null
        ? rangeEnd!.difference(rangeStart!).inDays + 1 
        : selectedDays.length;

    int totalPets = selectedPetIds.length;
    manualPets.values.forEach((q) => totalPets += q);

    return BookingSummaryStep(
      sitter: sitter,
      startDate: rangeStart ?? (selectedDays.isNotEmpty ? selectedDays.first : null),
      endDate: rangeEnd ?? (selectedDays.length > 1 ? selectedDays.last : null),
      service: displayServices.join("\n"),
      petCount: totalPets > 0 ? totalPets : 1,
      checkIn: selectedTimes.isNotEmpty ? selectedTimes.first : const TimeOfDay(hour: 0, minute: 0),
      checkOut: selectedTimes.isNotEmpty ? selectedTimes.last : const TimeOfDay(hour: 0, minute: 0), 
      note: "${"ps_booking_summary_days".tr()}: $totalDays | ${"cal_label_times".tr()}:\n${_formatTimes(selectedTimes)}",
      totalPrice: totalPrice,
      selectedPets: selectedPets,
      manualPetData: manualPets.isNotEmpty ? {
        'pets': manualPets,
        'breeds': manualBreeds,
        'size': manualSize,
      } : null,
      userNotes: userNotes,
      userLocation: userLocation, 
      onUserNotesChanged: onUserNotesChanged,
      onUserLocationChanged: onLocationChanged,
    );
  }

  Widget _buildBottomNav() {
    bool canProceed = false;

    if (currentStep == 0) {
      canProceed = selectedPetIds.isNotEmpty || manualPets.isNotEmpty;
    } else if (currentStep == 1) {
      if (selectedServices.isEmpty) {
        canProceed = false;
      } else {
        canProceed = selectedServices.every((s) {
          bool isGrooming = s.contains("Bagnetto") || s.contains("Toilettatura");
          if (isGrooming) {
            return selectedSizes.containsKey(s) && selectedSizes[s]!.isNotEmpty;
          }
          return true;
        });
      }
    } else if (currentStep == 2) {
      canProceed = (selectedDays.isNotEmpty || (rangeStart != null)) && userLocation.trim().isNotEmpty;
    } else if (currentStep == 3) {
      canProceed = selectedTimes.isNotEmpty || selectedServices.any((s) => s.contains("Taxi"));
    } else if (currentStep == 4) {
      canProceed = true;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 40),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))]
      ),
      child: Row(
        children: [
          if (totalPrice > 0)
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("ps_booking_total_label".tr().toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 0.5)),
                  Text("€${totalPrice.toInt()}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: SitterUIHelpers.textColor)),
                ],
              ),
            ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: canProceed ? (currentStep == 4 ? onConfirm : onNext) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: SitterUIHelpers.primaryIndigo,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade200,
              disabledForegroundColor: Colors.grey.shade400,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: canProceed ? 4 : 0,
              shadowColor: SitterUIHelpers.primaryIndigo.withOpacity(0.4)
            ),
            child: Text(currentStep == 4 ? "ps_booking_btn_send".tr().toUpperCase() : "btn_continue".tr().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1))
          ),
        ],
      ),
    );
  }
}
