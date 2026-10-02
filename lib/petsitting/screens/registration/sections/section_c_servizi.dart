import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'serzioni/visita_domicilio_section.dart';
import 'serzioni/pensione_section.dart';
import 'serzioni/passeggiata_section.dart';
import 'serzioni/farmaci_section.dart';
import 'serzioni/benessere_section.dart';
import 'serzioni/taxi_pet_section.dart';
import 'serzioni/restrizioni_section.dart';

class SectionCServizi extends StatefulWidget {
  final Map<String, bool> serviziAttivi;
  final Map<String, double> serviziPrezzi;
  final Map<String, int> serviziMaxAnimali;
  final Map<String, String> serviziOrari;
  final Map<String, String> serviziNote;
  final Map<String, String> serviziDurata;
  final Map<String, double> serviziWeekendExtra;
  final Map<String, bool> serviziWeekendAttivi;
  final Map<String, double> serviziNotturnoExtra;
  final Map<String, bool> serviziNotturnoAttivi;
  final Map<String, bool> serviziAsciugaturaAttivi;
  final Map<String, double> serviziTaxiPet;
  final Map<String, String> serviziCheckIn;
  final Map<String, String> serviziCheckOut;
  final Map<String, List<String>> serviziTaglie;

  final List<String> razzeEscluse;
  final List<String> comportamentiEsclusi;

  final int boardingDailyWalks;
  final List<String> boardingToiletOptions;
  final String boardingToiletFrequency;
  final String boardingHygieneDescription;
  final List<String> boardingSpecialNeeds;

  final double taxiBaseFare;
  final double taxiPricePerKm;
  final double taxiPricePerMin;
  final double taxiNightSurcharge;
  final List<String> taxiSpecieAccettate;

  final String tipoCasa;
  final bool giardino;
  final bool altriAnimali;
  final bool bambini;
  final bool ambienteSicuro;
  final List<File?> fotoCasa;
  final List<String> existingFotoCasaUrls;

  final Function(String, bool) onServizioToggled;
  final Function(String, double) onPrezzoChanged;
  final Function(String, int) onMaxAnimaliChanged;
  final Function(String, String) onOrariChanged;
  final Function(String, String) onNoteChanged;
  final Function(String, String) onDurataChanged;
  final Function(String, bool) onWeekendToggled;
  final Function(String, double) onWeekendExtraChanged;
  final Function(String, bool) onNotturnoToggled;
  final Function(String, double) onNotturnoExtraChanged;
  final Function(String, bool) onAsciugaturaToggled;
  final Function(String, double) onTaxiPetChanged;
  final Function(String, String) onCheckInChanged;
  final Function(String, String) onCheckOutChanged;
  final Function(String, String, bool) onTagliaChanged;

  final Function(String) onRazzaAggiunta;
  final Function(String) onRazzaRimossa;
  final Function(String) onComportamentoAggiunto;
  final Function(String) onComportamentoRimosso;

  final Function(int) onBoardingDailyWalksChanged;
  final Function(String, bool) onBoardingToiletOptionChanged;
  final Function(String) onBoardingToiletFrequencyChanged;
  final Function(String) onBoardingHygieneDescriptionChanged;
  final Function(String, bool) onBoardingSpecialNeedChanged;

  final Function(double) onTaxiBaseFareChanged;
  final Function(double) onTaxiPricePerKmChanged;
  final Function(double) onTaxiPricePerMinChanged;
  final Function(double) onTaxiNightSurchargeChanged;
  final Function(String, bool) onTaxiSpecieChanged;

  final Function(String) onTipoCasaChanged;
  final Function(bool) onGiardinoChanged;
  final Function(bool) onAltriAnimaliChanged;
  final Function(bool) onBambiniChanged;
  final Function(bool) onSicuroChanged;
  final Function(int, File) onFotoCasaPicked;
  final Function(int) onFotoCasaRemoved;
  final Function(int) onExistingFotoCasaRemoved;
  final Function(List<File>) onMultiFotoPicked;

