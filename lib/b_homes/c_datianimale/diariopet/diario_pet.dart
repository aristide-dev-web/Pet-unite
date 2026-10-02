import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'back_diario.dart';
import 'vet/racolta_esami.dart';
import 'vet/dettaglio_esame.dart';
import 'vet/aggiungi_passaporto.dart';
import 'vet/a/esami_local_service.dart';
import 'vet/a/esame_model.dart';
import '../modifica_animale.dart';

class DiarioPet extends StatefulWidget {
  final String animaleId;
  final Animale? initialData;
  final ScrollController? scrollController;
  final bool isNotte;

  const DiarioPet({
    super.key,
    required this.animaleId,
    this.initialData,
    this.scrollController,
    this.isNotte = false,
  });

  static void mostraMenuOpzioni(BuildContext context, String animaleId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _MenuOpzioniDiario(animaleId: animaleId),
    );
  }

  @override
  State<DiarioPet> createState() => _DiarioPetState();
}

class _DiarioPetState extends State<DiarioPet> {

  Color _parseColor(String colorName) {
    final name = colorName.toLowerCase().trim();
    if (name.contains('bianco')) return Colors.white;
    if (name.contains('nero')) return const Color(0xFF1A1A1A);
    if (name.contains('marrone') || name.contains('cioccolato') || name.contains('bruno') || name.contains('tabacco')) return const Color(0xFF5D4037);
    if (name.contains('grigio')) return Colors.blueGrey.shade400;
    if (name.contains('fulvo') || name.contains('arancio') || name.contains('albicocca')) return const Color(0xFFE67E22);
    if (name.contains('crema') || name.contains('beige') || name.contains('sabbia')) return const Color(0xFFF5DEB3);
    if (name.contains('rosso')) return const Color(0xFFC0392B);
    if (name.contains('giallo') || name.contains('miele')) return const Color(0xFFFFD700);
    if (name.contains('rosa') || name.contains('nuvola_rosa') || name.contains('fenicottero')) return const Color(0xFFFFB2C5);
    if (name.contains('lilla') || name.contains('viola')) return const Color(0xFFE1BEE7);
    if (name.contains('azzurro') || name.contains('celeste')) return const Color(0xFFB3E5FC);
    if (name.contains('blu') || name.contains('blue')) {
      return (name.contains('scuro') || name.contains('notte')) ? const Color(0xFF1A237E) : const Color(0xFF607D8B);
    }
    if (name.contains('verde')) return const Color(0xFF27AE60);

    // Pattern e colori particolari del mantello
    if (name.contains('tigrato')) return const Color(0xFFB87333);
    if (name.contains('maculato')) return const Color(0xFFDAA520);
    if (name.contains('pezzato')) return const Color(0xFF3E2723);
    if (name.contains('tappezzato') || name.contains('merle')) return const Color(0xFF90A4AE);
    if (name.contains('tricolore')) return const Color(0xFF2E1A16);

    return Colors.blueGrey.shade200;
  }

  String _getEta(Animale a) {
    if (a.year.isEmpty) return "pet_age_nd".tr();
    try {
      final age = DateTime.now().year - int.parse(a.year);
      return age <= 0 ? "pet_age_puppy".tr() : "$age" + "pet_age_years".tr();
    } catch (_) { return "pet_age_nd".tr(); }
  }

