import 'package:flutter/material.dart';
import 'package:petping/petsitting/models/sitter_model.dart';
import 'time_slot_grid.dart';

class BookingDetailsStep extends StatefulWidget {
  final SitterProfile sitter;
  final List<String> selectedServices;
  final TimeOfDay checkInTime;
  final TimeOfDay checkOutTime;
  final DateTime startDate;
  final DateTime endDate;
  final Function(String, bool) onServiceToggled;
  final Function(TimeOfDay) onCheckInChanged;
  final Function(TimeOfDay) onCheckOutChanged;

  const BookingDetailsStep({
    super.key,
    required this.sitter,
    required this.selectedServices,
    required this.checkInTime,
    required this.checkOutTime,
    required this.startDate,
    required this.endDate,
    required this.onServiceToggled,
    required this.onCheckInChanged,
    required this.onCheckOutChanged,
  });

  @override
  State<BookingDetailsStep> createState() => _BookingDetailsStepState();
}

class _BookingDetailsStepState extends State<BookingDetailsStep> {
  String? _currentDuration;

  @override
  void initState() {
    super.initState();
    if (widget.selectedServices.isNotEmpty) {
      String? durations = widget.sitter.serviziDurata[widget.selectedServices.first];
      if (durations != null && durations.isNotEmpty) {
        _currentDuration = durations.split(',').first;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryIndigo = const Color(0xFF6366F1);
    final Color textColor = const Color(0xFF1E293B);

    bool isTimedService = widget.selectedServices.any((s) => 
      s.toLowerCase().contains("visita") || s.toLowerCase().contains("passeggiata"));

    return ListView(
      padding: const EdgeInsets.all(25),
      children: [
        const Text("SERVIZI RICHIESTI", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.grey, letterSpacing: 1.2)),
        const SizedBox(height: 15),
        ...widget.sitter.serviziPrezzi.keys.map((service) {
          final isSelected = widget.selectedServices.contains(service);
          return _buildServiceItem(service, isSelected, primaryIndigo, textColor);
        }).toList(),

        if (isTimedService) ...[
          const SizedBox(height: 30),
          _buildDurationSelector(primaryIndigo),
        ],

        const SizedBox(height: 40),
        const Text("ORARIO DISPONIBILE", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.grey, letterSpacing: 1.2)),
        const SizedBox(height: 15),
        
        TimeSlotGrid(
          sitter: widget.sitter,
          date: widget.startDate,
          durationMinutes: int.tryParse(_currentDuration ?? "30") ?? 30,
          selectedTimes: [widget.checkInTime], // ✅ Passata lista correttamente
          serviceName: widget.selectedServices.isNotEmpty ? widget.selectedServices.first : null,
          onTimeToggle: (time) => widget.onCheckInChanged(time), // ✅ Parametro corretto
          filterRange: 'morning', // ✅ Aggiunto parametro richiesto
        ),
        
        const SizedBox(height: 50),
      ],
    );
  }

  Widget _buildDurationSelector(Color primary) {
    if (widget.selectedServices.isEmpty) return const SizedBox.shrink();
    String? durationsStr = widget.sitter.serviziDurata[widget.selectedServices.first];
    if (durationsStr == null || durationsStr.isEmpty) return const SizedBox.shrink();
    List<String> durations = durationsStr.split(',');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("DURATA SERVIZIO", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.grey, letterSpacing: 1.2)),
        const SizedBox(height: 15),
        Row(
          children: durations.map((d) {
            bool isSelected = _currentDuration == d;
            return GestureDetector(
              onTap: () => setState(() => _currentDuration = d),
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? primary : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? primary : Colors.grey.shade200),
                ),
                child: Text("$d MIN", style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildServiceItem(String service, bool isSelected, Color primary, Color text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected ? primary.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isSelected ? primary : Colors.grey.shade200, width: 2),
      ),
      child: CheckboxListTile(
        title: Text(service, style: TextStyle(fontWeight: FontWeight.w800, color: isSelected ? primary : text)),
        subtitle: Text("€${widget.sitter.serviziPrezzi[service]}/gg", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        value: isSelected,
        activeColor: primary,
        onChanged: (v) => widget.onServiceToggled(service, v ?? false),
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }
}
