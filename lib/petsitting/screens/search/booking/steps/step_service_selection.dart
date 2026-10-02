import 'package:flutter/material.dart';
import 'package:petping/petsitting/models/sitter_model.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../components/sections/sitter_ui_helpers.dart';
import '../components/taxi_location_picker.dart';

class StepServiceSelection extends StatelessWidget {
  final SitterProfile sitter;
  final List<String> selectedServices;
  final Map<String, List<String>> selectedSizes; 
  final Map<String, int> selectedDurations; 
  final Function(String) onServiceToggle;
  final Function(String, String) onSizeSelected;
  final Function(String, int) onDurationSelected; 
  final Function(double, double, String, String)? onTaxiLocationChanged;

  const StepServiceSelection({
    super.key,
    required this.sitter,
    required this.selectedServices,
    required this.selectedDurations,
    required this.selectedSizes,
    required this.onServiceToggle,
    required this.onSizeSelected,
    required this.onDurationSelected,
    this.onTaxiLocationChanged,
  });

  IconData _getServiceIcon(String name) {
    String n = name.toLowerCase();
    if (n.contains("visita")) return Icons.meeting_room_rounded;
    if (n.contains("passeggiata")) return Icons.directions_run_rounded;
    if (n.contains("taxi")) return Icons.local_taxi_rounded;
    if (n.contains("pensione")) return Icons.night_shelter_rounded;
    if (n.contains("bagnetto") || n.contains("toilettatura")) return Icons.auto_awesome_rounded;
    if (n.contains("farmaci") || n.contains("salute")) return Icons.health_and_safety_rounded;
    return Icons.pets_rounded;
  }

  Color _getServiceColor(String name) {
    String n = name.toLowerCase();
    if (n.contains("visita") || n.contains("passeggiata")) return const Color(0xFF6366F1); // Indaco
    if (n.contains("taxi")) return const Color(0xFFF59E0B); // Ambra
    if (n.contains("pensione")) return const Color(0xFF8B5CF6); // Viola
    if (n.contains("igiene") || n.contains("bagnetto") || n.contains("toilettatura")) return const Color(0xFFEC4899); // Rosa
    if (n.contains("farmaci")) return const Color(0xFFEF4444); // Rosso
    return SitterUIHelpers.primaryIndigo;
  }

  String _getServiceDesc(String name) {
    String n = name.toLowerCase();
    if (n.contains("visita")) return "ps_service_home_visit_desc".tr();
    if (n.contains("passeggiata")) return "ps_service_walk_desc".tr();
    if (n.contains("taxi")) return "ps_service_taxi_desc".tr();
    if (n.contains("pensione")) return "ps_service_boarding_desc".tr();
    if (n.contains("bagnetto")) return "ps_service_bath_desc".tr();
    if (n.contains("toilettatura")) return "ps_service_grooming_desc".tr();
    if (n.contains("farmaci")) return "ps_service_medicine_desc".tr();
    return "";
  }

