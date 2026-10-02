import 'package:flutter/material.dart';
import 'package:petping/petsitting/models/sitter_model.dart';
import 'sitter_ui_helpers.dart';

class SitterServicesSection extends StatelessWidget {
  final SitterProfile sitter;

  const SitterServicesSection({super.key, required this.sitter});

  @override
  Widget build(BuildContext context) {
    const Color textColor = Color(0xFF1E293B);
    const Color secondaryTextColor = Color(0xFF64748B);

    final Map<String, List<String>> categorieMapping = {
      'Servizi Offerti': ['Visita a domicilio', 'Passeggiata', 'Taxi Pet'],
      'Ospitalità': ['Pensione Pet Stop'],
      'Cura, Benessere e Salute': [
        'Bagnetto e asciugatura',
        'Toilettatura professionale',
        'Somministrazione farmaci'
      ],
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Row(
          children: [
            Container(
              width: 5,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 15),
            const Text(
              "Servizi",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          "Configurazione dei servizi e tariffe base del sitter.",
          style: TextStyle(
            color: secondaryTextColor,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),

        ...categorieMapping.entries.map((entry) {
          final String categoria = entry.key;
          final List<String> serviziInCategoria = entry.value;

          final serviziAttivi = serviziInCategoria.where((s) {
             return sitter.serviziAttivi.contains(s) || 
                    (s == 'Bagnetto e asciugatura' && sitter.serviziAttivi.any((sa) => sa.startsWith('Bagnetto'))) ||
                    (s == 'Toilettatura professionale' && sitter.serviziAttivi.any((sa) => sa.startsWith('Toilettatura')));
          }).toList();

          if (serviziAttivi.isEmpty) return const SizedBox.shrink();

          final style = _getCategoryStyle(categoria);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 40, bottom: 20, left: 5),
                child: Text(
                  categoria.toUpperCase(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: style['accent'],
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              ...serviziAttivi.map((nomeServizio) {
                return _buildServicePokeCard(nomeServizio);
              }),
            ],
          );
        }),
        const SizedBox(height: 40),
      ],
    );
  }

  Map<String, dynamic> _getCategoryStyle(String category) {
    switch (category) {
      case 'Servizi Offerti':
        return {'bg': const Color(0xFFE0F2FE), 'accent': Colors.blueAccent};
      case 'Ospitalità':
        return {'bg': const Color(0xFFF3E5F5), 'accent': Colors.purple};
      case 'Cura, Benessere e Salute':
        return {'bg': const Color(0xFFFFEBEE), 'accent': const Color(0xFFF06292)};
      default:
        return {'bg': const Color(0xFFF1F5F9), 'accent': const Color(0xFF475569)};
    }
  }

  Widget _buildServicePokeCard(String label) {
    IconData icon = Icons.pets_rounded;
    Color accentColor = SitterUIHelpers.primaryIndigo;
    Color cardBg = const Color(0xFFF1F5F9);
    String subtitle = "";

    if (label == 'Visita a domicilio') {
      icon = Icons.home_rounded;
      accentColor = const Color(0xFF0369A1);
      cardBg = const Color(0xFFE0F2FE);
      subtitle = "Controllare, nutrire e accudire il pet";
    } else if (label == 'Passeggiata') {
      icon = Icons.directions_run_rounded;
      accentColor = Colors.blueAccent;
      cardBg = const Color(0xFFE0F2FE);
      subtitle = "Uscite all'aperto per esercizio e bisogni";
    } else if (label == 'Taxi Pet') {
      icon = Icons.local_taxi_rounded;
      accentColor = Colors.blueAccent;
      cardBg = const Color(0xFFE0F2FE);
      subtitle = "Trasporto sicuro del tuo pet";
    } else if (label == 'Pensione Pet Stop') {
      icon = Icons.night_shelter_rounded;
      accentColor = Colors.purple;
      cardBg = const Color(0xFFF3E5F5);
      subtitle = "Ospitalità sicura a casa del sitter";
    } else if (label == 'Bagnetto e asciugatura') {
      icon = Icons.shower_rounded;
      accentColor = const Color(0xFFBE185D);
      cardBg = const Color(0xFFFFEBEE);
      subtitle = "Lavaggio completo con shampoo e asciugatura";
    } else if (label == 'Toilettatura professionale') {
      icon = Icons.content_cut_rounded;
      accentColor = const Color(0xFFBE185D);
      cardBg = const Color(0xFFFFEBEE);
      subtitle = "Taglio pelo e cura estetica professionale";
    } else if (label == 'Somministrazione farmaci') {
      icon = Icons.health_and_safety_rounded;
      accentColor = const Color(0xFFFB7185);
      cardBg = const Color(0xFFFFEBEE);
      subtitle = "Gestione terapie e medicinali";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: cardBg, width: 4),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accentColor, accentColor.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: accentColor, letterSpacing: 1.2)),
                      Text(subtitle, style: TextStyle(fontSize: 11, color: SitterUIHelpers.secondaryTextColor.withOpacity(0.7), fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          Padding(
            padding: const EdgeInsets.all(20),
            child: _getServiceSpecificContent(label, accentColor),
          ),
        ],
      ),
    );
  }

  Widget _getServiceSpecificContent(String label, Color accentColor) {
    if (label == 'Visita a domicilio') return _buildStandard30MinSubSection('Visita a domicilio', accentColor);
    if (label == 'Passeggiata') return _buildStandard30MinSubSection('Passeggiata', accentColor);
    if (label == 'Somministrazione farmaci') return _buildHealthSubSection(accentColor);
    if (label == 'Taxi Pet') return _buildTaxiSubSection(accentColor);
    if (label == 'Pensione Pet Stop') return _buildBoardingContent(accentColor);
    if (label == 'Bagnetto e asciugatura' || label == 'Toilettatura professionale') {
       return _buildGroomingSubSection(
          label, 
          label == 'Bagnetto e asciugatura' ? 'PRODOTTI E IGIENE' : 'ATTREZZATURA PROFESSIONALE', 
          label == 'Bagnetto e asciugatura' ? Icons.waves_rounded : Icons.content_cut_rounded, 
          sitter.serviziTaglie[label == 'Bagnetto e asciugatura' ? 'Bagnetto-Prodotti' : 'Toilettatura-Attrezzatura'] ?? [],
          sitter.serviziNote[label == 'Bagnetto e asciugatura' ? 'Bagnetto-Note' : 'Toilettatura-Note'] ?? "",
          accentColor
       );
    }
    return const SizedBox.shrink();
  }

  Widget _buildMaxAnimaliPremium(String label, Color accentColor) {
    int max = sitter.maxAnimali[label] ?? 0; // Default a 0 (Nessun limite)
    bool isUnlimited = max == 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withOpacity(0.1), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Icon(Icons.group_add_rounded, color: accentColor, size: 16),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "DISPONIBILITÀ",
                style: TextStyle(
                  fontSize: 8, 
                  fontWeight: FontWeight.w900, 
                  color: SitterUIHelpers.secondaryTextColor, 
                  letterSpacing: 1
                ),
              ),
              Text(
                isUnlimited ? "NESSUN LIMITE" : "FINO A $max POSTI",
                style: TextStyle(
                  fontSize: 12, 
                  fontWeight: FontWeight.w900, 
                  color: isUnlimited ? SitterUIHelpers.primaryIndigo : SitterUIHelpers.textColor
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBoardingContent(Color accentColor) {
    String mainService = 'Pensione Pet Stop';
    double prezzo = sitter.serviziPrezzi[mainService] ?? 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SitterUIHelpers.buildPriceRow(mainService, prezzo, unit: "/notte"),
        const Divider(height: 24),
        
        if (sitter.serviziCheckIn[mainService] != null || sitter.serviziCheckOut[mainService] != null)
          SitterUIHelpers.buildDetailRow(Icons.schedule_rounded, "Check-in/out", "${sitter.serviziCheckIn[mainService] ?? '--'} - ${sitter.serviziCheckOut[mainService] ?? '--'}"),
        
        SitterUIHelpers.buildDetailRow(Icons.directions_walk_rounded, "Passeggiate", "${sitter.boardingDailyWalks} al giorno"),
        SitterUIHelpers.buildDetailRow(Icons.access_time_rounded, "Frequenza bisogni", sitter.boardingToiletFrequency),
        
        if (sitter.boardingToiletOptions.isNotEmpty)
          SitterUIHelpers.buildDetailRow(Icons.wc_rounded, "Dove fa i bisogni", sitter.boardingToiletOptions.join(", ")),
          
        if (sitter.boardingSpecialNeeds.isNotEmpty)
          SitterUIHelpers.buildDetailRow(Icons.star_border_rounded, "Bisogni speciali", sitter.boardingSpecialNeeds.join(", ")),
          
        if (sitter.boardingHygieneDescription.isNotEmpty)
          SitterUIHelpers.buildDetailRow(Icons.clean_hands_rounded, "Igiene", sitter.boardingHygieneDescription),

        const SizedBox(height: 16),
        
        if ((sitter.serviziTaglie['$mainService-Specie'] ?? []).isNotEmpty) ...[
           const Text(
            "SPECIE ACCETTATE",
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: SitterUIHelpers.secondaryTextColor, letterSpacing: 1),
           ),
           const SizedBox(height: 12),
           Wrap(
             spacing: 8, runSpacing: 8,
             children: (sitter.serviziTaglie['$mainService-Specie'] ?? []).map((s) {
               return SitterUIHelpers.buildEmojiMiniChip(SitterUIHelpers.getEmoji(s), s);
             }).toList(),
           ),
           const SizedBox(height: 20),
        ],

        if (sitter.taglieAccettate.isNotEmpty) ...[
          SitterUIHelpers.buildSmallSubHeader("TAGLIE ACCETTATE", Icons.straighten_rounded, accentColor),
          const SizedBox(height: 12),
          SitterUIHelpers.buildDogSizesImageGrid(sitter.taglieAccettate),
          const SizedBox(height: 20),
        ],

        _buildMaxAnimaliPremium(mainService, accentColor),
        const SizedBox(height: 24),

        const Divider(height: 16, thickness: 1),
        const SizedBox(height: 8),
        const Text(
          "DETTAGLI AMBIENTE",
          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: SitterUIHelpers.secondaryTextColor, letterSpacing: 1),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: [
            SitterUIHelpers.buildMiniChip(Icons.home_rounded, sitter.tipoCasa),
            if (sitter.giardino) SitterUIHelpers.buildMiniChip(Icons.yard_rounded, "Giardino"),
            if (sitter.bambini) SitterUIHelpers.buildMiniChip(Icons.child_care_rounded, "Bambini"),
            if (sitter.altriAnimali) SitterUIHelpers.buildMiniChip(Icons.pets_rounded, "Altri pet"),
            if (sitter.ambienteSicuro) SitterUIHelpers.buildMiniChip(Icons.security_rounded, "Sicuro"),
          ],
        ),
      ],
    );
  }

  Widget _buildStandard30MinSubSection(String label, Color accentColor) {
    double prezzoDiurno = sitter.serviziPrezzi['$label-30'] ?? sitter.serviziPrezzi[label] ?? 0.0;
    double supplementoNotte = sitter.serviziNotturnoExtra[label] ?? 0.0;
    double prezzoNotturno = prezzoDiurno + supplementoNotte;
    String note = sitter.serviziNote[label] ?? "";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: SitterUIHelpers.bgLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("$label (30 min)", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
              Text("€${prezzoDiurno.toInt()}", style: TextStyle(fontWeight: FontWeight.w900, color: accentColor, fontSize: 15)),
            ],
          ),
        ),

        if (supplementoNotte > 0) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.indigo.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.nightlight_round, size: 16, color: Colors.indigo),
                    SizedBox(width: 8),
                    Text("Servizio Notturno (30 min)", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.indigo)),
                  ],
                ),
                Text("€${prezzoNotturno.toInt()}", style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.indigo, fontSize: 15)),
              ],
            ),
          ),
        ],

        const SizedBox(height: 20),
        if ((sitter.serviziTaglie['$label-Specie'] ?? []).isNotEmpty) ...[
          SitterUIHelpers.buildSmallSubHeader("SPECIE ACCETTATE", Icons.pets_rounded, accentColor),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6, runSpacing: 6,
            children: (sitter.serviziTaglie['$label-Specie'] ?? []).map((s) {
               return SitterUIHelpers.buildEmojiMiniChip(SitterUIHelpers.getEmoji(s), s);
            }).toList(),
          ),
          const SizedBox(height: 20),
        ],

        if ((sitter.serviziTaglie[label] ?? []).isNotEmpty) ...[
          SitterUIHelpers.buildSmallSubHeader("TAGLIE ACCETTATE", Icons.straighten_rounded, accentColor),
          const SizedBox(height: 12),
          SitterUIHelpers.buildDogSizesImageGrid(sitter.serviziTaglie[label] ?? []),
          const SizedBox(height: 20),
        ],

        _buildMaxAnimaliPremium(label, accentColor),
        const SizedBox(height: 20),

        if (note.isNotEmpty) ...[
          SitterUIHelpers.buildSmallSubHeader("NOTE E SPECIALIZZAZIONI", Icons.edit_note_rounded, SitterUIHelpers.secondaryTextColor),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Text(note, style: const TextStyle(fontSize: 12, color: SitterUIHelpers.textColor, fontWeight: FontWeight.w500)),
          ),
        ],
      ],
    );
  }

  Widget _buildHealthSubSection(Color accentColor) {
    final String label = 'Somministrazione farmaci';
    final double prezzoDiurno = sitter.serviziPrezzi[label] ?? 0.0;
    final double supplementoNotte = sitter.serviziNotturnoExtra[label] ?? 0.0;
    final double prezzoNotturno = prezzoDiurno + supplementoNotte;
    final String note = sitter.serviziNote[label] ?? "";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accentColor.withOpacity(0.1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
              Text("€${prezzoDiurno.toInt()}", style: TextStyle(fontWeight: FontWeight.w900, color: accentColor, fontSize: 15)),
            ],
          ),
        ),
        
        if (supplementoNotte > 0) ...[
           const SizedBox(height: 8),
           Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.indigo.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.nightlight_round, size: 14, color: Colors.indigo),
                    SizedBox(width: 8),
                    Text("Tariffa Notturna", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.indigo)),
                  ],
                ),
                Text("€${prezzoNotturno.toInt()}", style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.indigo, fontSize: 15)),
              ],
            ),
          ),
        ],

        const SizedBox(height: 20),
        if ((sitter.serviziTaglie['$label-Specie'] ?? []).isNotEmpty) ...[
          SitterUIHelpers.buildSmallSubHeader("SPECIE ACCETTATE", Icons.pets_rounded, accentColor),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6, runSpacing: 6,
            children: (sitter.serviziTaglie['$label-Specie'] ?? []).map((s) {
               return SitterUIHelpers.buildEmojiMiniChip(SitterUIHelpers.getEmoji(s), s);
            }).toList(),
          ),
          const SizedBox(height: 20),
        ],

        if ((sitter.serviziTaglie[label] ?? []).isNotEmpty) ...[
          SitterUIHelpers.buildSmallSubHeader("TAGLIE ACCETTATE", Icons.straighten_rounded, accentColor),
          const SizedBox(height: 12),
          SitterUIHelpers.buildDogSizesImageGrid(sitter.serviziTaglie[label] ?? []),
          const SizedBox(height: 20),
        ],

        _buildMaxAnimaliPremium(label, accentColor),
        const SizedBox(height: 20),

        if (note.isNotEmpty) ...[
          SitterUIHelpers.buildSmallSubHeader("NOTE E SPECIALIZZAZIONI", Icons.edit_note_rounded, SitterUIHelpers.secondaryTextColor),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Text(note, style: const TextStyle(fontSize: 12, color: SitterUIHelpers.textColor, fontWeight: FontWeight.w500)),
          ),
        ],
      ],
    );
  }

  Widget _buildTaxiSubSection(Color accentColor) {
    final String label = 'Taxi Pet';
    final double baseFare = sitter.taxiBaseFare;
    final double kmPrice = sitter.taxiPricePerKm;
    final double minPrice = sitter.taxiPricePerMin;
    final double nightSurchargePercent = sitter.taxiNightSurcharge;
    final String note = sitter.serviziNote[label] ?? "";

    double nightBaseFare = baseFare * (1 + nightSurchargePercent / 100);
    double nightKmPrice = kmPrice * (1 + nightSurchargePercent / 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: SitterUIHelpers.bgLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              _buildTaxiPriceRow("Tariffa Base", baseFare, nightBaseFare, nightSurchargePercent > 0, accentColor),
              const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1)),
              _buildTaxiPriceRow("Costo al Km", kmPrice, nightKmPrice, nightSurchargePercent > 0, accentColor, suffix: "/km"),
              const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Costo al minuto", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                  Text("€${minPrice.toStringAsFixed(2)}/min", style: TextStyle(fontWeight: FontWeight.w900, color: accentColor, fontSize: 15)),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        if (sitter.taxiSpecieAccettate.isNotEmpty) ...[
          SitterUIHelpers.buildSmallSubHeader("SPECIE ACCETTATE", Icons.pets_rounded, accentColor),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: sitter.taxiSpecieAccettate.map((s) {
               return SitterUIHelpers.buildEmojiMiniChip(SitterUIHelpers.getEmoji(s), s);
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],

        if ((sitter.serviziTaglie[label] ?? []).isNotEmpty) ...[
          SitterUIHelpers.buildSmallSubHeader("TAGLIE ACCETTATE", Icons.straighten_rounded, accentColor),
          const SizedBox(height: 12),
          SitterUIHelpers.buildDogSizesImageGrid(sitter.serviziTaglie[label] ?? []),
          const SizedBox(height: 24),
        ],

        _buildMaxAnimaliPremium(label, accentColor),
        const SizedBox(height: 24),

        if (note.isNotEmpty) ...[
          SitterUIHelpers.buildSmallSubHeader("NOTE E SPECIALIZZAZIONI", Icons.edit_note_rounded, SitterUIHelpers.secondaryTextColor),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Text(note, style: const TextStyle(fontSize: 12, color: SitterUIHelpers.textColor, fontWeight: FontWeight.w500, height: 1.5)),
          ),
        ],
      ],
    );
  }

  Widget _buildTaxiPriceRow(String label, double dayPrice, double nightPrice, bool hasNight, Color accentColor, {String suffix = ""}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
            Text("€${dayPrice.toStringAsFixed(2)}$suffix", style: TextStyle(fontWeight: FontWeight.w900, color: accentColor, fontSize: 15)),
          ],
        ),
        if (hasNight) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.nightlight_round, size: 12, color: Colors.indigo),
                  SizedBox(width: 6),
                  Text("Notturno", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.indigo)),
                ],
              ),
              Text("€${nightPrice.toStringAsFixed(2)}$suffix", style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.indigo, fontSize: 13)),
            ],
          ),
        ]
      ],
    );
  }

  Widget _buildGroomingSubSection(String label, String subHeader, IconData subIcon, List<String> options, String note, Color accentColor) {
    final Map<String, double> tagliePrezzi = {
      'XS': sitter.serviziPrezzi['$label-XS'] ?? 0.0,
      'S': sitter.serviziPrezzi['$label-S'] ?? 0.0,
      'M': sitter.serviziPrezzi['$label-M'] ?? 0.0,
      'L': sitter.serviziPrezzi['$label-L'] ?? 0.0,
      'XL': sitter.serviziPrezzi['$label-XL'] ?? 0.0,
    };

    bool hasAnyPrice = tagliePrezzi.values.any((v) => v > 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SitterUIHelpers.buildSmallSubHeader(subHeader, subIcon, accentColor),
        const SizedBox(height: 12),
        if (options.isEmpty) 
          const Text("Nessuna opzione specificata", style: TextStyle(fontSize: 11, color: SitterUIHelpers.secondaryTextColor, fontStyle: FontStyle.italic))
        else
          Wrap(
            spacing: 6, runSpacing: 6,
            children: options.map((opt) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(opt, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: SitterUIHelpers.textColor)),
            )).toList(),
          ),
        
        if (hasAnyPrice) ...[
          const SizedBox(height: 20),
          SitterUIHelpers.buildSmallSubHeader("TARIFFE PER TAGLIA", Icons.payments_rounded, SitterUIHelpers.accentEmerald),
          const SizedBox(height: 12),
          _buildGroomingPricesGrid(tagliePrezzi, accentColor),
        ],

        const SizedBox(height: 20),
        _buildMaxAnimaliPremium(label, accentColor),
        const SizedBox(height: 20),

        if (note.isNotEmpty) ...[
          SitterUIHelpers.buildSmallSubHeader("NOTE E SPECIALIZZAZIONI", Icons.edit_note_rounded, SitterUIHelpers.secondaryTextColor),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Text(note, style: const TextStyle(fontSize: 12, color: SitterUIHelpers.textColor, fontWeight: FontWeight.w500)),
          ),
        ],

        if ((sitter.serviziTaglie['$label-Specie'] ?? []).isNotEmpty) ...[
          const SizedBox(height: 20),
          SitterUIHelpers.buildSmallSubHeader("SPECIE ACCETTATE", Icons.pets_rounded, accentColor),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6, runSpacing: 6,
            children: (sitter.serviziTaglie['$label-Specie'] ?? []).map((s) {
               return SitterUIHelpers.buildEmojiMiniChip(SitterUIHelpers.getEmoji(s), s);
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildGroomingPricesGrid(Map<String, double> taglie, Color accentColor) {
    final Map<String, String> taglieLabel = {
      'XS': '0-5kg', 'S': '5-10kg', 'M': '10-25kg', 'L': '25-45kg', 'XL': '45kg+'
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: taglie.entries.where((e) => e.value > 0).map((entry) {
          return Container(
            width: 75,
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accentColor.withOpacity(0.1)),
            ),
            child: Column(
              children: [
                Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                Text(taglieLabel[entry.key] ?? "", style: const TextStyle(fontSize: 8, color: SitterUIHelpers.secondaryTextColor, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text("€${entry.value.toInt()}", style: TextStyle(fontWeight: FontWeight.w900, color: accentColor, fontSize: 13)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