  Widget _buildDataNascita(Animale a, Color accentColor) {
    if (a.day.isEmpty || a.month.isEmpty || a.year.isEmpty) {
      return Text("pet_birthdate_missing".tr(), style: TextStyle(color: widget.isNotte ? Colors.white70 : Colors.brown[600], fontSize: 13));
    }

    final dateStyle = TextStyle(
      fontWeight: FontWeight.w900,
      fontSize: 13,
      color: widget.isNotte ? Colors.white.withOpacity(0.9) : accentColor.withOpacity(0.9),
    );

    final separator = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Text(
        "/",
        style: TextStyle(color: accentColor.withOpacity(0.5), fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(widget.isNotte ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          if (!widget.isNotte) BoxShadow(color: accentColor.withOpacity(0.08), blurRadius: 4, offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(a.day, style: dateStyle),
          separator,
          Text(a.month, style: dateStyle),
          separator,
          Text(a.year, style: dateStyle),
        ],
      ),
    );
  }

  Widget _dataBox(String text, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(widget.isNotte ? 0.25 : 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.4), width: 1.5),
        boxShadow: [
          if (!widget.isNotte) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 14,
          color: widget.isNotte ? Colors.white : accentColor.withOpacity(0.9),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _dataSeparator(Color accentColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Text("•", style: TextStyle(color: accentColor.withOpacity(0.5), fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Color _getAdaptiveColor(Color dayColor, Color nightColor) {
    return widget.isNotte ? nightColor : dayColor;
  }

  String _getTranslatedColor(String colorName) {
    if (colorName.isEmpty) return "";
    final name = colorName.toLowerCase().trim().replaceAll(' ', '_');
    
    // Mappa dei nomi dei colori alle chiavi di traduzione
    final Map<String, String> colorKeys = {
      'nero': 'color_black',
      'bianco': 'color_white',
      'marrone': 'color_brown',
      'grigio': 'color_gray',
      'beige': 'color_beige',
      'crema': 'color_cream',
      'fulvo': 'color_fawn',
      'rosso': 'color_red',
      'arancione': 'color_orange',
      'tricolore': 'color_tricolore',
      'bicolore': 'color_bicolore',
      'pezzato': 'color_pezzato',
      'tigrato': 'color_brindle',
      'striato': 'color_striato',
      'maculato': 'color_spotted',
      'zebrato': 'color_zebrato',
      'cioccolato': 'color_cioccolato',
      'blu': 'color_blue',
      'lilla': 'color_lilla',
      'fumo': 'color_fumo',
      'argento': 'color_argento',
      'dorato': 'color_dorato',
      'sabbia': 'color_sabbia',
      'miele': 'color_miele',
      'cannella': 'color_cannella',
      'testa_di_moro': 'color_testa_moro',
      'isabella': 'color_isabella',
      'biondo': 'color_biondo',
      'azzurro': 'color_azzurro',
      'nuvola_rosa': 'color_nuvola_rosa',
      'fenicottero': 'color_fenicottero',
      'rosa_shocking': 'color_rosa_shocking',
      'galassia': 'color_galassia',
      'oro': 'color_oro',
      'neon': 'color_neon',
    };

    if (colorKeys.containsKey(name)) {
      return colorKeys[name]!.tr();
    }
    
    // Se non troviamo una corrispondenza esatta, proviamo a pulire la stringa
    // o restituiamo il nome originale formattato bene
    return colorName;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('animali').doc(widget.animaleId).snapshots(),
      builder: (context, snapshot) {
        final a = (snapshot.hasData && snapshot.data!.exists)
            ? Animale.fromFirestore(snapshot.data!)
            : widget.initialData;

        if (a == null) return const Center(child: CircularProgressIndicator(color: Colors.white));

        return _buildContent(a);
      },
    );
  }

  Widget _buildContent(Animale a) {
    final accentBirth = _getAdaptiveColor(const Color(0xFFFF5252), Colors.orangeAccent); 
    final accentFatto = _getAdaptiveColor(const Color(0xFFFFB74D), const Color(0xFFFF6B6B)); 
    final accentSguardo = _getAdaptiveColor(const Color(0xFFBA68C8), Colors.purpleAccent); 
    final accentSalute = _getAdaptiveColor(const Color(0xFF81C784), Colors.lightGreenAccent); 
    final accentDocumenti = _getAdaptiveColor(const Color(0xFF4FC3F7), Colors.cyanAccent); 

    return SingleChildScrollView(
      controller: widget.scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          const SizedBox(height: 10),
          _buildMainCard(a),
          const SizedBox(height: 25),

          Row(
            children: [
              Expanded(child: _buildMedicalFolderCard(context, widget.animaleId)),
              const SizedBox(width: 15),
              Expanded(child: _buildPassportFolderCard(context, widget.animaleId)),
            ],
          ),

          const SizedBox(height: 25),

          _buildDiarySection(
            title: "pet_section_identity_birth".tr(),
            subtitle: "pet_subtitle_origins".tr(),
            icon: Icons.auto_awesome_rounded,
            accentColor: accentBirth,
            children: [
              _diaryRow("pet_label_species_upper".tr(), a.tipo, Icons.pets, accentBirth),
              _diaryRow("pet_label_breed_upper".tr(), a.razza, Icons.category, accentBirth),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month_rounded, size: 16, color: widget.isNotte ? accentBirth : accentBirth.withOpacity(0.8)),
                    const SizedBox(width: 12),
                    Text("profile_label_birthdate_full".tr(), style: TextStyle(
                        color: widget.isNotte ? Colors.white70 : Colors.brown[600],
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                    const Spacer(),
                    _buildDataNascita(a, accentBirth),
                  ],
                ),
              ),

              _diaryRow("pet_label_current_age".tr(), _getEta(a), Icons.access_time, accentBirth),
            ],
          ),

          _buildPaletteDiary(a),

          _buildDiarySection(
            title: "pet_section_appearance".tr(),
            subtitle: "pet_subtitle_traits".tr(),
            icon: Icons.pets_rounded,
            accentColor: accentFatto,
            children: [
              _diaryRow("diary_label_size".tr(), a.taglia, Icons.straighten, accentFatto),
              _diaryRow("diary_label_coat".tr(), "${a.peloGrandezza} (${a.peloTipo})", Icons.texture, accentFatto),
              _diaryRow("diary_label_tail".tr(), "${a.codaGrandezza} (${a.codaTipo})", Icons.reorder, accentFatto),
            ],
          ),

          _buildDiarySection(
            title: "pet_section_gaze".tr(),
            subtitle: "pet_subtitle_eyes_ears".tr(),
            icon: Icons.favorite,
            accentColor: accentSguardo,
            children: [
              _diaryRow("diary_label_eyes".tr(), "${a.occhiColore} (${a.occhiForma})", Icons.remove_red_eye, accentSguardo),
              _diaryRow("diary_label_ears".tr(), "${a.orecchieTipo} (${a.orecchieGrandezza})", Icons.hearing, accentSguardo),
            ],
          ),

          _buildDiarySection(
            title: "pet_section_health".tr(),
            subtitle: "pet_subtitle_health".tr(),
            icon: Icons.health_and_safety,
            accentColor: accentSalute,
            children: [
              _diaryRow("diary_label_vaccinated".tr(), a.vaccinato, Icons.verified_user, accentSalute),
              _diaryRow("diary_label_sterilized".tr(), a.riproduttivo, Icons.favorite_border, accentSalute),
              _diaryRow("diary_label_allergic".tr(), a.allergico, Icons.warning_amber, accentSalute),
              if (a.allergico == "Sì" || a.allergico == "Yes") _diaryRow("diary_label_allergies_which".tr(), a.allergie, Icons.info_outline, accentSalute),
            ],
          ),

          _buildDiarySection(
            title: "pet_section_docs".tr(),
            subtitle: "pet_subtitle_id".tr(),
            icon: Icons.description,
            accentColor: accentDocumenti,
            children: [
              _diaryRow("diary_label_microchip".tr(), a.microchip, Icons.qr_code, accentDocumenti),
              if (a.microchip == "Sì" || a.microchip == "Yes") _diaryRow("diary_label_microchip_num".tr(), a.microchipNumero, Icons.pin, accentDocumenti),
            ],
          ),

          if (a.noteGenerali.isNotEmpty) _buildNoteSection(a.noteGenerali),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildMainCard(Animale a) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: widget.isNotte ? Colors.black.withOpacity(0.4) : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(45),
        border: Border.all(
            color: widget.isNotte ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.6),
            width: 2.5
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(widget.isNotte ? 0.3 : 0.05), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 140, height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: widget.isNotte
                        ? [Colors.purpleAccent, Colors.cyanAccent]
                        : [const Color(0xFFFFDAB9), const Color(0xFFFF7E7E)], 
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                ),
              ),
              Hero(
                tag: 'pet_image_${widget.animaleId}',
                child: CircleAvatar(
                  radius: 65,
                  backgroundColor: Colors.white,
                  backgroundImage: (a.fotoUrl != null && a.fotoUrl!.isNotEmpty) ? NetworkImage(a.fotoUrl!) : null,
                  child: (a.fotoUrl == null || a.fotoUrl!.isEmpty) ? null : null,
                ),
              ),
              Positioned(
                top: -5,
                left: -5,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (a.sesso == 'Maschio' || a.sesso == 'Male') ? Colors.blue : Colors.pink,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))
                    ],
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(
                    (a.sesso == 'Maschio' || a.sesso == 'Male') ? Icons.male : Icons.female,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                bottom: -5,
                right: -5,
                child: GestureDetector(
                  onTap: () => DiarioPet.mostraMenuOpzioni(context, widget.animaleId),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: widget.isNotte ? const Color(0xFF1A1A1A) : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))
                      ],
                      border: Border.all(
                        color: widget.isNotte ? Colors.cyanAccent.withOpacity(0.5) : const Color(0xFFFF7E7E).withOpacity(0.5),
                        width: 2
                      ),
                    ),
                    child: Icon(
                      Icons.edit_rounded,
                      size: 22,
                      color: widget.isNotte ? Colors.cyanAccent : const Color(0xFFFF7E7E),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Text(
            a.nome.toUpperCase(),
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: widget.isNotte ? Colors.white : const Color(0xFF5D4037),
              letterSpacing: 3,
              shadows: [
                Shadow(color: Colors.black.withOpacity(widget.isNotte ? 0.6 : 0.3), offset: const Offset(2, 3), blurRadius: 6),
                if (!widget.isNotte) Shadow(color: Colors.white.withOpacity(0.5), offset: const Offset(-1, -1), blurRadius: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiarySection({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required List<Widget> children
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: widget.isNotte ? Colors.black.withOpacity(0.3) : Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(35),
        border: Border.all(
            color: widget.isNotte ? accentColor.withOpacity(0.5) : accentColor.withOpacity(0.4),
            width: 2
        ),
        boxShadow: [
          BoxShadow(color: accentColor.withOpacity(widget.isNotte ? 0.15 : 0.1), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: accentColor.withOpacity(0.3), shape: BoxShape.circle),
                child: Icon(icon, color: widget.isNotte ? Colors.white : accentColor.withOpacity(0.9), size: 24),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title.toUpperCase(), style: TextStyle(
                        fontSize: 16,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w900,
                        color: widget.isNotte ? Colors.white : accentColor.withOpacity(0.9))
                    ),
                    Text(subtitle, style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: widget.isNotte ? Colors.white70 : Colors.brown[300])
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Divider(thickness: 1.5, color: Colors.white24),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _diaryRow(String label, String val, IconData rowIcon, Color accentColor) {
    if (val.isEmpty || val == "/") return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(rowIcon, size: 16, color: widget.isNotte ? accentColor : accentColor.withOpacity(0.8)),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(
              color: widget.isNotte ? Colors.white70 : Colors.brown[600],
              fontSize: 13,
              fontWeight: FontWeight.w600)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.isNotte
                  ? [accentColor.withOpacity(0.4), accentColor.withOpacity(0.1)]
                  : [accentColor.withOpacity(0.3), accentColor.withOpacity(0.1)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: accentColor.withOpacity(0.5), width: 1.5),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
              ],
            ),
            child: Text(val, style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 13,
                color: widget.isNotte ? Colors.white : accentColor.withOpacity(1.0))),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalFolderCard(BuildContext context, String animaleId) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RaccoltaEsami(animaleId: animaleId))),
      child: _folderBase("diary_btn_medical_folder".tr(), Icons.folder_shared_rounded, Colors.teal),
    );
  }

  Widget _buildPassportFolderCard(BuildContext context, String animaleId) {
    return GestureDetector(
      onTap: () async {
        final esami = await EsamiLocalService().leggiEsami(animaleId);
        final passaporto = esami.cast<Esame?>().firstWhere((e) => e?.categoria == "Passaporto", orElse: () => null);
        if (mounted) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => passaporto != null ? DettaglioEsame(esame: passaporto, animaleId: animaleId) : AggiungiPassaporto(animaleId: animaleId)));
        }
      },
      child: _folderBase("diary_btn_passport".tr(), Icons.import_contacts, Colors.indigo),
    );
  }

  Widget _folderBase(String title, IconData icon, Color baseColor) {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [baseColor.withOpacity(0.7), baseColor.withOpacity(0.9)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
        boxShadow: [
          BoxShadow(color: baseColor.withOpacity(widget.isNotte ? 0.3 : 0.5), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 36),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.2)),
        ],
      ),
    );
  }

  Widget _buildPaletteDiary(Animale a) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: widget.isNotte ? Colors.black.withOpacity(0.2) : Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: widget.isNotte
                  ? [Colors.cyanAccent, Colors.purpleAccent]
                  : [const Color(0xFFFF5252), const Color(0xFFFFB74D)], 
            ).createShader(bounds),
            child: Text("diary_label_colors".tr(), style: const TextStyle(
                fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2.2,
                color: Colors.white)),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (a.coloreDominante.isNotEmpty) _colorDiaryItem(a.coloreDominante, "diary_color_main".tr()),
              if (a.coloreSecondario.isNotEmpty) ...[const SizedBox(width: 20), _colorDiaryItem(a.coloreSecondario, "diary_color_reflections".tr())],
              if (a.coloreTerziario.isNotEmpty) ...[const SizedBox(width: 20), _colorDiaryItem(a.coloreTerziario, "diary_color_details".tr())],
            ],
          ),
        ],
      ),
    );
  }

  Widget _colorDiaryItem(String name, String label) {
    final lowerName = name.toLowerCase();
    CustomPainter? patternPainter;
    Color baseCol = _parseColor(name);

    if (lowerName.contains('tigrato')) {
      patternPainter = TigratoPainter(baseColor: baseCol);
    } else if (lowerName.contains('maculato')) {
      patternPainter = MaculatoPainter(baseColor: baseCol);
    } else if (lowerName.contains('pezzato')) {
      patternPainter = PezzatoPainter(baseColor: baseCol);
    } else if (lowerName.contains('merle') || lowerName.contains('tappezzato')) {
      patternPainter = MerlePainter(baseColor: baseCol);
    } else if (lowerName.contains('tricolore')) {
      patternPainter = TricolorePainter();
    }

    return Column(
      children: [
        Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
            color: baseCol,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(widget.isNotte ? 0.4 : 0.15), blurRadius: 8, offset: const Offset(0, 4))
            ],
          ),
          child: patternPainter != null
            ? ClipOval(child: CustomPaint(painter: patternPainter))
            : null,
        ),
        const SizedBox(height: 8),
        Text(_getTranslatedColor(name).toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: widget.isNotte ? Colors.white : Colors.black87)),
        Text(label, style: TextStyle(fontSize: 9, color: widget.isNotte ? Colors.white54 : Colors.brown[300])),
      ],
    );
  }

  Widget _buildNoteSection(String note) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 45),
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.isNotte
              ? [Colors.purple.withOpacity(0.15), Colors.black.withOpacity(0.4)]
              : [const Color(0xFFFF5252).withOpacity(0.2), Colors.white.withOpacity(0.7)], 
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: widget.isNotte ? Colors.purpleAccent.withOpacity(0.3) : const Color(0xFFFF5252).withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned(
            top: -60,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.favorite_rounded, size: 28, color: Color(0xFFFF5252)), 
                const SizedBox(width: 2),
                const Icon(Icons.favorite_rounded, size: 48, color: Color(0xFFFFF176)), 
                const SizedBox(width: 2),
                const Icon(Icons.favorite_rounded, size: 28, color: Color(0xFFFF5252)), 
              ],
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 15),
              Text(
                "\"$note\"",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: widget.isNotte ? Colors.white.withOpacity(0.9) : const Color(0xFF5D4037).withOpacity(0.9),
                  fontFamily: 'Georgia',
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ],
      ),
    );
  }
}