  String _getTranslatedServiceName(String name) {
    String n = name.toLowerCase();
    if (n.contains("visita")) return "ps_service_home_visit".tr();
    if (n.contains("passeggiata")) return "ps_service_walk".tr();
    if (n.contains("taxi")) return "ps_service_taxi".tr();
    if (n.contains("pensione")) return "ps_service_boarding".tr();
    if (n.contains("bagnetto")) return "ps_service_bath".tr();
    if (n.contains("toilettatura")) return "ps_service_grooming".tr();
    if (n.contains("farmaci")) return "ps_service_medicine".tr();
    return name;
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, List<String>> categorie = {
      "ps_reg_cat_offered".tr(): ['Visita a domicilio', 'Passeggiata', 'Taxi Pet'],
      "ps_reg_cat_hospitality".tr(): ['Pensione Pet Stop'],
      "ps_reg_cat_care".tr(): ['Bagnetto e asciugatura', 'Toilettatura professionale', 'Somministrazione farmaci'],
    };

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      children: [
        _buildModernHeader("booking_step_service_title".tr(), "booking_step_service_sub".tr()),
        const SizedBox(height: 20),
        ...categorie.entries.map((entry) {
          final categoriaServizi = sitter.serviziAttivi.where((s) => entry.value.contains(s)).toList();
          if (categoriaServizi.isEmpty) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 25, bottom: 15, left: 5),
                child: Text(entry.key.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5)),
              ),
              ...categoriaServizi.map((serviceName) => _buildChoiceServicePanel(context, serviceName)),
            ],
          );
        }).toList(),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildChoiceServicePanel(BuildContext context, String serviceName) {
    final isSelected = selectedServices.contains(serviceName);
    final color = _getServiceColor(serviceName);
    
    final isGrooming = serviceName.contains("Bagnetto") || serviceName.contains("Toilettatura");
    final isTaxi = serviceName.contains("Taxi");
    final isTimed = !isGrooming && !isTaxi && (serviceName.contains("Asilo") || serviceName.contains("Passeggiata"));
    
    final selectedSizesForThis = selectedSizes[serviceName] ?? [];
    final currentDuration = selectedDurations[serviceName] ?? 30;

    double priceDisplay = 0;
    if (isGrooming) {
      if (selectedSizesForThis.isNotEmpty) {
        for (var size in selectedSizesForThis) priceDisplay += sitter.serviziPrezzi["$serviceName-$size"] ?? 0;
      } else {
        priceDisplay = sitter.serviziPrezzi["$serviceName-XS"] ?? sitter.serviziPrezzi[serviceName] ?? 0;
      }
    } else if (isTaxi) {
      priceDisplay = sitter.taxiBaseFare;
    } else {
      priceDisplay = sitter.serviziPrezzi["$serviceName-$currentDuration"] ?? sitter.serviziPrezzi[serviceName] ?? 0;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(isSelected ? 0.2 : 0.12), 
            blurRadius: 25, 
            offset: const Offset(0, 10)
          ),
        ],
        border: Border.all(
          color: isSelected ? color : color.withOpacity(0.15), 
          width: 2.5
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => onServiceToggle(serviceName),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(_getServiceIcon(serviceName), color: color, size: 28),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getTranslatedServiceName(serviceName).toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.w900, 
                            color: color, 
                            fontSize: 13, 
                            letterSpacing: 0.5
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getServiceDesc(serviceName),
                          style: const TextStyle(
                            color: Colors.grey, 
                            fontSize: 10, 
                            height: 1.3, 
                            fontWeight: FontWeight.bold
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isTaxi ? "booking_service_calculate".tr() : "€${priceDisplay.toInt()}",
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: isSelected ? color : SitterUIHelpers.textColor)
                      ),
                      const SizedBox(height: 4),
                      Icon(
                        isSelected ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                        color: isSelected ? const Color(0xFF10B981) : color.withOpacity(0.3),
                        size: 18
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isSelected && (isGrooming || isTimed || isTaxi)) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(height: 1, thickness: 1.5, color: Color(0xFFF1F5F9)),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  if (isGrooming) _buildSubSection("booking_section_size".tr(), _buildSizeSelector(serviceName, color, selectedSizesForThis)),
                  if (isTimed) 
                    serviceName.toLowerCase().contains("passeggiata") 
                      ? _buildDurationSelector(serviceName, color, currentDuration)
                      : _buildSubSection("booking_section_duration".tr(), _buildDurationSelector(serviceName, color, currentDuration)),
                  if (isTaxi) _buildSubSection("booking_section_taxi".tr(), TaxiLocationPicker(
                    key: ValueKey('taxi_picker_${sitter.uid}'), 
                    sitter: sitter,
                    onLocationChanged: onTaxiLocationChanged ?? (km, min, from, to) {},
                  )),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModernHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 5, height: 24, decoration: BoxDecoration(color: SitterUIHelpers.primaryIndigo, borderRadius: BorderRadius.circular(10))),
            const SizedBox(width: 12),
            Text(title.toUpperCase(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: SitterUIHelpers.textColor, letterSpacing: -0.5)),
          ],
        ),
        const SizedBox(height: 6),
        Text(subtitle, style: TextStyle(color: SitterUIHelpers.secondaryTextColor, fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildSubSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 9, color: Colors.grey, letterSpacing: 1)),
        const SizedBox(height: 16),
        content,
      ],
    );
  }

  Widget _buildDurationSelector(String serviceName, Color color, int current) {
    final durations = [30, 60, 90, 120];
    return Wrap(
      spacing: 10, runSpacing: 10, alignment: WrapAlignment.center,
      children: durations.map((dur) {
        if (serviceName.toLowerCase().contains("passeggiata") && dur == 30) return const SizedBox.shrink();

        final isSel = current == dur;
        final price = sitter.serviziPrezzi["$serviceName-$dur"] ?? 0;
        if (price == 0 && dur != 30) return const SizedBox.shrink();
        return GestureDetector(
          onTap: () => onDurationSelected(serviceName, dur),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200), width: 85, padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: isSel ? color.withOpacity(0.08) : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: isSel ? color : Colors.grey.shade200, width: 2)),
            child: Column(children: [Icon(Icons.timer_outlined, size: 18, color: isSel ? color : Colors.grey), const SizedBox(height: 4), Text("$dur ${"booking_duration_unit".tr()}", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: isSel ? color : SitterUIHelpers.textColor)), Text("€${price.toInt()}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: isSel ? color : SitterUIHelpers.secondaryTextColor))]),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSizeSelector(String serviceName, Color color, List<String> currentSelectedSizes) {
    final List<String> possibleKeys = ['XS', 'S', 'M', 'L', 'XL'];
    final List<String> sizesWithPrice = possibleKeys.where((size) => (sitter.serviziPrezzi["$serviceName-$size"] ?? 0) > 0).toList();
    final Map<String, Map<String, dynamic>> taglieInfo = {'XS': {'icon': 'assets/images/xs.png', 'imgSize': 20.0}, 'S': {'icon': 'assets/images/s.png', 'imgSize': 28.0}, 'M': {'icon': 'assets/images/media.png', 'imgSize': 38.0}, 'L': {'icon': 'assets/images/grande.png', 'imgSize': 48.0}, 'XL': {'icon': 'assets/images/xl.png', 'imgSize': 46.0}};
    return Wrap(
      spacing: 8, runSpacing: 8, alignment: WrapAlignment.center,
      children: sizesWithPrice.map((key) {
        final info = taglieInfo[key]!;
        final isSel = currentSelectedSizes.contains(key);
        final price = sitter.serviziPrezzi["$serviceName-$key"] ?? 0;
        return GestureDetector(
          onTap: () => onSizeSelected(serviceName, key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200), width: 90, padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: isSel ? color.withOpacity(0.05) : Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: isSel ? color : Colors.grey.shade200, width: 2)),
            child: Column(children: [Image.asset(info['icon']!, height: (info['imgSize'] as double) * 0.7, fit: BoxFit.contain), const SizedBox(height: 4), Text(key, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: isSel ? color : SitterUIHelpers.textColor)), Text("€${price.toInt()}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: isSel ? color : SitterUIHelpers.secondaryTextColor))]),
          ),
        );
      }).toList(),
    );
  }
}
