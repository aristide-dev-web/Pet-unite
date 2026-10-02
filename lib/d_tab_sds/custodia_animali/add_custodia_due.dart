import 'package:flutter/material.dart';
import 'package:petping/d_tab_sds/custodia_animali/custodia_animal_data.dart';
import 'package:petping/d_tab_sds/custodia_animali/add_custodia_tre.dart';
import 'package:petping/d_tab_sds/custodia_animali/front/front_add_custodia_due.dart';

class AddCustodiaDue extends StatefulWidget {
  final CustodiaAnimalData data;
  const AddCustodiaDue({super.key, required this.data});

  @override
  State<AddCustodiaDue> createState() => _AddCustodiaDueState();
}

class _AddCustodiaDueState extends State<AddCustodiaDue> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController colorDomController;
  late TextEditingController colorSecController;
  late TextEditingController occhiColoreController;
  late TextEditingController occhiFormaController;
  late TextEditingController orecchieController;
  late TextEditingController codaController;
  late TextEditingController noteParticolariController;
  late TextEditingController microchipController; // AGGIUNTO
  bool haCicatrici = false;

  @override
  void initState() {
    super.initState();
    colorDomController = TextEditingController(text: widget.data.coloreDominante);
    colorSecController = TextEditingController(text: widget.data.coloreSecondario);
    occhiColoreController = TextEditingController(text: widget.data.occhiColore);
    occhiFormaController = TextEditingController(text: widget.data.occhiForma);
    orecchieController = TextEditingController(text: widget.data.orecchieGrandezza);
    codaController = TextEditingController(text: widget.data.codaGrandezza);
    noteParticolariController = TextEditingController(text: widget.data.noteParticolari);
    microchipController = TextEditingController(text: widget.data.microchipNumero); // AGGIUNTO
    haCicatrici = widget.data.haCicatrici;
  }

  void _saveAndNext() {
    widget.data.coloreDominante = colorDomController.text;
    widget.data.coloreSecondario = colorSecController.text;
    widget.data.occhiColore = occhiColoreController.text;
    widget.data.occhiForma = occhiFormaController.text;
    widget.data.orecchieGrandezza = orecchieController.text;
    widget.data.codaGrandezza = codaController.text;
    widget.data.haCicatrici = haCicatrici;
    widget.data.noteParticolari = noteParticolariController.text;
    widget.data.microchipNumero = microchipController.text; // SALVATAGGIO

    Navigator.push(context, MaterialPageRoute(builder: (context) => AddCustodiaTre(data: widget.data)));
  }

  @override
  void dispose() {
    colorDomController.dispose();
    colorSecController.dispose();
    occhiColoreController.dispose();
    occhiFormaController.dispose();
    orecchieController.dispose();
    codaController.dispose();
    noteParticolariController.dispose();
    microchipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('STEP 2/3 - FISICO', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2C3E50), fontSize: 16)),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE3F2FD), Color(0xFFF5F9FF)], 
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: kToolbarHeight + 40, left: 20, right: 20, bottom: 40),
          child: FrontAddCustodiaDue(
            formKey: _formKey,
            colorDomController: colorDomController,
            colorSecController: colorSecController,
            occhiColoreController: occhiColoreController,
            occhiFormaController: occhiFormaController,
            orecchieController: orecchieController,
            codaController: codaController,
            noteParticolariController: noteParticolariController,
            microchipController: microchipController, // PASSAGGIO AL FRONT
            haCicatrici: haCicatrici,
            onCicatriciChanged: (v) => setState(() => haCicatrici = v),
            onNext: _saveAndNext,
          ),
        ),
      ),
    );
  }
}