class _MenuOpzioniDiario extends StatelessWidget {
  final String animaleId;
  const _MenuOpzioniDiario({required this.animaleId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 25),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.edit_note_rounded, color: Colors.blueAccent),
            ),
            title: Text("diary_menu_edit".tr(), style: const TextStyle(fontWeight: FontWeight.w900)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => ModificaAnimale(animaleId: animaleId)));
            },
          ),
          const Divider(height: 30),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
            ),
            title: Text("diary_menu_delete".tr(), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900)),
            onTap: () => _confermaEliminazione(context),
          ),
        ],
      ),
    );
  }

  void _confermaEliminazione(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Text("dialog_confirm_delete_title".tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text("diary_delete_confirm_msg".tr()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("btn_cancel".tr())),
          TextButton(
              onPressed: () async {
                await eliminaAnimale(animaleId);
                if (context.mounted) {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                  Navigator.pop(context);
                }
              },
              child: Text("btn_delete".tr(), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
  }
}

class TigratoPainter extends CustomPainter {
  final Color baseColor;
  TigratoPainter({required this.baseColor});

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = baseColor);

    final stripePaint = Paint()
      ..color = Colors.black.withOpacity(0.75)
      ..style = PaintingStyle.fill;

    final random = math.Random(42);
    for (int i = 0; i < 15; i++) {
      double y = random.nextDouble() * size.height;      double width = 15 + random.nextDouble() * 25;
      double height = 3 + random.nextDouble() * 6;
      bool fromLeft = random.nextBool();

      Path path = Path();
      if (fromLeft) {
        path.moveTo(0, y);
        path.quadraticBezierTo(width * 0.7, y + height / 2, width, y + height / 2);
        path.quadraticBezierTo(width * 0.7, y + height, 0, y + height);
      } else {
        path.moveTo(size.width, y);
        path.quadraticBezierTo(size.width - width * 0.7, y + height / 2, size.width - width, y + height / 2);
        path.quadraticBezierTo(size.width - width * 0.7, y + height, size.width, y + height);
      }
      path.close();
      canvas.drawPath(path, stripePaint);
    }
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MaculatoPainter extends CustomPainter {
  final Color baseColor;
  MaculatoPainter({required this.baseColor});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPaint(Paint()..color = baseColor);

    final random = math.Random(123);
    for (int i = 0; i < 20; i++) {
      final center = Offset(random.nextDouble() * size.width, random.nextDouble() * size.height);
      final r = 4 + random.nextDouble() * 6;

      canvas.drawCircle(center, r * 0.7, Paint()..color = const Color(0xFF8B4513).withOpacity(0.5));

      int fragments = 3 + random.nextInt(3);
      for (int j = 0; j < fragments; j++) {
        double startAngle = (j * (2 * math.pi / fragments)) + random.nextDouble();
        double sweepAngle = (2 * math.pi / fragments) * 0.7;

        Path p = Path();
        p.addArc(Rect.fromCircle(center: center, radius: r), startAngle, sweepAngle);
        canvas.drawPath(
          p,
          Paint()
            ..color = Colors.black.withOpacity(0.8)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2 + random.nextDouble() * 2
            ..strokeCap = StrokeCap.round
        );
      }
    }
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PezzatoPainter extends CustomPainter {
  final Color baseColor;
  PezzatoPainter({required this.baseColor});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPaint(Paint()..color = baseColor);
    final patchPaint = Paint()..color = Colors.white.withOpacity(0.9)..style = PaintingStyle.fill;
    final random = math.Random(55);

    for (int i = 0; i < 4; i++) {
      final center = Offset(random.nextDouble() * size.width, random.nextDouble() * size.height);
      final radius = 15 + random.nextDouble() * 25;

      Path path = Path();
      int points = 8;
      for (int j = 0; j < points; j++) {
        double angle = (j / points) * 2 * math.pi;
        double r = radius * (0.6 + random.nextDouble() * 0.8);
        double x = center.dx + math.cos(angle) * r;
        double y = center.dy + math.sin(angle) * r;
        if (j == 0) path.moveTo(x, y);
        else path.lineTo(x, y);
      }
      path.close();
      canvas.drawPath(path, patchPaint);
    }
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MerlePainter extends CustomPainter {
  final Color baseColor;
  MerlePainter({required this.baseColor});

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      baseColor,
      baseColor.withOpacity(0.6),
      Colors.black.withOpacity(0.4),
      Colors.white.withOpacity(0.3),
      const Color(0xFF546E7A).withOpacity(0.5),
    ];
    final random = math.Random(9);
    canvas.drawPaint(Paint()..color = baseColor);

    for (int i = 0; i < 40; i++) {
      final color = colors[random.nextInt(colors.length)];
      final center = Offset(random.nextDouble() * size.width, random.nextDouble() * size.height);
      final radius = 3 + random.nextDouble() * 10;

      canvas.drawPath(
        Path()..addOval(Rect.fromCircle(center: center, radius: radius)),
        Paint()
          ..color = color
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5)
      );
    }
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TricolorePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintNero = Paint()..color = const Color(0xFF1A1A1A);
    final paintBianco = Paint()..color = Colors.white;
    final paintMarrone = Paint()..color = const Color(0xFF8B4513);

    Path pathNero = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.7, 0)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.5, 0, size.height * 0.8)
      ..close();

    Path pathMarrone = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width * 0.6, 0)
      ..quadraticBezierTo(size.width * 0.8, size.height * 0.6, size.width, size.height * 0.7)
      ..close();

    canvas.drawPaint(paintBianco);
    canvas.drawPath(pathNero, paintNero);
    canvas.drawPath(pathMarrone, paintMarrone);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
