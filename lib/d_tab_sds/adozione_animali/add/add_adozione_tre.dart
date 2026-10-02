import 'package:flutter/material.dart';
import 'package:petping/d_tab_sds/adozione_animali/adozione_animal_data.dart';
import 'package:petping/d_tab_sds/adozione_animali/add/add_adozione_quattro.dart';
import 'package:petping/d_tab_sds/adozione_animali/front/front_add_adozione_tre.dart';

class AddAdozioneTre extends StatefulWidget {
  final AdozioneAnimalData data;

  const AddAdozioneTre({super.key, required this.data});

  @override
  State<AddAdozioneTre> createState() => _AddAdozioneTreState();
}

class _AddAdozioneTreState extends State<AddAdozioneTre> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController viaController;
  late TextEditingController cittaController;
  late TextEditingController regioneController;
  late TextEditingController raccontoController;

  double? _lat;
  double? _lng;

  static const Color darkBlue = Color(0xFF2C3E50);

  @override
  void initState() {
    super.initState();
    viaController = TextEditingController(text: widget.data.via);
    cittaController = TextEditingController(text: widget.data.citta);
    regioneController = TextEditingController(text: widget.data.regione);
    raccontoController = TextEditingController(text: widget.data.raccontoDettagliato);
    _lat = widget.data.lat;
    _lng = widget.data.lng;
  }

  void _updatePosition(double lat, double lng, String via, String citta, String regione) {
    setState(() {
      _lat = lat;
      _lng = lng;
      viaController.text = via;
      cittaController.text = citta;
      regioneController.text = regione;
    });
  }

  void _saveData() {
    widget.data.via = viaController.text;
    widget.data.citta = cittaController.text;
    widget.data.regione = regioneController.text;
    widget.data.lat = _lat;
    widget.data.lng = _lng;
    widget.data.raccontoDettagliato = raccontoController.text;
  }

  void _goToNext() {
    if (_formKey.currentState!.validate()) {
      _saveData();
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => AddAdozioneQuattro(data: widget.data),
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
    viaController.dispose();
    cittaController.dispose();
    regioneController.dispose();
    raccontoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('PASSO 3/4', style: TextStyle(fontWeight: FontWeight.w900, color: darkBlue, fontSize: 16)),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 120, left: 20, right: 20, bottom: 40),
          child: FrontAddAdozioneTre(
            formKey: _formKey,
            viaController: viaController,
            cittaController: cittaController,
            regioneController: regioneController,
            raccontoController: raccontoController,
            onPositionConfirmed: _updatePosition,
            onNext: _goToNext,
            lat: _lat,
            lng: _lng,
          ),
        ),
      ),
    );
  }
}
