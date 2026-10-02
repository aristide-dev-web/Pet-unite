import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'serzioni/shared_servizi_widgets.dart';

class Step9Revisione extends StatelessWidget {
  final Map<String, dynamic> summaryData;
  final VoidCallback onConfirm;

  const Step9Revisione({
    super.key,
    required this.summaryData,
    required this.onConfirm,
  });

  static final List<Map<String, dynamic>> _opzioniSpecie = [
    {'label': 'Cani', 'key': 'ps_specie_dogs', 'emoji': '🐶', 'color': const Color(0xFFFFEDD5), 'text': const Color(0xFF9A3412)},
    {'label': 'Gatti', 'key': 'ps_specie_cats', 'emoji': '🐱', 'color': const Color(0xFFE0F2FE), 'text': const Color(0xFF075985)},
    {'label': 'Conigli', 'key': 'ps_specie_rabbits', 'emoji': '🐰', 'color': const Color(0xFFFCE7F3), 'text': const Color(0xFF9D174D)},
    {'label': 'Volatili', 'key': 'ps_specie_birds', 'emoji': '🐦', 'color': const Color(0xFFF0FDF4), 'text': const Color(0xFF166534)},
    {'label': 'Criceti', 'key': 'ps_specie_hamsters', 'emoji': '🐹', 'color': const Color(0xFFFEF9C3), 'text': const Color(0xFF854D0E)},
    {'label': 'Tartarughe', 'key': 'ps_specie_turtles', 'emoji': '🐢', 'color': const Color(0xFFFEE2E2), 'text': const Color(0xFF991B1B)},
    {'label': 'Altro', 'key': 'ps_specie_other', 'emoji': '➕', 'color': const Color(0xFFF1F5F9), 'text': const Color(0xFF475569)},
  ];

  static final Map<String, Map<String, dynamic>> _serviziIconMap = {
    'Visita a domicilio': {'key': 'ps_service_home_visit', 'icon': Icons.meeting_room_rounded, 'color': const Color(0xFFE0F2FE), 'accent': Colors.blueAccent},
    'Passeggiata': {'key': 'ps_service_walk', 'icon': Icons.explore_rounded, 'color': const Color(0xFFE0F2FE), 'accent': Colors.blueAccent},
    'Taxi Pet': {'key': 'ps_service_taxi', 'icon': Icons.local_taxi_rounded, 'color': const Color(0xFFE0F2FE), 'accent': Colors.blueAccent},
    'Pensione Pet Stop': {'key': 'ps_service_boarding', 'icon': Icons.night_shelter_rounded, 'color': const Color(0xFFECFDF5), 'accent': const Color(0xFF10B981)},
    'Bagnetto e asciugatura': {'key': 'ps_service_bath', 'icon': Icons.shower_rounded, 'color': const Color(0xFFFFF1F2), 'accent': const Color(0xFFE11D48)},
    'Toilettatura professionale': {'key': 'ps_service_grooming', 'icon': Icons.content_cut_rounded, 'color': const Color(0xFFFFF1F2), 'accent': const Color(0xFFE11D48)},
    'Somministrazione farmaci': {'key': 'ps_service_medicine', 'icon': Icons.health_and_safety_rounded, 'color': const Color(0xFFFFF1F2), 'accent': const Color(0xFFE11D48)},
  };