  const SectionCServizi({
    super.key,
    required this.serviziAttivi,
    required this.serviziPrezzi,
    required this.serviziMaxAnimali,
    required this.serviziOrari,
    this.serviziNote = const {},
    this.serviziDurata = const {},
    this.serviziWeekendExtra = const {},
    this.serviziWeekendAttivi = const {},
    this.serviziNotturnoExtra = const {},
    required this.serviziNotturnoAttivi,
    this.serviziAsciugaturaAttivi = const {},
    this.serviziTaxiPet = const {},
    this.serviziCheckIn = const {},
    this.serviziCheckOut = const {},
    this.serviziTaglie = const {},
    required this.razzeEscluse,
    required this.comportamentiEsclusi,
    required this.boardingDailyWalks,
    required this.boardingToiletOptions,
    required this.boardingToiletFrequency,
    required this.boardingHygieneDescription,
    required this.boardingSpecialNeeds,
    required this.tipoCasa,
    required this.giardino,
    required this.altriAnimali,
    required this.bambini,
    required this.ambienteSicuro,
    required this.fotoCasa,
    required this.existingFotoCasaUrls,
    required this.onServizioToggled,
    required this.onPrezzoChanged,
    required this.onMaxAnimaliChanged,
    required this.onOrariChanged,
    required this.onNoteChanged,
    required this.onDurataChanged,
    required this.onWeekendToggled,
    required this.onWeekendExtraChanged,
    required this.onNotturnoToggled,
    required this.onNotturnoExtraChanged,
    required this.onAsciugaturaToggled,
    required this.onTaxiPetChanged,
    required this.onCheckInChanged,
    required this.onCheckOutChanged,
    required this.onTagliaChanged,
    required this.onRazzaAggiunta,
    required this.onRazzaRimossa,
    required this.onComportamentoAggiunto,
    required this.onComportamentoRimosso,
    required this.onBoardingDailyWalksChanged,
    required this.onBoardingToiletOptionChanged,
    required this.onBoardingToiletFrequencyChanged,
    required this.onBoardingHygieneDescriptionChanged,
    required this.onBoardingSpecialNeedChanged,
    required this.onTaxiBaseFareChanged,
    required this.onTaxiPricePerKmChanged,
    required this.onTaxiPricePerMinChanged,
    required this.onTaxiNightSurchargeChanged,
    required this.onTaxiSpecieChanged,
    required this.onTipoCasaChanged,
    required this.onGiardinoChanged,
    required this.onAltriAnimaliChanged,
    required this.onBambiniChanged,
    required this.onSicuroChanged,
    required this.onFotoCasaPicked,
    required this.onFotoCasaRemoved,
    required this.onExistingFotoCasaRemoved,
    required this.onMultiFotoPicked,
    required this.taxiBaseFare,
    required this.taxiPricePerKm,
    required this.taxiPricePerMin,
    required this.taxiNightSurcharge,
    required this.taxiSpecieAccettate,
  });

  @override
  State<SectionCServizi> createState() => _SectionCServiziState();
}

class _SectionCServiziState extends State<SectionCServizi> {
  final Color bgLight = const Color(0xFFF8FAFC);
  final Color textColor = const Color(0xFF1E293B);
  final Color secondaryTextColor = const Color(0xFF64748B);

  final Map<String, List<Map<String, dynamic>>> _categorie = {
    'ps_reg_cat_offered': [
      {'label': 'Visita a domicilio', 'key': 'ps_service_home_visit', 'icon': Icons.meeting_room_rounded, 'desc': 'ps_service_home_visit_desc'},
      {'label': 'Passeggiata', 'key': 'ps_service_walk', 'icon': Icons.explore_rounded, 'desc': 'ps_service_walk_desc'},
      {'label': 'Taxi Pet', 'key': 'ps_service_taxi', 'icon': Icons.local_taxi_rounded, 'desc': 'ps_service_taxi_desc'},
    ],
    'ps_reg_cat_hospitality': [
      {'label': 'Pensione Pet Stop', 'key': 'ps_service_boarding', 'icon': Icons.night_shelter_rounded, 'desc': 'ps_service_boarding_desc'}
    ],
    'ps_reg_cat_care': [
      {'label': 'Bagnetto e asciugatura', 'key': 'ps_service_bath', 'icon': Icons.shower_rounded, 'desc': 'ps_service_bath_desc'},
      {'label': 'Toilettatura professionale', 'key': 'ps_service_grooming', 'icon': Icons.content_cut_rounded, 'desc': 'ps_service_grooming_desc'},
      {'label': 'Somministrazione farmaci', 'key': 'ps_service_medicine', 'icon': Icons.health_and_safety_rounded, 'desc': 'ps_service_medicine_desc'},
    ],
  };

