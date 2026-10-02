import 'package:flutter/material.dart';
import 'package:petping/d_tab_sds/d_smarriti/addpet/lost_animal_data.dart';
import 'package:petping/d_tab_sds/d_smarriti/addpet/addanimalsmar/add_tre.dart';
import 'package:petping/d_tab_sds/d_smarriti/addpet/addanimalsmar/front/front_due.dart';

class AddDue extends StatefulWidget {
  final LostAnimalData data;

  const AddDue({super.key, required this.data});

  @override
  State<AddDue> createState() => _AddDueState();
}

class _AddDueState extends State<AddDue> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController microchipController;
  late TextEditingController coloreDominanteController;
  late TextEditingController coloreSecondarioController;
  late TextEditingController occhiColoreController;

  late TextEditingController orecchieGrandezzaController;
  late TextEditingController codaGrandezzaController;
  late TextEditingController scarNoteController;
  late bool haCicatrici;

  static const Color darkBrown = Color(0xFF4E342E);

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    microchipController = TextEditingController(text: widget.data.microchipNumero ?? '');
    coloreDominanteController = TextEditingController(text: widget.data.coloreDominante ?? '');
    coloreSecondarioController = TextEditingController(text: widget.data.coloreSecondario ?? '');
    occhiColoreController = TextEditingController(text: widget.data.occhiColore ?? '');

    orecchieGrandezzaController = TextEditingController(text: widget.data.orecchieGrandezza ?? '');
    codaGrandezzaController = TextEditingController(text: widget.data.codaGrandezza ?? '');
    scarNoteController = TextEditingController(text: widget.data.noteCicatrici ?? '');
    haCicatrici = widget.data.haCicatrici;
  }

  void _saveData() {
    widget.data.microchipNumero = microchipController.text.trim();
    widget.data.coloreDominante = coloreDominanteController.text;
    widget.data.coloreSecondario = coloreSecondarioController.text;
    widget.data.occhiColore = occhiColoreController.text;

    widget.data.orecchieGrandezza = orecchieGrandezzaController.text;
    widget.data.codaGrandezza = codaGrandezzaController.text;
    widget.data.haCicatrici = haCicatrici;
    widget.data.noteCicatrici = scarNoteController.text.trim();
  }

  void _goToNextStep() {
    if (_formKey.currentState!.validate()) {
      _saveData();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddTre(data: widget.data)),
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
    scarNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) _saveData(); 
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: darkBrown),
          centerTitle: true,
          title: const Text('DETTAGLI PET', style: TextStyle(fontWeight: FontWeight.w900, color: darkBrown, letterSpacing: 1.5, fontSize: 16)),
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFFDF7), Color(0xFFFFF4E1), Color(0xFFF5E6CC)],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: kToolbarHeight + 40, left: 20, right: 20, bottom: 40),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6), 
                    borderRadius: BorderRadius.circular(35),
                    border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
                    boxShadow: [
                      BoxShadow(color: darkBrown.withOpacity(0.05), blurRadius: 30, spreadRadius: 5)
                    ]
                  ),
                  child: AddDueFront(
                    formKey: _formKey,
                    microchipController: microchipController,
                    coloreDominanteController: coloreDominanteController,
                    coloreSecondarioController: coloreSecondarioController,
                    occhiColoreController: occhiColoreController,
                    orecchieGrandezzaController: orecchieGrandezzaController,
                    codaGrandezzaController: codaGrandezzaController,
                    scarNoteController: scarNoteController,
                    haCicatrici: haCicatrici,
                    onCicatriceChanged: (val) => setState(() => haCicatrici = val),
                    onNextStep: _goToNextStep,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
