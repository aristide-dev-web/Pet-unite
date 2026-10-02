import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'shared_servizi_widgets.dart';

class SpecieSelectorWidget extends StatelessWidget {
  final List<String> currentSelected;
  final Function(String, bool) onSpecieChanged;
  final String? title;

  const SpecieSelectorWidget({
    super.key,
    required this.currentSelected,
    required this.onSpecieChanged,
    this.title,
  });

  static final List<Map<String, dynamic>> opzioniSpecie = [
    {'label': 'Cani', 'key': 'ps_specie_dogs', 'emoji': '🐶', 'color': const Color(0xFFFFEDD5), 'text': const Color(0xFF9A3412)},
    {'label': 'Gatti', 'key': 'ps_specie_cats', 'emoji': '🐱', 'color': const Color(0xFFE0F2FE), 'text': const Color(0xFF075985)},
    {'label': 'Volatili', 'key': 'ps_specie_birds', 'emoji': '🐦', 'color': const Color(0xFFF0FDF4), 'text': const Color(0xFF166534)},
    {'label': 'Pesci', 'key': 'ps_specie_fish', 'emoji': '🐠', 'color': const Color(0xFFE0F2FE), 'text': const Color(0xFF075985)},
    {'label': 'Tartarughe', 'key': 'ps_specie_turtles', 'emoji': '🐢', 'color': const Color(0xFFFEE2E2), 'text': const Color(0xFF991B1B)},
    {'label': 'Rettili', 'key': 'ps_specie_reptiles', 'emoji': '🦎', 'color': const Color(0xFFF1F5F9), 'text': const Color(0xFF475569)},
    {'label': 'Insetti', 'key': 'ps_specie_insects', 'emoji': '🦋', 'color': const Color(0xFFF0FDF4), 'text': const Color(0xFF166534)},
    {'label': 'Esotici', 'key': 'ps_specie_exotic', 'emoji': '🦔', 'color': const Color(0xFFFEF9C3), 'text': const Color(0xFF854D0E)},
    {'label': 'Conigli', 'key': 'ps_specie_rabbits', 'emoji': '🐰', 'color': const Color(0xFFFCE7F3), 'text': const Color(0xFF9D174D)},
    {'label': 'Criceti', 'key': 'ps_specie_hamsters', 'emoji': '🐹', 'color': const Color(0xFFFEF9C3), 'text': const Color(0xFF854D0E)},
    {'label': 'Altro', 'key': 'ps_specie_other', 'emoji': '➕', 'color': const Color(0xFFF1F5F9), 'text': const Color(0xFF475569)},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title ?? "ps_reg_serv_specie_accepted".tr(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: SharedServiziWidgets.secondaryTextColor, letterSpacing: 1.2)),
        const SizedBox(height: 15),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: opzioniSpecie.map((s) {
              final rawLabel = s['label'] as String;
              final key = s['key'] as String;
              final isSelected = currentSelected.contains(rawLabel);
              return GestureDetector(
                onTap: () => onSpecieChanged(rawLabel, !isSelected),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? SharedServiziWidgets.indigoColor : (s['color'] as Color),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: isSelected ? [BoxShadow(color: SharedServiziWidgets.indigoColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
                  ),
                  child: Row(
                    children: [
                      Text(s['emoji'] as String, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(
                        key.tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : (s['text'] as Color),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
