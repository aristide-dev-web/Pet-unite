import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petping/d_tab_sds/d_smarriti/addpet/lost_animal_data.dart';
import 'package:petping/d_tab_sds/d_smarriti/addpet/addanimalsmar/front/front_tre.dart';
import 'package:petping/d_tab_sds/d_smarriti/addpet/addanimalsmar/add_4.dart';

class AddTre extends StatefulWidget {
  final LostAnimalData data;

  const AddTre({super.key, required this.data});

  @override
  State<AddTre> createState() => _AddTreState();
}

class _AddTreState extends State<AddTre> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController viaController;
  late TextEditingController cittaController;
  late TextEditingController regioneController;
  late TextEditingController raccontoController;
  late TextEditingController rewardController;

  int? selectedDay;
  int? selectedMonth;
  int? selectedYear;

  double? _latitudine;
  double? _longitudine;

  static const Color darkBrown = Color(0xFF4E342E);

  @override
  void initState() {
    super.initState();
    viaController = TextEditingController(text: widget.data.via);
    cittaController = TextEditingController(text: widget.data.citta);
    regioneController = TextEditingController(text: widget.data.regione);
    raccontoController = TextEditingController(text: widget.data.raccontoDettagliato);
    rewardController = TextEditingController(text: widget.data.ricompensa);
    
    _latitudine = widget.data.lat;
    _longitudine = widget.data.lng;

    if (widget.data.dataSmarrimento != null) {
      try {
        final parts = widget.data.dataSmarrimento!.split('-');
        if (parts.length == 3) {
          selectedYear = int.tryParse(parts[0]);
          selectedMonth = int.tryParse(parts[1]);
          selectedDay = int.tryParse(parts[2]);
        }
      } catch (_) {}
    }
  }

  void _saveData() {
    widget.data.via = viaController.text;
    widget.data.citta = cittaController.text;
    widget.data.regione = regioneController.text;
    widget.data.lat = _latitudine;
    widget.data.lng = _longitudine;
    widget.data.raccontoDettagliato = raccontoController.text;
    widget.data.ricompensa = rewardController.text;
    widget.data.dataSmarrimento =
        selectedDay != null && selectedMonth != null && selectedYear != null
        ? '${selectedYear!}-${selectedMonth!.toString().padLeft(2, '0')}-${selectedDay!.toString().padLeft(2, '0')}'
        : widget.data.dataSmarrimento;
  }

  void _updatePositionFromFront(double lat, double lng, String via, String citta, String regione) {
    setState(() {
      _latitudine = lat;
      _longitudine = lng;
      viaController.text = via;
      cittaController.text = citta;
      regioneController.text = regione;
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _saveData();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddQuattro(data: widget.data)),
      );
    }
  }

  @override
  void dispose() {
    viaController.dispose();
    cittaController.dispose();
    regioneController.dispose();
    raccontoController.dispose();
    rewardController.dispose();
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
          title: const Text('STEP 3/3', style: TextStyle(fontWeight: FontWeight.w900, color: darkBrown, letterSpacing: 1.5, fontSize: 18)),
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
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), borderRadius: BorderRadius.circular(30)),
                  child: AddTreFront(
                    formKey: _formKey,
                    viaController: viaController,
                    cittaController: cittaController,
                    regioneController: regioneController,
                    raccontoController: raccontoController,
                    rewardController: rewardController,
                    selectedDay: selectedDay,
                    selectedMonth: selectedMonth,
                    selectedYear: selectedYear,
                    onDayChanged: (val) => setState(() => selectedDay = val),
                    onMonthChanged: (val) => setState(() => selectedMonth = val),
                    onYearChanged: (val) => setState(() => selectedYear = val),
                    onPositionConfirmed: _updatePositionFromFront,
                    onSubmit: _submit,
                    lat: _latitudine,
                    lng: _longitudine,
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
