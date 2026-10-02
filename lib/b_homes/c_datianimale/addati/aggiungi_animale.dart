import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petping/tipologie/selector/a/selector.dart';
import 'package:petping/b_homes/c_datianimale/addati/card_chose.dart';
import 'package:petping/keyboard_cover.dart';
import 'package:petping/zoom.dart';
import 'package:easy_localization/easy_localization.dart';

class AggiungiAnimale extends StatefulWidget {
  const AggiungiAnimale({super.key});

  @override
  State<AggiungiAnimale> createState() => _AggiungiAnimaleState();
}

class _AggiungiAnimaleState extends State<AggiungiAnimale> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // STEP 1
  final nomeController = TextEditingController();
  final tipoController = TextEditingController();
  final razzaController = TextEditingController();
  final sessoController = TextEditingController();
  final dayController = TextEditingController();
  final monthController = TextEditingController();
  final yearController = TextEditingController();

  // STEP 2
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

  // STEP 3
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
  int step = 0;
  bool _isMovingForward = true;

  final Color neonColor = const Color(0xFF00FBFF);

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
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

  Future<void> _scegliImmagine() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      File img = File(picked.path);

      final editedImage = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PhotoEditorPage(imageFile: img),
        ),
      );

      if (editedImage != null) {
        setState(() {
          _immagine = editedImage;
        });
      }
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            primaryColor: neonColor,
            colorScheme: ColorScheme.dark(primary: neonColor),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        dayController.text = picked.day.toString().padLeft(2, '0');
        monthController.text = picked.month.toString().padLeft(2, '0');
        yearController.text = picked.year.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFE1F5FE),
                Color(0xFFB3E5FC),
                Color(0xFFFFECB3),
                Color(0xFFFFCCBC),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: AnimalCartoonPainter(animationValue: _animationController.value),
                    );
                  }
                ),
              ),
              Positioned.fill(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 1200),
                  reverseDuration: const Duration(milliseconds: 1200),
                  switchInCurve: Curves.linear,
                  switchOutCurve: Curves.linear,
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    final isEntering = child.key == ValueKey<int>(step);
                    
                    final curvedAnimation = CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOutQuart,
                    );

                    final offset = _isMovingForward
                        ? (isEntering ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0))
                        : (isEntering ? const Offset(-1.0, 0.0) : const Offset(1.0, 0.0));

                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: offset,
                        end: Offset.zero,
                      ).animate(curvedAnimation),
                      child: FadeTransition(
                        opacity: curvedAnimation,
                        child: child,
                      ),
                    );
                  },
                  child: SafeFormPage(
                    key: ValueKey<int>(step),
                    child: step == 0
                        ? SizedBox(
                            height: MediaQuery.of(context).size.height,
                            child: SingleChildScrollView(
                              child: SizedBox(
                                height: math.max(MediaQuery.of(context).size.height, 850),
                                child: _step1Artistico(),
                              ),
                            ),
                          )
                        : _stepFormContent(),
                  ),
                ),
              ),
              _buildMinimalNavigation(),
              _buildStepIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Positioned(
      top: 60,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "pets_step_label".tr(args: [(step + 1).toString()]),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _stepFormContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 110),
            if (step == 1) _step2Widget() else _step3Widget(),
            const SizedBox(height: 150),
          ],
        ),
      ),
    );
  }

  Widget _step1Artistico() {
    final allTipi = [...razzePerSpecie.keys, ...specieSenzaRazze];
    final availableRazze = razzePerSpecie[tipoController.text] ?? [];

    return Stack(
      children: [
        Positioned(
          top: 122,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: _scegliImmagine,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 153,
                    height: 153,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    width: 145,
                    height: 145,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [neonColor, Colors.greenAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: neonColor.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 137,
                    height: 137,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                  CircleAvatar(
                    radius: 65,
                    backgroundColor: Colors.black.withOpacity(0.4),
                    backgroundImage: _immagine != null ? FileImage(_immagine!) : null,
                    child: _immagine == null
                        ? const Icon(Icons.add_a_photo_outlined, color: Colors.white, size: 50)
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),

        Positioned(
          top: 360,
          left: 25,
          right: 25,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _labelBadge("pets_label_gender".tr(), color: Colors.pinkAccent),
                  Row(
                    children: [
                      _smallSexBtn("Maschio", "gender_male".tr(), Icons.male, Colors.blue),
                      const SizedBox(width: 15),
                      _smallSexBtn("Femmina", "gender_female".tr(), Icons.female, Colors.pink),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _labelBadge("pets_label_born_on".tr(), color: Colors.blueAccent),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                        boxShadow: [BoxShadow(color: neonColor.withOpacity(0.2), blurRadius: 10)],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _datePart(dayController, "pets_date_day".tr()),
                          _slash(),
                          _datePart(monthController, "pets_date_month".tr()),
                          _slash(),
                          _datePart(yearController, "pets_date_year".tr(), width: 45),
                          const SizedBox(width: 8),
                          const Icon(Icons.calendar_month_rounded, color: Colors.blue, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        Positioned(
          top: 510,
          left: 25,
          right: 25,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _labelBadge("pets_label_name".tr(), color: Colors.orange),
              _elegantNeonInput(nomeController, "pets_hint_name".tr()),
              const SizedBox(height: 35),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _labelBadge("pets_label_type".tr(), color: Colors.green),
                        _elegantNeonAutocomplete(tipoController, "pets_hint_type".tr(), allTipi),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _labelBadge("pets_label_breed".tr(), color: Colors.purple),
                        _elegantNeonAutocomplete(razzaController, "pets_hint_breed".tr(), availableRazze, enabled: availableRazze.isNotEmpty),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _labelBadge(String text, {Color color = Colors.black}) {
    return Container(
      margin: const EdgeInsets.only(left: 10, bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5),
      ),
    );
  }

  Widget _elegantNeonInput(TextEditingController c, String hint, {FocusNode? focusNode, Function(String)? onChanged, VoidCallback? onSubmitted, bool enabled = true}) {
    return _neonWrapper(
      child: TextField(
        controller: c,
        focusNode: focusNode,
        onChanged: onChanged,
        onSubmitted: (_) => onSubmitted?.call(),
        enabled: enabled,
        scrollPadding: const EdgeInsets.only(bottom: 150),
        style: TextStyle(color: enabled ? Colors.white : Colors.white38, fontWeight: FontWeight.bold, fontSize: 18),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 15),
          filled: true,
          fillColor: enabled ? Colors.black.withOpacity(0.6) : Colors.black.withOpacity(0.3),
          contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: Colors.white, width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.1), width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: neonColor, width: 2.5),
          ),
        ),
      ),
    );
  }

  Widget _neonWrapper({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: neonColor.withOpacity(0.4), blurRadius: 15, spreadRadius: 1),
          BoxShadow(color: neonColor.withOpacity(0.1), blurRadius: 30, spreadRadius: 2),
        ],
      ),
      child: child,
    );
  }

  Widget _artisticoSelector({
    required String label,
    required Widget child,
    Color labelColor = Colors.black,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labelBadge(label, color: labelColor),
        Row(
          children: [
            Expanded(
              child: _neonWrapper(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Container(
                    color: Colors.black.withOpacity(0.6),
                    child: Theme(
                      data: ThemeData.dark().copyWith(
                        inputDecorationTheme: InputDecorationTheme(
                          filled: true,
                          fillColor: Colors.transparent,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 22, vertical: 14),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: const BorderSide(
                                color: Colors.white, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide:
                            BorderSide(color: neonColor, width: 2.5),
                          ),
                        ),
                      ),
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _elegantNeonAutocomplete(TextEditingController c, String label, List<String> opt, {bool enabled = true}) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (!enabled) return const Iterable<String>.empty();
        if (textEditingValue.text == '') return opt;
        return opt.where((String o) => o.toLowerCase().contains(textEditingValue.text.toLowerCase()));
      },
      onSelected: (String s) {
        setState(() {
          c.text = s;
          if (label.contains("specie") || label.contains("TYPE")) razzaController.clear();
        });
        FocusScope.of(context).unfocus();
      },
      fieldViewBuilder: (ctx, ctrl, focus, onSub) {
        if (c.text.isEmpty && ctrl.text.isNotEmpty) {
          ctrl.text = '';
        } else if (c.text.isNotEmpty && ctrl.text.isEmpty) {
          ctrl.text = c.text;
        }
        return _elegantNeonInput(ctrl, label, focusNode: focus, enabled: enabled, onSubmitted: onSub, onChanged: (val) {
          setState(() {
            c.text = val;
            if (label.contains("specie") || label.contains("TYPE")) razzaController.clear();
          });
        });
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.42,
              margin: const EdgeInsets.only(top: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: neonColor.withOpacity(0.5), width: 1.5),
                boxShadow: [BoxShadow(color: neonColor.withOpacity(0.2), blurRadius: 10)],
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 250),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    separatorBuilder: (context, index) => Divider(color: Colors.white.withOpacity(0.1), height: 1),
                    itemBuilder: (BuildContext context, int index) {
                      final String option = options.elementAt(index);
                      return ListTile(
                        dense: true,
                        title: Text(option, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        onTap: () => onSelected(option),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _smallSexBtn(String val, String label, IconData icon, Color color) {
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

  Widget _datePart(TextEditingController c, String hint, {double width = 30}) {
    return SizedBox(
      width: width,
      child: Center(
        child: Text(
          c.text.isEmpty ? hint : c.text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: c.text.isEmpty ? Colors.white24 : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _slash() => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 2),
    child: Text("/", style: TextStyle(color: Colors.white24, fontWeight: FontWeight.bold, fontSize: 16)),
  );

  Widget _buildMinimalNavigation() {
    if (MediaQuery.of(context).viewInsets.bottom > 0) return const SizedBox.shrink();

    return Positioned(
      bottom: 30, left: 30, right: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (step > 0)
            GestureDetector(
              onTap: () => setState(() {
                _isMovingForward = false;
                step--;
              }),
              child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.white70)),
            )
          else
            const SizedBox(),
          GestureDetector(
            onTap: () async {
              if (step < 2) {
                setState(() {
                  _isMovingForward = true;
                  step++;
                });
              } else {
                final data = "${yearController.text}-${monthController.text.padLeft(2, '0')}-${dayController.text.padLeft(2, '0')}";
                final Map<String, dynamic> datiCompleti = {
                  'nome': nomeController.text, 'tipo': tipoController.text, 'razza': razzaController.text,
                  'sesso': sessoController.text, 'dataNascita': data, 'peso': _pesoValue.toStringAsFixed(1),
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

                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (_) => CardChose(
                      datiAnimale: datiCompleti,
                      foto: _immagine,
                      fotoPassaporto: const [],
                    )
                  )
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 12),
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.15), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.blue.withOpacity(0.2))),
              child: Text(step < 2 ? "btn_next".tr() : "btn_continue_emoji".tr(), style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _step2Widget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("pets_section_colors".tr(), Icons.palette_outlined, bgColor: const Color(0xFFF8BBD0)),
        _artisticoSelector(label: "pets_label_select".tr(), child: ColoreSelector(controller: coloreDominanteController, label: "pets_hint_choose_color".tr()), labelColor: Colors.redAccent),
        const SizedBox(height: 25),
        Row(children: [
          Expanded(child: _artisticoSelector(label: "pets_label_second".tr(), child: ColoreSelector(controller: coloreSecondarioController, label: "pets_label_select".tr()), labelColor: Colors.greenAccent)),
          const SizedBox(width: 15),
          Expanded(child: _artisticoSelector(label: "pets_label_third".tr(), child: ColoreSelector(controller: coloreTerziarioController, label: "pets_label_select".tr()), labelColor: Colors.amberAccent)),
        ]),
        const SizedBox(height: 35),
        _sectionTitle("pets_section_coat_features".tr(), Icons.waves, bgColor: Colors.greenAccent[100]!),
        Row(children: [
          Expanded(child: _artisticoSelector(label: "pets_label_length".tr(), child: PeloGrandezzaSelector(controller: peloGrandezzaController), labelColor: Colors.amber[200]!,)),
          const SizedBox(width: 15),
          Expanded(child: _artisticoSelector(label: "pets_label_type_simple".tr(), child: TipoPeloSelector(controller: peloTipoController), labelColor: Colors.cyanAccent)),
        ]),
        const SizedBox(height: 35),
        _sectionTitle("pets_section_physical_details".tr(), Icons.straighten, bgColor: Colors.yellow[200]!),
        Row(children: [
          Expanded(child: _artisticoSelector(label: "pets_label_tail_dim".tr(), child: CodaGrandezzaSelector(controller: codaGrandezzaController), labelColor: Colors.deepOrangeAccent)),
          const SizedBox(width: 15),
          Expanded(child: _artisticoSelector(label: "pets_label_tail_type".tr(), child: CodaTipoSelector(controller: codaTipoController), labelColor: Colors.brown)),
        ]),
        const SizedBox(height: 25),
        Row(children: [
          Expanded(child: _artisticoSelector(label: "pets_label_ears".tr(), child: OrecchieGrandezzaSelector(controller: orecchieGrandezzaController), labelColor: Colors.indigoAccent)),
          const SizedBox(width: 15),
          Expanded(child: _artisticoSelector(label: "pets_label_ears_type".tr(), child: OrecchieTipoSelector(controller: orecchieTipoController), labelColor: Colors.blueGrey)),
        ]),
        const SizedBox(height: 35),
        _sectionTitle("pets_section_eyes".tr(), Icons.visibility_outlined, bgColor: Colors.deepPurple[50]!),
        Row(children: [
          Expanded(child: _artisticoSelector(label: "pets_label_color".tr(), child: OcchiColoreSelector(controller: occhiColoreController), labelColor: Colors.blue)),
          const SizedBox(width: 15),
          Expanded(child: _artisticoSelector(label: "pets_label_shape".tr(), child: OcchiFormaSelector(controller: occhiFormaController), labelColor: Colors.purpleAccent)),
        ]),
      ],
    );
  }

  Widget _step3Widget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("pets_section_health_safety".tr(), Icons.health_and_safety_outlined, bgColor: const Color(0xFFFFCDD2)),
        _artisticoSelector(label: "pets_label_microchip".tr(), child: MicrochipSelector(statoController: microchipController, numeroController: microchipNumeroController), labelColor: Colors.redAccent),
        const SizedBox(height: 35),
        _sectionTitle("pets_section_dimensions".tr(), Icons.monitor_weight_outlined, bgColor: const Color(0xFFDCEDC8)),
        _buildWeightCounter(),
        const SizedBox(height: 25),
        _artisticoSelector(label: "pets_label_vet_size".tr(), child: TagliaVeterinariaSelector(controller: tagliaController), labelColor: const Color(0xFF9575CD)),
        const SizedBox(height: 35),
        _sectionTitle("pets_section_health_status".tr(), Icons.medical_services_outlined, bgColor: const Color(0xFFB3E5FC)),
        _artisticoSelector(label: "pets_label_vaccinations".tr(), child: VaccinatoSelector(controller: vaccinatoController), labelColor: Colors.lightBlueAccent),
        const SizedBox(height: 25),
        _artisticoSelector(label: "pets_label_reproductive_status".tr(), child: StatoRiproduttivoSelector(controller: riproduttivoController), labelColor: const Color(0xFF4FC3F7)),
        const SizedBox(height: 25),
        _artisticoSelector(label: "pets_label_allergies".tr(), child: AllergieSelector(statoController: allergicoController, allergieController: allergieController), labelColor: Colors.orangeAccent),
        const SizedBox(height: 35),
        _sectionTitle("pets_section_notes_details".tr(), Icons.description_outlined, bgColor: const Color(0xFFFFE0B2)),
        _artisticoSelector(label: "pets_label_general_notes".tr(), child: NoteGeneraliSelector(controller: noteGeneraliController), labelColor: Colors.blueGrey[300]!),
      ],
    );
  }

  Widget _buildWeightCounter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labelBadge("pets_label_estimated_weight".tr(), color: const Color(0xFFFFD54F)),
        _neonWrapper(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.white, width: 2)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Flexible(child: Text(_pesoValue.toStringAsFixed(1), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: neonColor), overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 8),
              Row(mainAxisSize: MainAxisSize.min, children: [
                _counterBtn(Icons.remove, () => setState(() => _pesoValue = (_pesoValue - 0.1).clamp(0.1, 100.0))),
                const SizedBox(width: 15),
                _counterBtn(Icons.add, () => setState(() => _pesoValue = (_pesoValue + 0.1).clamp(0.1, 100.0))),
              ]),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _counterBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white10, shape: BoxShape.circle, border: Border.all(color: Colors.white30)),
        child: Icon(icon, size: 20, color: neonColor)
      )
    );
  }

  Widget _sectionTitle(String t, IconData i, {required Color bgColor}) => Container(
    margin: const EdgeInsets.only(bottom: 20, top: 10),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: bgColor.withOpacity(0.7),
      borderRadius: BorderRadius.circular(15),
      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
    ),
    child: Row(children: [
      Icon(i, color: Colors.black87, size: 24),
      const SizedBox(width: 12),
      Expanded(child: Text(t.toUpperCase(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.black87, letterSpacing: 1.2), overflow: TextOverflow.ellipsis))
    ]),
  );
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

        int type;
        double typeRand = random.nextDouble();
        if (typeRand < 0.25) type = 0;
        else if (typeRand < 0.35) type = 1;
        else if (typeRand < 0.55) type = 2;
        else if (typeRand < 0.80) type = 3;
        else type = 4;

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
        if (type == 0) _drawPaw(canvas, paint);
        else if (type == 1) _drawBone(canvas, paint);
        else if (type == 2) _drawFish(canvas, paint);
        else if (type == 3) _drawHeart(canvas, paint);
        else _drawYarnBall(canvas, paint);

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
  bool shouldRepaint(covariant AnimalCartoonPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
