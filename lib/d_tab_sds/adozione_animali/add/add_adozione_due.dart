import 'package:flutter/material.dart';
import 'package:petping/d_tab_sds/adozione_animali/adozione_animal_data.dart';
import 'package:petping/d_tab_sds/adozione_animali/add/add_adozione_tre.dart';
import 'package:petping/d_tab_sds/adozione_animali/front/front_add_adozione_due.dart';

class AddAdozioneDue extends StatefulWidget {
  final AdozioneAnimalData data;

  const AddAdozioneDue({super.key, required this.data});

  @override
  State<AddAdozioneDue> createState() => _AddAdozioneDueState();
}

class _AddAdozioneDueState extends State<AddAdozioneDue> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController microchipController;
  late TextEditingController coloreDominanteController;
  late TextEditingController coloreSecondarioController;
  late TextEditingController occhiColoreController;
  late TextEditingController orecchieGrandezzaController;
  late TextEditingController codaGrandezzaController;

  // Nuovi controller per note
  late TextEditingController vaccinatoNoteController;
  late TextEditingController sverminatoNoteController;
  late TextEditingController sterilizzatoNoteController;
  late TextEditingController cicatriciNoteController;
  late TextEditingController allergieNoteController;

  late bool vaccinato;
  late bool sverminato;
  late bool sterilizzato;
  late bool haCicatrici;
  late bool haAllergie;

  static const Color darkBlue = Color(0xFF2C3E50);

  @override
  void initState() {
    super.initState();
    microchipController = TextEditingController(text: widget.data.microchipNumero ?? '');
    coloreDominanteController = TextEditingController(text: widget.data.coloreDominante ?? '');
    coloreSecondarioController = TextEditingController(text: widget.data.coloreSecondario ?? '');
    occhiColoreController = TextEditingController(text: widget.data.occhiColore ?? '');
    orecchieGrandezzaController = TextEditingController(text: widget.data.orecchieGrandezza ?? '');
    codaGrandezzaController = TextEditingController(text: widget.data.codaGrandezza ?? '');

    vaccinatoNoteController = TextEditingController(text: widget.data.vaccinatoNote ?? '');
    sverminatoNoteController = TextEditingController(text: widget.data.sverminatoNote ?? '');
    sterilizzatoNoteController = TextEditingController(text: widget.data.sterilizzatoNote ?? '');
    cicatriciNoteController = TextEditingController(text: widget.data.cicatriciNote ?? '');
    allergieNoteController = TextEditingController(text: widget.data.allergieNote ?? '');

    vaccinato = widget.data.vaccinato;
    sverminato = widget.data.sverminato;
    sterilizzato = widget.data.sterilizzato;
    haCicatrici = widget.data.haCicatrici;
    haAllergie = widget.data.haAllergie;
  }

  void _saveData() {
    widget.data.microchipNumero = microchipController.text.trim();
    widget.data.coloreDominante = coloreDominanteController.text;
    widget.data.coloreSecondario = coloreSecondarioController.text;
    widget.data.occhiColore = occhiColoreController.text;
    widget.data.orecchieGrandezza = orecchieGrandezzaController.text;
    widget.data.codaGrandezza = codaGrandezzaController.text;

    widget.data.vaccinato = vaccinato;
    widget.data.vaccinatoNote = vaccinatoNoteController.text;
    widget.data.sverminato = sverminato;
    widget.data.sverminatoNote = sverminatoNoteController.text;
    widget.data.sterilizzato = sterilizzato;
    widget.data.sterilizzatoNote = sterilizzatoNoteController.text;
    widget.data.haCicatrici = haCicatrici;
    widget.data.cicatriciNote = cicatriciNoteController.text;
    widget.data.haAllergie = haAllergie;
    widget.data.allergieNote = allergieNoteController.text;
  }

  void _goToNext() {
    if (_formKey.currentState!.validate()) {
      _saveData();
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => AddAdozioneTre(data: widget.data),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeOutQuart;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(position: animation.drive(tween), child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  @override
  void dispose() {
    microchipController.dispose();
    coloreDominanteController.dispose();
    coloreSecondarioController.dispose();
    occhiColoreController.dispose();
    orecchieGrandezzaController.dispose();
    codaGrandezzaController.dispose();
    vaccinatoNoteController.dispose();
    sverminatoNoteController.dispose();
    sterilizzatoNoteController.dispose();
    cicatriciNoteController.dispose();
    allergieNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('PASSO 2/3', style: TextStyle(fontWeight: FontWeight.w900, color: darkBlue, fontSize: 16)),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F5E9), Color(0xFFF1F8E9)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 100, left: 20, right: 20),
          child: FrontAddAdozioneDue(
            formKey: _formKey,
            microchipController: microchipController,
            coloreDominanteController: coloreDominanteController,
            coloreSecondarioController: coloreSecondarioController,
            occhiColoreController: occhiColoreController,
            orecchieGrandezzaController: orecchieGrandezzaController,
            codaGrandezzaController: codaGrandezzaController,
            vaccinato: vaccinato,
            onVaccinatoChanged: (v) => setState(() => vaccinato = v),
            vaccinatoNoteController: vaccinatoNoteController,
            sverminato: sverminato,
            onSverminatoChanged: (v) => setState(() => sverminato = v),
            sverminatoNoteController: sverminatoNoteController,
            sterilizzato: sterilizzato,
            onSterilizzatoChanged: (v) => setState(() => sterilizzato = v),
            sterilizzatoNoteController: sterilizzatoNoteController,
            haCicatrici: haCicatrici,
            onCicatriciChanged: (v) => setState(() => haCicatrici = v),
            cicatriciNoteController: cicatriciNoteController,
            haAllergie: haAllergie,
            onAllergieChanged: (v) => setState(() => haAllergie = v),
            allergieNoteController: allergieNoteController,
            onNext: _goToNext,
          ),
        ),
      ),
    );
  }
}