  @override
  Widget build(BuildContext context) {
    final Color indigoColor = const Color(0xFF6366F1);
    final Color bgLight = const Color(0xFFF8FAFC);
    final Color textColor = const Color(0xFF1E293B);
    final Color secondaryTextColor = const Color(0xFF64748B);
    final Color accentEmerald = const Color(0xFF10B981);

    String val(dynamic key) => (summaryData[key]?.toString() ?? '').isEmpty ? "ps_reg_rev_not_specified".tr() : summaryData[key].toString();

    return Container(
      color: bgLight,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(indigoColor, textColor, secondaryTextColor),
            const SizedBox(height: 35),

            _buildRevisionPokeCard(
              title: "ps_reg_rev_identity_title".tr(),
              subtitle: "ps_reg_rev_identity_sub".tr(),
              icon: Icons.person_pin_rounded,
              color: const Color(0xFFE0E7FF),
              accentColor: indigoColor,
              items: [
                "${"profile_label_firstname".tr()}: ${val('nome')} ${val('cognome')}",
                "${"profile_label_birthdate".tr()}: ${val('dataNascita')}",
                "Email: ${val('email')}",
                "${"profile_label_phones".tr()}: ${val('telefono')}",
                "${"profile_label_address".tr()}: ${val('indirizzo')}, ${val('citta')} (${val('nazione')})",
                "${"profile_label_neighborhood".tr()}: ${val('quartiere')}",
              ], 
            ),

            _buildRevisionPokeCard(
              title: "ps_reg_rev_experience_title".tr(), 
              subtitle: "ps_reg_rev_experience_sub".tr(),
              icon: Icons.history_edu_rounded,
              color: const Color(0xFFFFF1E6),
              accentColor: const Color(0xFFFFB347), 
              items: [
                "${"ps_reg_exp_title".tr()}: ${val('anniEsperienza')}",
                "${"ps_reg_radius_title".tr()}: ${summaryData['raggioKm'] == 999 ? "ps_reg_radius_no_limit".tr() : '${summaryData['raggioKm'] ?? 0} km'}",
              ],
              extraWidget: _buildSpecieBadges(summaryData['specie'] as List<String>?),
            ),

            _buildRevisionPokeCard(
              title: "ps_reg_rev_skills_title".tr(), 
              subtitle: "ps_reg_rev_skills_sub".tr(),
              icon: Icons.workspace_premium_rounded,
              color: const Color(0xFFF3E5F5),
              accentColor: Colors.purple,
              items: [],
              extraWidget: _buildSkillsGrid(
                summaryData['competenze'] is List ? List<String>.from(summaryData['competenze']) : [], 
                summaryData['certificazioni'] is List ? summaryData['certificazioni'] : []
              ),
            ),

            _buildRevisionPokeCard(
              title: "ps_reg_rev_special_title".tr(), 
              subtitle: "ps_reg_rev_special_sub".tr(),
              icon: Icons.star_rounded,
              color: const Color(0xFFFCE7F3),
              accentColor: const Color(0xFFF06292),
              items: [
                "${"ps_reg_special_needs_title".tr()}: ${summaryData['bisogniSpeciali'] == true ? '✅ ${"ps_reg_rev_available".tr()}' : '❌ ${"ps_reg_rev_not_available".tr()}'}",
                "${"ps_reg_med_admin_title".tr()}: ${summaryData['somministrazioneFarmaci'] == true ? '✅ ${"ps_reg_rev_available".tr()}' : '❌ ${"ps_reg_rev_not_available".tr()}'}",
                "${"ps_reg_behavior_mgmt_title".tr()}: ${summaryData['gestioneAnimaliDifficili'] == true ? '✅ ${"ps_reg_rev_available".tr()}' : '❌ ${"ps_reg_rev_not_available".tr()}'}",
                "${"ps_reg_last_minute_title".tr()}: ${summaryData['prenotazioneLastMinute'] == true ? '✅ ${"ps_reg_rev_accepted".tr()}' : '❌ ${"ps_reg_rev_not_accepted".tr()}'}",
              ],
            ),

            _buildServicesRevisionCard(summaryData, textColor, secondaryTextColor),

            _buildEquipmentRevisionCard(summaryData, indigoColor, textColor, secondaryTextColor),

            _buildRevisionPokeCard(
              title: "ps_reg_rev_limits_title".tr(), 
              subtitle: "ps_reg_rev_limits_sub".tr(),
              icon: Icons.gpp_maybe_rounded,
              color: const Color(0xFFF1F5F9),
              accentColor: const Color(0xFF475569),
              items: [
                "${"ps_reg_rev_excluded_breeds".tr()}: ${(summaryData['razzeEscluse'] as List<String>? ?? []).isEmpty ? "ps_reg_rev_none".tr() : (summaryData['razzeEscluse'] as List<String>).join(', ')}",
                "${"ps_reg_rev_excluded_behaviors".tr()}: ${(summaryData['comportamentiEsclusi'] as List<String>? ?? []).isEmpty ? "ps_reg_rev_none".tr() : (summaryData['comportamentiEsclusi'] as List<String>).join(', ')}",
              ], 
            ),

            _buildRevisionPokeCard(
              title: "ps_reg_rev_home_title".tr(), 
              subtitle: "ps_reg_rev_home_sub".tr(),
              icon: Icons.home_work_rounded,
              color: const Color(0xFFE0F2FE),
              accentColor: Colors.blueAccent,
              items: [
                "${"ps_reg_rev_home_type".tr()}: ${val('tipoCasa')}",
                "${"ps_reg_rev_garden".tr()}: ${summaryData['giardino'] == true ? "yes".tr() : "no".tr()}",
                "${"ps_reg_rev_other_pets".tr()}: ${summaryData['altriAnimali'] == true ? "yes".tr() : "no".tr()}",
                "${"ps_reg_rev_children".tr()}: ${summaryData['bambini'] == true ? "yes".tr() : "no".tr()}",
                "${"ps_reg_rev_safe_env".tr()}: ${summaryData['ambienteSicuro'] == true ? "yes".tr() : "no".tr()}",
              ], 
              extraWidget: _buildHousePhotosPreview(summaryData['fotoCasa'] as List<File?>?, indigoColor),
            ),

            const SizedBox(height: 30),
            _buildInfoBox(accentEmerald),

            const SizedBox(height: 40),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: indigoColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: ElevatedButton(
                onPressed: onConfirm, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: indigoColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 65),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("ps_reg_rev_btn_confirm".tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                    const SizedBox(width: 15),
                    const Icon(Icons.rocket_launch_rounded, size: 24),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipmentRevisionCard(Map<String, dynamic> data, Color indigo, Color textColor, Color secondary) {
    final attrezzatura = data['attrezzatura'] as Map<String, bool>? ?? {};
    final altro = data['attrezzaturaAltro'] as String? ?? '';
    
    List<String> presenti = [];
    attrezzatura.forEach((key, value) {
      if (value) presenti.add(key);
    });

    return _buildRevisionPokeCard(
      title: "ps_reg_rev_equip_title".tr(), 
      subtitle: "ps_reg_rev_equip_sub".tr(),
      icon: Icons.inventory_2_rounded, 
      color: const Color(0xFFDCFCE7),
      accentColor: const Color(0xFF10B981),
      items: [
        if (presenti.isEmpty && altro.isEmpty) "ps_reg_rev_equip_none".tr(),
        if (presenti.isNotEmpty) "${"ps_reg_rev_equip_ready".tr()}: ${presenti.join(', ')}",
        if (altro.isNotEmpty) "Altro: $altro",
      ],
    );
  }

  Widget _buildSkillsGrid(List<String> competenze, List<dynamic> certificazioni) {
    if (competenze.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Text("ps_reg_rev_skills_none".tr(), style: const TextStyle(color: Colors.grey, fontSize: 13, fontStyle: FontStyle.italic)),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Wrap(
        spacing: 8, runSpacing: 8,
        children: competenze.map((skill) {
          bool isVerified = certificazioni.any((c) => c is Map && c['name'] == skill);
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isVerified ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isVerified ? const Color(0xFF10B981).withOpacity(0.3) : Colors.transparent),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(skill, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isVerified ? const Color(0xFF065F46) : const Color(0xFF475569))),
                if (isVerified) ...[const SizedBox(width: 6), const Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 16)],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHousePhotosPreview(List<File?>? photos, Color indigo) {
    if (photos == null || photos.isEmpty || photos.every((f) => f == null)) {
      return Padding(padding: const EdgeInsets.only(top: 15), child: Text("ps_reg_rev_house_photos_none".tr(), style: const TextStyle(color: Colors.grey, fontSize: 13)));
    }
    final validPhotos = photos.whereType<File>().toList();
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: SizedBox(
        height: 90,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: validPhotos.length,
          separatorBuilder: (context, index) => const SizedBox(width: 12),
          itemBuilder: (context, index) => Container(
            width: 90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white, width: 2),
              image: DecorationImage(image: FileImage(validPhotos[index]), fit: BoxFit.cover),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(Color indigoColor, Color textColor, Color secondaryTextColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 5, height: 30, decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(10))),
            const SizedBox(width: 15),
            Text("ps_reg_rev_header".tr(), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
          ],
        ),
        const SizedBox(height: 8),
        Text("ps_reg_rev_header_sub".tr(), style: TextStyle(color: secondaryTextColor, fontSize: 15, fontWeight: FontWeight.w500, height: 1.4)),
      ],
    );
  }

  Widget _buildServicesRevisionCard(Map<String, dynamic> data, Color textColor, Color secondary) {
    final servizi = data['servizi'] as Map<String, bool>? ?? {};
    final prezzi = data['serviziPrezzi'] as Map<String, double>? ?? {};
    final taglie = data['serviziTaglie'] as Map<String, List<String>>? ?? {};
    List<Widget> serviceWidgets = [];

    servizi.forEach((label, attivo) {
      if (attivo && label != 'LastMinute') {
        final config = _serviziIconMap[label] ?? {'key': 'ps_service_default', 'icon': Icons.star_rounded, 'color': const Color(0xFFF1F5F9), 'accent': const Color(0xFF475569)};
        final String sKey = config['key'];
        final IconData sIcon = config['icon'];
        final Color sColor = config['color'];
        final Color sAccent = config['accent'];

        List<String> details = [];
        
        if (label == 'Taxi Pet') {
          details.add("${"ps_reg_taxi_base".tr()}: ${data['taxiBaseFare'] ?? 0}€ | Km: ${data['taxiPricePerKm'] ?? 0}€");
        } else if (label == 'Visita a domicilio' || label == 'Passeggiata') {
          for (var d in ['30', '45', '60']) {
            double p = prezzi['$label-$d'] ?? 0.0;
            if (p > 0) details.add("$d min: $p€");
          }
        } else if (label.contains('Bagnetto') || label.contains('Toilettatura')) {
          for (var t in ['XS', 'S', 'M', 'L', 'XL']) {
            double p = prezzi['$label-$t'] ?? 0.0;
            if (p > 0) details.add("$t: $p€");
          }
        } else {
          double p = prezzi[label] ?? 0.0;
          if (p > 0) details.add("${"ps_reg_rev_fare".tr()}: $p€");
        }

        serviceWidgets.add(Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white, 
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: sColor, width: 2),
            boxShadow: [BoxShadow(color: sAccent.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: sColor.withOpacity(0.5), borderRadius: BorderRadius.circular(14)),
                child: Icon(sIcon, color: sAccent, size: 20),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sKey.tr(), style: TextStyle(fontWeight: FontWeight.w900, color: textColor, fontSize: 14)),
                    if (details.isNotEmpty)
                      Padding(padding: const EdgeInsets.only(top: 4), child: Text(details.join(' | '), style: TextStyle(color: sAccent, fontSize: 12, fontWeight: FontWeight.w800))),
                    if (taglie[label] != null && taglie[label]!.isNotEmpty)
                      Padding(padding: const EdgeInsets.only(top: 2), child: Text("${"ps_reg_rev_sizes".tr()}: ${taglie[label]!.join(', ')}", style: TextStyle(color: secondary.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.w500))),
                  ],
                ),
              ),
              Icon(Icons.check_circle_rounded, color: sAccent.withOpacity(0.5), size: 20),
            ],
          ),
        ));
      }
    });

    return _buildRevisionPokeCard(
      title: "ps_reg_rev_services_title".tr(), 
      subtitle: "ps_reg_rev_services_sub".tr(),
      icon: Icons.payments_rounded, 
      color: const Color(0xFFFEF3C7), 
      accentColor: const Color(0xFFD97706), 
      items: [],
      extraWidget: serviceWidgets.isEmpty 
        ? Text("ps_reg_rev_services_none".tr(), style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)) 
        : Column(crossAxisAlignment: CrossAxisAlignment.start, children: serviceWidgets),
    );
  }

  Widget _buildSpecieBadges(List<String>? specie) {
    if (specie == null || specie.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Wrap(
        spacing: 10, runSpacing: 10,
        children: specie.map((label) {
          final opzione = _opzioniSpecie.firstWhere(
            (o) => o['label'] == label,
            orElse: () => _opzioniSpecie.last,
          );
          final emoji = opzione['emoji']!;
          final String key = opzione['key']!;
          final pastelBg = opzione['color'] as Color;
          final pastelText = opzione['text'] as Color;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: pastelBg.withOpacity(0.5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: pastelBg.withOpacity(0.8), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Text(key.tr(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: pastelText)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRevisionPokeCard({
    required String title, 
    required String subtitle,
    required IconData icon, 
    required Color color, 
    required Color accentColor,
    required List<String> items, 
    Widget? extraWidget
  }) {
    return Container(
      width: double.infinity, margin: const EdgeInsets.only(bottom: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: color, width: 4),
        boxShadow: [BoxShadow(color: accentColor.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
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
                      Text(subtitle, style: TextStyle(fontSize: 11, color: SharedServiziWidgets.secondaryTextColor.withOpacity(0.7), fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10), 
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline_rounded, size: 16, color: accentColor.withOpacity(0.4)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(item, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF334155)))),
                    ],
                  )
                )),
                if (extraWidget != null) extraWidget,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08), 
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.2))
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: color, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              "ps_reg_rev_info_box_msg".tr(),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, height: 1.4, color: Color(0xFF065F46))
            )
          ),
        ],
      ),
    );
  }
}