  @override
  Widget build(BuildContext context) {
    bool hasActiveService = widget.serviziAttivi.values.contains(true);

    return Container(
      color: bgLight,
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(),
                const SizedBox(height: 35),
                ..._categorie.entries.map((entry) => _buildCategorySection(entry.key, entry.value)),

                const SizedBox(height: 40),
                _buildLastMinuteSection(),

                const SizedBox(height: 40),
                RestrizioniSection(
                  razzeEscluse: widget.razzeEscluse,
                  comportamentiEsclusi: widget.comportamentiEsclusi,
                  onRazzaAggiunta: widget.onRazzaAggiunta,
                  onRazzaRimossa: widget.onRazzaRimossa,
                  onComportamentoAggiunto: widget.onComportamentoAggiunto,
                  onComportamentoRimosso: widget.onComportamentoRimosso,
                ),

                if (!hasActiveService) ...[
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.red.shade200, width: 2),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 24),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("ps_reg_error_no_service_title".tr(), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.red.shade900, letterSpacing: 1)),
                              const SizedBox(height: 4),
                              Text("ps_reg_error_no_service_msg".tr(), style: TextStyle(fontSize: 12, color: Colors.red.shade700, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 140),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 5, height: 30, decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(10))),
            const SizedBox(width: 15),
            Text("ps_reg_services_header".tr(), style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: textColor)),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          "ps_reg_services_sub_header".tr(),
          style: TextStyle(color: secondaryTextColor, fontSize: 15, fontWeight: FontWeight.w500, height: 1.4)
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.amber.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.timer_outlined, color: Colors.amber, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "ps_reg_services_timer_info".tr(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[900],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection(String titleKey, List<Map<String, dynamic>> servizi) {
    final style = _getCategoryStyle(titleKey);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 40, bottom: 20, left: 5),
          child: Text(titleKey.tr().toUpperCase(), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: style['accent'], letterSpacing: 1.5)),
        ),
        ...servizi.map((serv) {
          final String label = serv['label'];
          bool isAttivo = widget.serviziAttivi[label] ?? false;

          if (label == 'Visita a domicilio') {
            return VisitaDomicilioSection(
              isAttivo: isAttivo,
              serviziOrari: widget.serviziOrari,
              serviziPrezzi: widget.serviziPrezzi,
              serviziNotturnoExtra: widget.serviziNotturnoExtra,
              serviziTaglie: widget.serviziTaglie,
              serviziMaxAnimali: widget.serviziMaxAnimali,
              serviziNote: widget.serviziNote,
              serviziDurata: widget.serviziDurata,
              onServizioToggled: widget.onServizioToggled,
              onOrariChanged: widget.onOrariChanged,
              onPrezzoChanged: widget.onPrezzoChanged,
              onNotturnoExtraChanged: widget.onNotturnoExtraChanged,
              onTagliaChanged: widget.onTagliaChanged,
              onMaxAnimaliChanged: widget.onMaxAnimaliChanged,
              onNoteChanged: widget.onNoteChanged,
              onNotturnoToggled: widget.onNotturnoToggled,
              onDurataChanged: widget.onDurataChanged,
            );
          }

          if (label == 'Pensione Pet Stop') {
            return PensioneSection(
              isAttivo: isAttivo,
              serviziOrari: widget.serviziOrari,
              serviziPrezzi: widget.serviziPrezzi,
              serviziNotturnoExtra: widget.serviziNotturnoExtra,
              serviziTaglie: widget.serviziTaglie,
              serviziMaxAnimali: widget.serviziMaxAnimali,
              serviziNote: widget.serviziNote,
              serviziCheckIn: widget.serviziCheckIn,
              serviziCheckOut: widget.serviziCheckOut,
              boardingDailyWalks: widget.boardingDailyWalks,
              boardingToiletOptions: widget.boardingToiletOptions,
              boardingToiletFrequency: widget.boardingToiletFrequency,
              boardingHygieneDescription: widget.boardingHygieneDescription,
              boardingSpecialNeeds: widget.boardingSpecialNeeds,
              tipoCasa: widget.tipoCasa,
              giardino: widget.giardino,
              altriAnimali: widget.altriAnimali,
              bambini: widget.bambini,
              ambienteSicuro: widget.ambienteSicuro,
              fotoCasa: widget.fotoCasa,
              existingFotoCasaUrls: widget.existingFotoCasaUrls,
              onServizioToggled: widget.onServizioToggled,
              onOrariChanged: widget.onOrariChanged,
              onPrezzoChanged: widget.onPrezzoChanged,
              onNotturnoExtraChanged: widget.onNotturnoExtraChanged,
              onTagliaChanged: widget.onTagliaChanged,
              onMaxAnimaliChanged: widget.onMaxAnimaliChanged,
              onNoteChanged: widget.onNoteChanged,
              onNotturnoToggled: widget.onNotturnoToggled,
              onCheckInChanged: widget.onCheckInChanged,
              onCheckOutChanged: widget.onCheckOutChanged,
              onBoardingDailyWalksChanged: widget.onBoardingDailyWalksChanged,
              onBoardingToiletOptionChanged: widget.onBoardingToiletOptionChanged,
              onBoardingToiletFrequencyChanged: widget.onBoardingToiletFrequencyChanged,
              onBoardingHygieneDescriptionChanged: widget.onBoardingHygieneDescriptionChanged,
              onBoardingSpecialNeedChanged: widget.onBoardingSpecialNeedChanged,
              onTipoCasaChanged: widget.onTipoCasaChanged,
              onGiardinoChanged: widget.onGiardinoChanged,
              onAltriAnimaliChanged: widget.onAltriAnimaliChanged,
              onBambiniChanged: widget.onBambiniChanged,
              onSicuroChanged: widget.onSicuroChanged,
              onMultiFotoPicked: widget.onMultiFotoPicked,
              onFotoCasaRemoved: widget.onFotoCasaRemoved,
              onExistingFotoCasaRemoved: widget.onExistingFotoCasaRemoved,
            );
          }

          if (label == 'Passeggiata') {
            return PasseggiataSection(
              isAttivo: isAttivo,
              serviziOrari: widget.serviziOrari,
              serviziPrezzi: widget.serviziPrezzi,
              serviziNotturnoExtra: widget.serviziNotturnoExtra,
              serviziTaglie: widget.serviziTaglie,
              serviziMaxAnimali: widget.serviziMaxAnimali,
              serviziNote: widget.serviziNote,
              serviziDurata: widget.serviziDurata,
              onServizioToggled: widget.onServizioToggled,
              onOrariChanged: widget.onOrariChanged,
              onPrezzoChanged: widget.onPrezzoChanged,
              onNotturnoExtraChanged: widget.onNotturnoExtraChanged,
              onTagliaChanged: widget.onTagliaChanged,
              onMaxAnimaliChanged: widget.onMaxAnimaliChanged,
              onNoteChanged: widget.onNoteChanged,
              onNotturnoToggled: widget.onNotturnoToggled,
              onDurataChanged: widget.onDurataChanged,
            );
          }

          if (label == 'Somministrazione farmaci') {
            return FarmaciSection(
              isAttivo: isAttivo,
              serviziOrari: widget.serviziOrari,
              serviziPrezzi: widget.serviziPrezzi,
              serviziNotturnoExtra: widget.serviziNotturnoExtra,
              serviziTaglie: widget.serviziTaglie,
              serviziMaxAnimali: widget.serviziMaxAnimali,
              serviziNote: widget.serviziNote,
              onServizioToggled: widget.onServizioToggled,
              onOrariChanged: widget.onOrariChanged,
              onPrezzoChanged: widget.onPrezzoChanged,
              onNotturnoExtraChanged: widget.onNotturnoExtraChanged,
              onTagliaChanged: widget.onTagliaChanged,
              onMaxAnimaliChanged: widget.onMaxAnimaliChanged,
              onNoteChanged: widget.onNoteChanged,
              onNotturnoToggled: widget.onNotturnoToggled,
            );
          }

          if (label.contains('Bagnetto') || label.contains('Toilettatura')) {
            final String optionsKey = label == 'Bagnetto e asciugatura' ? 'Bagnetto-Prodotti' : 'Toilettatura-Attrezzatura';
            final String noteKey = label == 'Bagnetto e asciugatura' ? 'Bagnetto-Note' : 'Toilettatura-Note';

            Map<String, double> prezziTaglia = {
              'XS': widget.serviziPrezzi['$label-XS'] ?? 0.0,
              'S': widget.serviziPrezzi['$label-S'] ?? 0.0,
              'M': widget.serviziPrezzi['$label-M'] ?? 0.0,
              'L': widget.serviziPrezzi['$label-L'] ?? 0.0,
              'XL': widget.serviziPrezzi['$label-XL'] ?? 0.0,
            };

            return BenessereSection(
              label: label,
              icon: serv['icon'],
              desc: serv['desc'].toString().tr(),
              isAttivo: isAttivo,
              prezziTaglia: prezziTaglia,
              opzioniSelezionate: widget.serviziTaglie[optionsKey] ?? [],
              note: widget.serviziNote[noteKey] ?? "",
              serviziTaglie: widget.serviziTaglie,
              onServizioToggled: widget.onServizioToggled,
              onPrezzoChanged: (taglia, prezzo) => widget.onPrezzoChanged('$label-$taglia', prezzo),
              onOpzioneChanged: (opt, val) => widget.onTagliaChanged(optionsKey, opt, val),
              onNoteChanged: (val) => widget.onNoteChanged(noteKey, val),
              onTagliaChanged: widget.onTagliaChanged,
            );
          }

          if (label == 'Taxi Pet') {
            return TaxiPetSection(
              isAttivo: isAttivo,
              serviziOrari: widget.serviziOrari,
              taxiBaseFare: widget.taxiBaseFare,
              taxiPricePerKm: widget.taxiPricePerKm,
              taxiPricePerMin: widget.taxiPricePerMin,
              taxiNightSurcharge: widget.taxiNightSurcharge,
              taxiSpecieAccettate: widget.taxiSpecieAccettate,
              serviziTaglie: widget.serviziTaglie,
              serviziNotturnoExtra: widget.serviziNotturnoExtra,
              serviziMaxAnimali: widget.serviziMaxAnimali,
              serviziNote: widget.serviziNote,
              onServizioToggled: widget.onServizioToggled,
              onOrariChanged: widget.onOrariChanged,
              onTaxiBaseFareChanged: widget.onTaxiBaseFareChanged,
              onTaxiPricePerKmChanged: widget.onTaxiPricePerKmChanged,
              onTaxiPricePerMinChanged: widget.onTaxiPricePerMinChanged,
              onTaxiNightSurchargeChanged: widget.onTaxiNightSurchargeChanged,
              onTaxiSpecieChanged: widget.onTaxiSpecieChanged,
              onTagliaChanged: widget.onTagliaChanged,
              onNotturnoExtraChanged: widget.onNotturnoExtraChanged,
              onMaxAnimaliChanged: widget.onMaxAnimaliChanged,
              onNoteChanged: widget.onNoteChanged,
              onNotturnoToggled: widget.onNotturnoToggled,
            );
          }

          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildLastMinuteSection() {
    const Color orangeAccent = Color(0xFFF59E0B);
    bool isLastMinute = widget.serviziAttivi['LastMinute'] ?? false;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isLastMinute ? orangeAccent : orangeAccent.withOpacity(0.1),
          width: 4
        ),
        boxShadow: [
          BoxShadow(
            color: orangeAccent.withOpacity(isLastMinute ? 0.15 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10)
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [orangeAccent, Color(0xFFD97706)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.flash_on_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ps_reg_last_minute_title".tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          color: isLastMinute ? orangeAccent : textColor,
                          letterSpacing: 1.2
                        )
                      ),
                      Text(
                        "ps_reg_last_minute_sub".tr(),
                        style: TextStyle(
                          fontSize: 11,
                          color: secondaryTextColor.withOpacity(0.7),
                          fontWeight: FontWeight.w500
                        )
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isLastMinute,
                  activeColor: orangeAccent,
                  onChanged: (v) => widget.onServizioToggled('LastMinute', v),
                ),
              ],
            ),
            if (isLastMinute) ...[
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: orangeAccent.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: orangeAccent, size: 16),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "ps_reg_last_minute_info".tr(),
                        style: const TextStyle(fontSize: 11, color: orangeAccent, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getCategoryStyle(String categoryKey) {
    switch (categoryKey) {
      case 'ps_reg_cat_offered': return {'bg': const Color(0xFFE0F2FE), 'accent': Colors.blueAccent};
      case 'ps_reg_cat_hospitality': return {'bg': const Color(0xFFECFDF5), 'accent': const Color(0xFF10B981)}; 
      case 'ps_reg_cat_care': return {'bg': const Color(0xFFFFF1F2), 'accent': const Color(0xFFE11D48)};
      default: return {'bg': const Color(0xFFF1F5F9), 'accent': const Color(0xFF475569)};
    }
  }
}
