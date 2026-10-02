import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'serzioni/shared_servizi_widgets.dart';

class SectionDAttrezzatura extends StatefulWidget {
  final Map<String, bool> attrezzatura;
  final TextEditingController altroController;
  final Function(String, bool) onAttrezzaturaChanged;

  const SectionDAttrezzatura({
    super.key,
    required this.attrezzatura,
    required this.altroController,
    required this.onAttrezzaturaChanged,
  });

  @override
  State<SectionDAttrezzatura> createState() => _SectionDAttrezzaturaState();
}

class _SectionDAttrezzaturaState extends State<SectionDAttrezzatura> {
  final Color bgLight = const Color(0xFFF8FAFC);
  final Color textColor = const Color(0xFF1E293B);
  final Color secondaryTextColor = const Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgLight,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 35),

            _buildCategoryPokeCard(
              title: "ps_reg_equip_transport_title".tr(),
              subtitle: "ps_reg_equip_transport_sub".tr(),
              icon: Icons.directions_car_rounded,
              color: const Color(0xFFDCFCE7), 
              accentColor: const Color(0xFF10B981), 
              items: [
                "ps_reg_equip_carrier_s",
                "ps_reg_equip_carrier_m",
                "ps_reg_equip_carrier_l",
                "ps_reg_equip_kennel",
                "ps_reg_equip_dog_seat",
                "ps_reg_equip_dog_belt",
                "ps_reg_equip_seat_cover",
                "ps_reg_equip_car_net",
                "ps_reg_equip_ramps",
              ],
            ),

            const SizedBox(height: 25),

            _buildCategoryPokeCard(
              title: "ps_reg_equip_walks_title".tr(),
              subtitle: "ps_reg_equip_walks_sub".tr(),
              icon: Icons.explore_rounded,
              color: const Color(0xFFFFF1E6), 
              accentColor: const Color(0xFFFFB347), 
              items: [
                "ps_reg_equip_harnesses",
                "ps_reg_equip_leashes",
                "ps_reg_equip_bags",
                "ps_reg_equip_water_bottle",
                "ps_reg_equip_snacks",
              ],
            ),

            const SizedBox(height: 25),

            _buildCategoryPokeCard(
              title: "ps_reg_equip_home_title".tr(),
              subtitle: "ps_reg_equip_home_sub".tr(),
              icon: Icons.home_rounded,
              color: const Color(0xFFFEF9C3), 
              accentColor: const Color(0xFFEAB308), 
              items: [
                "ps_reg_equip_bed",
                "ps_reg_equip_fence",
                "ps_reg_equip_bowls",
                "ps_reg_equip_scratcher",
                "ps_reg_equip_litter",
                "ps_reg_equip_toys",
              ],
            ),

            const SizedBox(height: 25),

            _buildAltroPokeCard(),
            
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 5, height: 30, decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(10))),
            const SizedBox(width: 15),
            Text("ps_reg_equip_header".tr(), style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: textColor)),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          "ps_reg_equip_header_sub".tr(),
          style: TextStyle(color: secondaryTextColor, fontSize: 15, fontWeight: FontWeight.w500, height: 1.4),
        ),
      ],
    );
  }

  Widget _buildCategoryPokeCard({
    required String title, 
    required String subtitle,
    required IconData icon, 
    required Color color, 
    required Color accentColor,
    required List<String> items
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: color, width: 4),
        boxShadow: [BoxShadow(color: accentColor.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [accentColor, accentColor.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: accentColor, letterSpacing: 1.2)),
                      Text(subtitle, style: TextStyle(fontSize: 11, color: secondaryTextColor.withOpacity(0.7), fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Column(
              children: items.map((key) {
                // Mostriamo la label tradotta
                bool isSelected = widget.attrezzatura[key] ?? false;
                return CheckboxListTile(
                  value: isSelected,
                  onChanged: (val) => widget.onAttrezzaturaChanged(key, val ?? false),
                  title: Text(key.tr(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isSelected ? textColor : secondaryTextColor.withOpacity(0.8))),
                  activeColor: accentColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  controlAffinity: ListTileControlAffinity.leading,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAltroPokeCard() {
    Color accentColor = const Color(0xFF6366F1); 
    Color cardBg = const Color(0xFFEEF2FF);

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: cardBg, width: 4),
        boxShadow: [BoxShadow(color: accentColor.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [accentColor, accentColor.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.more_horiz_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 15),
              Text("ps_reg_equip_other_title".tr(), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: accentColor, letterSpacing: 1.2)),
            ],
          ),
          const SizedBox(height: 25),
          SharedServiziWidgets.buildNoteField(
            controller: widget.altroController,
            onNoteChanged: (v) {}, 
            label: "ps_reg_equip_other_label".tr(),
          ),
        ],
      ),
    );
  }
}
