import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:petping/tipologie/selector/a/selector.dart';
import 'package:petping/b_homes/c_datianimale/addati/card_chose.dart';
import 'package:petping/keyboard_cover.dart';
import 'package:petping/zoom.dart';
import 'diariopet/back_diario.dart';
import 'package:easy_localization/easy_localization.dart';

class ModificaAnimale extends StatefulWidget {
  final String animaleId;

  const ModificaAnimale({super.key, required this.animaleId});

  @override
  State<ModificaAnimale> createState() => _ModificaAnimaleState();
}

class _ModificaAnimaleState extends State<ModificaAnimale> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final nomeController = TextEditingController();
  final tipoController = TextEditingController();
  final razzaController = TextEditingController();
  final sessoController = TextEditingController();
  final dayController = TextEditingController();
  final monthController = TextEditingController();
  final yearController = TextEditingController();
  final coloreDominanteController = TextEditingController();
  final coloreSecondarioController = TextEditingController();
  final coloreTerziarioController = TextEditingController();
  final peloGrandezzaController = TextEditingController();
  final peloTipoController = TextEditingController();
  final codaGrandezzaController = TextEditingController();
  final codaTipoController = TextEditingController();
  final orecchieGrandezzaController = TextEditingController();
  final orecchieTipoController = TextEditingController();
  final occhiColoreController = TextEditingController();
  final occhiFormaController = TextEditingController();
  final tagliaController = TextEditingController();
  final microchipController = TextEditingController();
  final microchipNumeroController = TextEditingController();
  final vaccinatoController = TextEditingController();
  final riproduttivoController = TextEditingController();
  final allergicoController = TextEditingController();
  final allergieController = TextEditingController();
  final noteGeneraliController = TextEditingController();

  double _pesoValue = 5.0;
  File? _immagine;
  String? _urlImmagineEsistente;
  String? _temaCorrente;

  late PageController _pageController;
  int step = 0;
  String _searchQuery = "";
  bool _isLoading = true;
  bool _isSaving = false;

  final Color neonColor = const Color(0xFF00FBFF);
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    _caricaDati();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    nomeController.dispose();
    tipoController.dispose();
    razzaController.dispose();
    sessoController.dispose();
    dayController.dispose();
    monthController.dispose();
    yearController.dispose();
    coloreDominanteController.dispose();
    coloreSecondarioController.dispose();
    coloreTerziarioController.dispose();
    peloGrandezzaController.dispose();
    peloTipoController.dispose();
    codaGrandezzaController.dispose();
    codaTipoController.dispose();
    orecchieGrandezzaController.dispose();
    orecchieTipoController.dispose();
    occhiColoreController.dispose();
    occhiFormaController.dispose();
    tagliaController.dispose();
    microchipController.dispose();
    microchipNumeroController.dispose();
    vaccinatoController.dispose();
    riproduttivoController.dispose();
    allergicoController.dispose();
    allergieController.dispose();
    noteGeneraliController.dispose();
    super.dispose();
  }

  Future<void> _caricaDati() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('animali').doc(widget.animaleId).get();
      final data = doc.data();
      if (data != null) {
        setState(() {
          nomeController.text = data['nome'] ?? '';
          tipoController.text = data['tipo'] ?? '';
          razzaController.text = data['razza'] ?? '';
          sessoController.text = data['sesso'] ?? '';
          _temaCorrente = data['temaCarta'];
          _urlImmagineEsistente = data['fotoUrl'];
          _pesoValue = double.tryParse(data['peso']?.toString() ?? '5.0') ?? 5.0;
          final dataNascita = data['dataNascita']?.toString() ?? '';
          if (dataNascita.contains('-')) {
            final parti = dataNascita.split('-');
            if (parti.length == 3) {
              yearController.text = parti[0];
              monthController.text = parti[1];
              dayController.text = parti[2];
            }
          }
          coloreDominanteController.text = data['coloreDominante'] ?? '';
          coloreSecondarioController.text = data['coloreSecondario'] ?? '';
          coloreTerziarioController.text = data['coloreTerziario'] ?? '';
          peloGrandezzaController.text = data['peloGrandezza'] ?? '';
          peloTipoController.text = data['peloTipo'] ?? '';
          codaGrandezzaController.text = data['codaGrandezza'] ?? '';
          codaTipoController.text = data['codaTipo'] ?? '';
          orecchieGrandezzaController.text = data['orecchieGrandezza'] ?? '';
          orecchieTipoController.text = data['orecchieTipo'] ?? '';
          occhiColoreController.text = data['occhiColore'] ?? '';
          occhiFormaController.text = data['occhiForma'] ?? '';
          tagliaController.text = data['taglia'] ?? '';
          microchipController.text = data['microchip'] ?? '';
          microchipNumeroController.text = data['microchipNumero'] ?? '';
          vaccinatoController.text = data['vaccinato'] ?? '';
          riproduttivoController.text = data['riproduttivo'] ?? '';
          allergicoController.text = data['allergico'] ?? '';
          allergieController.text = data['allergie'] ?? '';
          noteGeneraliController.text = data['noteGenerali'] ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Errore caricamento: $e");
    }
  }

  bool _matchesSearch(String label) {
    if (_searchQuery.isEmpty) return true;
    return label.toLowerCase().contains(_searchQuery.toLowerCase());
  }

  Map<String, dynamic> _getDatiMappa() {
    final dataStr = "${yearController.text}-${monthController.text.padLeft(2, '0')}-${dayController.text.padLeft(2, '0')}";
    return {
      'nome': nomeController.text,
      'tipo': tipoController.text,
      'razza': razzaController.text,
      'sesso': sessoController.text,
      'dataNascita': dataStr,
      'peso': _pesoValue.toStringAsFixed(1),
      'coloreDominante': coloreDominanteController.text,
      'coloreSecondario': coloreSecondarioController.text,
      'coloreTerziario': coloreTerziarioController.text,
      'peloGrandezza': peloGrandezzaController.text,
      'peloTipo': peloTipoController.text,
      'codaGrandezza': codaGrandezzaController.text,
      'codaTipo': codaTipoController.text,
      'orecchieGrandezza': orecchieGrandezzaController.text,
      'orecchieTipo': orecchieTipoController.text,
      'occhiColore': occhiColoreController.text,
      'occhiForma': occhiFormaController.text,
      'taglia': tagliaController.text,
      'microchip': microchipController.text,
      'microchipNumero': microchipNumeroController.text,
      'vaccinato': vaccinatoController.text,
      'riproduttivo': riproduttivoController.text,
      'allergico': allergicoController.text,
      'allergie': allergieController.text,
      'noteGenerali': noteGeneraliController.text,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.black.withOpacity(0.3),
          elevation: 0,
          title: _buildSearchField(),
          actions: [
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CardChose(
                      datiAnimale: _getDatiMappa(),
                      foto: _immagine,
                      fotoPassaporto: const [],
                      temaIniziale: _temaCorrente,
                      animaleId: widget.animaleId,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.palette_outlined, color: Colors.white, size: 20),
              label: Text("btn_look".tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFE1F5FE), Color(0xFFB3E5FC), Color(0xFFFFECB3), Color(0xFFFFCCBC)],
                ),
              ),
            ),
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) => CustomPaint(painter: AnimalCartoonPainter(animationValue: _animationController.value)),
              ),
            ),
            Column(
              children: [
                const SizedBox(height: 100),
                _buildNavigationSwitch(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) => setState(() => step = index),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildStepPage(0, _buildIdentita()),
                      _buildStepPage(1, _buildAspetto()),
                      _buildStepPage(2, _buildSalute()),
                    ],
                  ),
                ),
              ],
            ),
            _buildModernNavigation(),
            if (_isSaving)
              Container(
                color: Colors.black54,
                child: const Center(child: CircularProgressIndicator(color: Colors.white)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepPage(int index, Widget content) {
    return SingleChildScrollView(
      key: PageStorageKey<int>(index),
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        children: [
          const SizedBox(height: 20),
          content,
          const SizedBox(height: 150),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 38,
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          hintText: "hint_search_field".tr(),
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          prefixIcon: const Icon(Icons.search, color: Colors.white70, size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }

  Widget _buildNavigationSwitch() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white10),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeInOutQuart,
            alignment: Alignment(step == 0 ? -1 : (step == 1 ? 0 : 1), 0),
            child: FractionallySizedBox(
              widthFactor: 0.33,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [neonColor.withOpacity(0.4), neonColor.withOpacity(0.1)]),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [BoxShadow(color: neonColor.withOpacity(0.2), blurRadius: 8)],
                ),
              ),
            ),
          ),
          Row(
            children: [
              _navBtn("tab_identity".tr(), 0),
              _navBtn("tab_appearance".tr(), 1),
              _navBtn("tab_health".tr(), 2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navBtn(String label, int index) {
    bool isSel = step == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (step == index) return;
          _pageController.animateToPage(index, duration: const Duration(milliseconds: 500), curve: Curves.easeInOutCubic);
        },
        child: Container(
          color: Colors.transparent,
          alignment: Alignment.center,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(color: isSel ? neonColor : Colors.white54, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1),
            child: Text(label),
          ),
        ),
      ),
    );
  }

  Widget _buildIdentita() {
    final allTipi = allTipiOrdinati;
    final availableRazze = razzePerSpecie[tipoController.text] ?? [];

    return Column(
      children: [
        if (_searchQuery.isEmpty) ...[
          GestureDetector(
            onTap: _scegliImmagine,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(width: 130, height: 130, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 4), boxShadow: [BoxShadow(color: neonColor.withOpacity(0.3), blurRadius: 20)])),
                CircleAvatar(radius: 60, backgroundColor: Colors.black45, backgroundImage: _immagine != null ? FileImage(_immagine!) : (_urlImmagineEsistente != null ? NetworkImage(_urlImmagineEsistente!) : null) as ImageProvider?, child: (_immagine == null && _urlImmagineEsistente == null) ? const Icon(Icons.add_a_photo, color: Colors.white, size: 40) : null),
              ],
            ),
          ),
          const SizedBox(height: 25),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _smallSexBtn("Maschio", Icons.male, Colors.blue),
            const SizedBox(width: 25),
            _smallSexBtn("Femmina", Icons.female, Colors.pink),
          ],
        ),
        const SizedBox(height: 25),
        if (_matchesSearch("nome")) _elegantNeonInput(nomeController, "pet_label_name_upper".tr(), labelColor: Colors.orangeAccent),
        const SizedBox(height: 15),
        if (_matchesSearch("tipo") || _matchesSearch("specie")) _elegantNeonAutocomplete(tipoController, "pet_label_species_upper".tr(), allTipi, labelColor: Colors.greenAccent),
        const SizedBox(height: 15),
        if (_matchesSearch("razza")) _elegantNeonAutocomplete(razzaController, "pet_label_breed_upper".tr(), availableRazze, enabled: availableRazze.isNotEmpty, labelColor: Colors.purpleAccent),
        const SizedBox(height: 15),
        if (_matchesSearch("nascita")) _artisticoSelector(label: "pet_label_birthdate_upper".tr(), labelColor: Colors.blueAccent, child: GestureDetector(onTap: _pickDate, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [_datePart(dayController, "GG"), _slash(), _datePart(monthController, "MM"), _slash(), _datePart(yearController, "AAAA"), const SizedBox(width: 10), const Icon(Icons.calendar_month, color: Colors.white70, size: 18)]))),
      ],
    );
  }

  Widget _smallSexBtn(String val, IconData icon, Color color) {
    bool isSel = sessoController.text == val;
    return GestureDetector(
      onTap: () => setState(() => sessoController.text = val),
      child: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          color: isSel ? color : Colors.black.withOpacity(0.6),
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(isSel ? 1.0 : 0.6), width: 3.5),
          boxShadow: [
            BoxShadow(color: color.withOpacity(isSel ? 0.8 : 0.3), blurRadius: 25, spreadRadius: 1),
            if (isSel) BoxShadow(color: color.withOpacity(0.4), blurRadius: 40, spreadRadius: 4),
          ],
        ),
        child: Icon(icon, color: isSel ? Colors.white : color.withOpacity(0.8), size: 28),
      ),
    );
  }

  Widget _buildAspetto() => Column(children: [
    _sectionTitle("section_colors_coat".tr(), Icons.palette_outlined, bgColor: const Color(0xFFF8BBD0)),
    if (_matchesSearch("colore")) ...[
      _artisticoSelector(label: "color_primary_upper".tr(), labelColor: Colors.redAccent, child: ColoreSelector(controller: coloreDominanteController, label: "hint_choose_color".tr())),
      const SizedBox(height: 15),
      Row(children: [
        Expanded(child: _artisticoSelector(label: "color_secondary_upper".tr(), labelColor: Colors.greenAccent, child: ColoreSelector(controller: coloreSecondarioController, label: "hint_choose_color".tr()))),
        const SizedBox(width: 10),
        Expanded(child: _artisticoSelector(label: "color_tertiary_upper".tr(), labelColor: Colors.amberAccent, child: ColoreSelector(controller: coloreTerziarioController, label: "hint_choose_color".tr()))),
      ]),
    ],
    const SizedBox(height: 25),
    _sectionTitle("section_fur_features".tr(), Icons.waves, bgColor: Colors.greenAccent[100]!),
    if (_matchesSearch("pelo")) Row(children: [
      Expanded(child: _artisticoSelector(label: "fur_length_upper".tr(), labelColor: Colors.amber, child: PeloGrandezzaSelector(controller: peloGrandezzaController))),
      const SizedBox(width: 10),
      Expanded(child: _artisticoSelector(label: "fur_type_upper".tr(), labelColor: Colors.cyanAccent, child: TipoPeloSelector(controller: peloTipoController))),
    ]),
    const SizedBox(height: 25),
    _sectionTitle("section_physical_details".tr(), Icons.straighten, bgColor: Colors.yellow[200]!),
    if (_matchesSearch("orecchie")) Row(children: [
      Expanded(child: _artisticoSelector(label: "ears_size_upper".tr(), labelColor: Colors.indigoAccent, child: OrecchieGrandezzaSelector(controller: orecchieGrandezzaController))),
      const SizedBox(width: 10),
      Expanded(child: _artisticoSelector(label: "ears_type_upper".tr(), labelColor: Colors.blueGrey, child: OrecchieTipoSelector(controller: orecchieTipoController))),
    ]),
    const SizedBox(height: 15),
    if (_matchesSearch("coda")) Row(children: [
      Expanded(child: _artisticoSelector(label: "tail_length_upper".tr(), labelColor: Colors.deepOrangeAccent, child: CodaGrandezzaSelector(controller: codaGrandezzaController))),
      const SizedBox(width: 10),
      Expanded(child: _artisticoSelector(label: "tail_type_upper".tr(), labelColor: Colors.brown, child: CodaTipoSelector(controller: codaTipoController))),
    ]),
    const SizedBox(height: 15),
    if (_matchesSearch("occhi")) Row(children: [
      Expanded(child: _artisticoSelector(label: "eyes_color_upper".tr(), labelColor: Colors.blue, child: OcchiColoreSelector(controller: occhiColoreController))),
      const SizedBox(width: 10),
      Expanded(child: _artisticoSelector(label: "eyes_shape_upper".tr(), labelColor: Colors.purpleAccent, child: OcchiFormaSelector(controller: occhiFormaController))),
    ]),
  ]);

  Widget _buildSalute() => Column(children: [
    _sectionTitle("section_health_safety".tr(), Icons.health_and_safety_outlined, bgColor: const Color(0xFFFFCDD2)),
    if (_matchesSearch("microchip")) _artisticoSelector(label: "microchip_upper".tr(), labelColor: Colors.redAccent, child: MicrochipSelector(statoController: microchipController, numeroController: microchipNumeroController)),
    const SizedBox(height: 25),
    _sectionTitle("section_dimensions".tr(), Icons.monitor_weight_outlined, bgColor: const Color(0xFFDCEDC8)),
    if (_matchesSearch("peso")) _buildWeightCounter(),
    const SizedBox(height: 15),
    if (_matchesSearch("taglia")) _artisticoSelector(label: "veterinary_size_upper".tr(), labelColor: const Color(0xFF9575CD), child: TagliaVeterinariaSelector(controller: tagliaController)),
    const SizedBox(height: 25),
    _sectionTitle("section_health_status".tr(), Icons.medical_services_outlined, bgColor: const Color(0xFFB3E5FC)),
    if (_matchesSearch("vaccino")) _artisticoSelector(label: "vaccinations_upper".tr(), labelColor: Colors.lightBlueAccent, child: VaccinatoSelector(controller: vaccinatoController)),
    const SizedBox(height: 15),
    if (_matchesSearch("ripro")) _artisticoSelector(label: "reproductive_status_upper".tr(), labelColor: const Color(0xFF4FC3F7), child: StatoRiproduttivoSelector(controller: riproduttivoController)),
    const SizedBox(height: 15),
    if (_matchesSearch("allergie")) _artisticoSelector(label: "allergies_upper".tr(), labelColor: Colors.orangeAccent, child: AllergieSelector(statoController: allergicoController, allergieController: allergieController)),
    const SizedBox(height: 25),
    _sectionTitle("section_note_details".tr(), Icons.description_outlined, bgColor: const Color(0xFFFFE0B2)),
    if (_matchesSearch("note")) _artisticoSelector(label: "general_notes_upper".tr(), labelColor: Colors.blueGrey[300]!, child: NoteGeneraliSelector(controller: noteGeneraliController)),
    const SizedBox(height: 40),
    ElevatedButton.icon(
      onPressed: () => _confermaEliminazione(context),
      icon: const Icon(Icons.delete_forever, color: Colors.white),
      label: Text("btn_delete_profile_permanent".tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    ),
  ]);

  Widget _sectionTitle(String t, IconData i, {required Color bgColor}) => Container(margin: const EdgeInsets.only(bottom: 15, top: 10), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: bgColor.withOpacity(0.7), borderRadius: BorderRadius.circular(15)), child: Row(children: [Icon(i, color: Colors.black87, size: 20), const SizedBox(width: 12), Text(t.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.black87, letterSpacing: 1.2))]));

  Widget _labelBadge(String t, {Color? color}) => Container(margin: const EdgeInsets.only(left: 8, bottom: 4), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3), decoration: BoxDecoration(color: color?.withOpacity(0.8) ?? Colors.black54, borderRadius: BorderRadius.circular(8)), child: Text(t, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)));

  Widget _artisticoSelector({required String label, required Widget child, Color? labelColor}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_labelBadge(label, color: labelColor), _neonWrapper(child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white24)), child: Theme(data: ThemeData.dark().copyWith(inputDecorationTheme: const InputDecorationTheme(border: InputBorder.none)), child: child)))]);

  Widget _elegantNeonInput(TextEditingController c, String h, {Color? labelColor, FocusNode? focusNode, bool enabled = true, Function(String)? onChanged, VoidCallback? onSubmitted}) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _labelBadge(h, color: labelColor),
        _neonWrapper(child: TextField(
            controller: c,
            focusNode: focusNode,
            enabled: enabled,
            onChanged: onChanged,
            onSubmitted: (_) => onSubmitted?.call(),
            scrollPadding: const EdgeInsets.only(bottom: 150),
            style: TextStyle(color: enabled ? Colors.white : Colors.white38, fontWeight: FontWeight.bold, fontSize: 16),
            decoration: InputDecoration(
                filled: true,
                fillColor: enabled ? Colors.black.withOpacity(0.6) : Colors.black.withOpacity(0.3),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: const BorderSide(color: Colors.white, width: 1.5)),
                disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide(color: Colors.white.withOpacity(0.1), width: 1.5)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide(color: neonColor, width: 2.0))
            )
        )),
      ]);

  Widget _neonWrapper({required Widget child}) => Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: neonColor.withOpacity(0.2), blurRadius: 15, spreadRadius: 1)]), child: child);

  Widget _buildWeightCounter() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _labelBadge("weight_estimated_upper".tr(), color: const Color(0xFFFFB74D)),
      _neonWrapper(child: Container(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10), decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.white24, width: 1.5)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(_pesoValue.toStringAsFixed(1), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: neonColor)), Row(children: [_counterBtn(Icons.remove, () => setState(() => _pesoValue = (_pesoValue - 0.1).clamp(0.1, 100.0)), Colors.red.shade200), const SizedBox(width: 12), _counterBtn(Icons.add, () => setState(() => _pesoValue = (_pesoValue + 0.1).clamp(0.1, 100.0)), Colors.green.shade200)])]))),
    ]);
  }

  Widget _counterBtn(IconData i, VoidCallback o, Color c) => GestureDetector(onTap: o, child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: c.withOpacity(0.15), shape: BoxShape.circle, border: Border.all(color: c.withOpacity(0.5), width: 1.5)), child: Icon(i, size: 20, color: c)));

  Widget _datePart(TextEditingController c, String h) => Text(c.text.isEmpty ? h : c.text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14));
  Widget _slash() => const Text("/", style: TextStyle(color: Colors.white24));

  Widget _buildModernNavigation() {
    if (MediaQuery.of(context).viewInsets.bottom > 0) return const SizedBox.shrink();

    return Positioned(
      bottom: 25, left: 20, right: 20,
      child: Row(
        children: [
          Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.2), minimumSize: const Size(0, 52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25), side: const BorderSide(color: Colors.white24))), onPressed: () => _salvaModificheRapide(), child: Text("btn_save_exit".tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)))),
          const SizedBox(width: 12),
          Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, minimumSize: const Size(0, 52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), elevation: 5), onPressed: () {
            if (step < 2) {
              _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOutCubic);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CardChose(
                    datiAnimale: _getDatiMappa(),
                    foto: _immagine,
                    fotoPassaporto: const [],
                    temaIniziale: _temaCorrente,
                    animaleId: widget.animaleId,
                  ),
                ),
              );
            }
          }, child: Text(step < 2 ? "btn_continue".tr() : "btn_finish_style".tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)))),
        ],
      ),
    );
  }

  Future<void> _salvaModificheRapide() async {
    setState(() => _isSaving = true);
    try {
      await FirebaseFirestore.instance.collection('animali').doc(widget.animaleId).update(_getDatiMappa());
      
      if (_immagine != null) {
        final ref = FirebaseStorage.instance.ref().child('foto_animali/${widget.animaleId}.jpg');
        await ref.putFile(_immagine!);
        final url = await ref.getDownloadURL();
        await FirebaseFirestore.instance.collection('animali').doc(widget.animaleId).update({'fotoUrl': url});
      }

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("msg_profile_updated".tr()), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (context.mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("msg_error_save".tr(args: [e.toString()])), backgroundColor: Colors.redAccent));
      }
    }
  }

  Future<void> _confermaEliminazione(BuildContext context) async {
    final conferma = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("dialog_confirm_delete_title".tr()),
        content: Text("dialog_confirm_delete_text".tr()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text("btn_cancel_upper".tr())),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text("btn_delete_upper".tr(), style: const TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (conferma == true) {
      setState(() => _isSaving = true);
      try {
        await eliminaAnimale(widget.animaleId);
        if (context.mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("msg_profile_deleted".tr()), backgroundColor: Colors.green));
        }
      } catch (e) {
        if (context.mounted) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("msg_error_delete".tr(args: [e.toString()])), backgroundColor: Colors.redAccent));
        }
      }
    }
  }

  Future<void> _pickDate() async {
    final DateTime? pi = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1990), lastDate: DateTime.now(), builder: (c, ch) => Theme(data: ThemeData.dark().copyWith(primaryColor: neonColor), child: ch!));
    if (pi != null) {
      setState(() {
        dayController.text = pi.day.toString().padLeft(2, '0');
        monthController.text = pi.month.toString().padLeft(2, '0');
        yearController.text = pi.year.toString();
      });
    }
  }

  Widget _elegantNeonAutocomplete(TextEditingController c, String label, List<String> opt, {bool enabled = true, Color? labelColor}) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (!enabled) return const Iterable<String>.empty();
        if (textEditingValue.text == '') return opt;
        return opt.where((String o) => o.toLowerCase().contains(textEditingValue.text.toLowerCase()));
      },
      onSelected: (String s) {
        setState(() {
          c.text = s;
          if (label.contains("SPECIE")) razzaController.clear();
        });
        FocusScope.of(context).unfocus();
      },
      fieldViewBuilder: (ctx, ctrl, focus, onSub) {
        if (c.text.isEmpty && ctrl.text.isNotEmpty) {
          ctrl.text = '';
        } else if (c.text.isNotEmpty && ctrl.text.isEmpty) {
          ctrl.text = c.text;
        }
        return _elegantNeonInput(ctrl, label, labelColor: labelColor, focusNode: focus, enabled: enabled, onChanged: (val) {
          setState(() {
            c.text = val;
            if (label.contains("SPECIE")) razzaController.clear();
          });
        }, onSubmitted: onSub);
      },
      optionsViewBuilder: (context, onSelected, options) => Align(
        alignment: Alignment.topLeft,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            margin: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(20), border: Border.all(color: neonColor.withOpacity(0.5), width: 1.5), boxShadow: [BoxShadow(color: neonColor.withOpacity(0.2), blurRadius: 10)]),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: options.length,
                  separatorBuilder: (context, index) => Divider(color: Colors.white.withOpacity(0.1), height: 1),
                  itemBuilder: (ctx, i) => ListTile(dense: true, title: Text(options.elementAt(i), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)), onTap: () => onSelected(options.elementAt(i))),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _scegliImmagine() async {
    final p = ImagePicker();
    final pi = await p.pickImage(source: ImageSource.gallery);
    if (pi != null) {
      File img = File(pi.path);
      final ed = await Navigator.push(context, MaterialPageRoute(builder: (_) => PhotoEditorPage(imageFile: img)));
      if (ed != null) setState(() => _immagine = ed);
    }
  }
}

