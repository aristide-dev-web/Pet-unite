import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'shared_servizi_widgets.dart';

class ModalitaTrasportoWidget extends StatelessWidget {
  final List<String> currentSelected;
  final Function(String, bool) onModalitaChanged;
  final String? title;

  const ModalitaTrasportoWidget({
    super.key,
    required this.currentSelected,
    required this.onModalitaChanged,
    this.title,
  });

  static final List<Map<String, dynamic>> opzioni = [
    {'label': 'Trasportino piccolo', 'key': 'ps_reg_equip_carrier_s', 'icon': Icons.shopping_basket_rounded, 'color': Color(0xFFE0F2FE), 'text': Color(0xFF075985)},
    {'label': 'Trasportino medio', 'key': 'ps_reg_equip_carrier_m', 'icon': Icons.inventory_2_rounded, 'color': Color(0xFFE0F2FE), 'text': Color(0xFF075985)},
    {'label': 'Trasportino grande', 'key': 'ps_reg_equip_carrier_l', 'icon': Icons.all_out_rounded, 'color': Color(0xFFE0F2FE), 'text': Color(0xFF075985)},
    {'label': 'Kennel / box rigido', 'key': 'ps_reg_equip_kennel', 'icon': Icons.door_sliding_rounded, 'color': Color(0xFFF3E5F5), 'text': Color(0xFF6B21A8)},
    {'label': 'Cintura di sicurezza', 'key': 'ps_reg_equip_dog_belt', 'icon': Icons.airline_seat_recline_extra_rounded, 'color': Color(0xFFFFEDD5), 'text': Color(0xFF9A3412)},
    {'label': 'Bagagliaio con rete', 'key': 'ps_reg_equip_car_net', 'icon': Icons.grid_view_rounded, 'color': Color(0xFFDCFCE7), 'text': Color(0xFF166534)},
    {'label': 'In braccio', 'key': 'ps_reg_taxi_in_arms', 'icon': Icons.front_hand_rounded, 'color': Color(0xFFFEE2E2), 'text': Color(0xFF991B1B)},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title ?? "ps_reg_taxi_transport_mode".tr().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: SharedServiziWidgets.secondaryTextColor, letterSpacing: 1.2)),
            const SizedBox(width: 5),
            const Icon(Icons.star_rounded, color: Colors.orange, size: 12),
          ],
        ),
        const SizedBox(height: 15),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: opzioni.map((o) {
            final rawLabel = o['label'] as String;
            final key = o['key'] as String;
            final isSelected = currentSelected.contains(rawLabel);
            final color = o['color'] as Color;
            final textColor = o['text'] as Color;

            return GestureDetector(
              onTap: () => onModalitaChanged(rawLabel, !isSelected),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? SharedServiziWidgets.indigoColor : color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? SharedServiziWidgets.indigoColor : color.withOpacity(0.5),
                    width: 2,
                  ),
                  boxShadow: isSelected ? [BoxShadow(color: SharedServiziWidgets.indigoColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(o['icon'] as IconData, size: 16, color: isSelected ? Colors.white : textColor),
                    const SizedBox(width: 8),
                    Text(
                      key.tr(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? Colors.white : textColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