class AnimalCartoonPainter extends CustomPainter {
  final double animationValue;
  AnimalCartoonPainter({required this.animationValue});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(42);
    const int cols = 5;
    const int rows = 8;
    final double colWidth = size.width / cols;
    final double rowHeight = size.height / rows;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (random.nextDouble() > 0.7) continue;
        final double baseX = c * colWidth + random.nextDouble() * (colWidth * 0.4);
        final double baseY = r * rowHeight + random.nextDouble() * (rowHeight * 0.4);
        final double time = animationValue * 2 * math.pi;
        final double dx = math.cos(time + (r * c)) * 12;
        final double dy = math.sin(time + (r + c)) * 15;
        int type = random.nextInt(5);
        Color itemColor;
        switch (type) {
          case 0:
            itemColor = const Color(0xFF263238).withOpacity(0.3);
            break;
          case 1:
            itemColor = const Color(0xFF795548).withOpacity(0.3);
            break;
          case 2:
            itemColor = const Color(0xFFFF7043).withOpacity(0.35);
            break;
          case 3:
            itemColor = const Color(0xFFE53935).withOpacity(0.35);
            break;
          default:
            itemColor = const Color(0xFF81D4FA).withOpacity(0.25);
        }
        canvas.save();
        canvas.translate(baseX + dx, baseY + dy);
        canvas.rotate(random.nextDouble() * math.pi / 4 + math.sin(time + r) * 0.1);
        paint.color = itemColor;
        if (type == 0)
          _drawPaw(canvas, paint);
        else if (type == 1)
          _drawBone(canvas, paint);
        else if (type == 2)
          _drawFish(canvas, paint);
        else if (type == 3)
          _drawHeart(canvas, paint);
        else
          _drawYarnBall(canvas, paint);
        canvas.restore();
      }
    }
  }

  void _drawPaw(Canvas canvas, Paint paint) {
    canvas.drawCircle(Offset.zero, 8, paint);
    canvas.drawCircle(const Offset(-10, -10), 4, paint);
    canvas.drawCircle(const Offset(0, -13), 4, paint);
    canvas.drawCircle(const Offset(10, -10), 4, paint);
  }

  void _drawBone(Canvas canvas, Paint paint) {
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-12, -3, 24, 6), const Radius.circular(3)), paint);
    canvas.drawCircle(const Offset(-12, -3), 4, paint);
    canvas.drawCircle(const Offset(-12, 3), 4, paint);
    canvas.drawCircle(const Offset(12, -3), 4, paint);
    canvas.drawCircle(const Offset(12, 3), 4, paint);
  }

  void _drawFish(Canvas canvas, Paint paint) {
    final path = Path()
      ..moveTo(-10, 0)
      ..quadraticBezierTo(0, -8, 10, 0)
      ..quadraticBezierTo(0, 8, -10, 0)
      ..moveTo(-10, 0)
      ..lineTo(-15, -5)
      ..lineTo(-15, 5)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawHeart(Canvas canvas, Paint paint) {
    final path = Path()
      ..moveTo(0, 4)
      ..cubicTo(-10, -6, -15, 6, 0, 15)
      ..cubicTo(15, 6, 10, -6, 0, 4);
    canvas.drawPath(path, paint);
  }

  void _drawYarnBall(Canvas canvas, Paint paint) {
    canvas.drawCircle(Offset.zero, 9, paint);
    final strokePaint = Paint()
      ..color = paint.color.withOpacity(paint.color.opacity + 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(const Offset(-7, -4), const Offset(7, 4), strokePaint);
    canvas.drawLine(const Offset(-7, 4), const Offset(7, -4), strokePaint);
    canvas.drawLine(const Offset(0, -8), const Offset(0, 8), strokePaint);
  }

  @override
  bool shouldRepaint(covariant AnimalCartoonPainter oldDelegate) => true;
}
