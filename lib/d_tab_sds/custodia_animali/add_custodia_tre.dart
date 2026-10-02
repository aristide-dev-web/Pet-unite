import 'package:flutter/material.dart';
import 'package:petping/d_tab_sds/custodia_animali/custodia_animal_data.dart';
import 'package:petping/d_tab_sds/custodia_animali/add_custodia_quattro.dart';
import 'package:petping/d_tab_sds/custodia_animali/front/front_add_custodia_tre.dart';

class AddCustodiaTre extends StatefulWidget {
  final CustodiaAnimalData data;
  const AddCustodiaTre({super.key, required this.data});

  @override
  State<AddCustodiaTre> createState() => _AddCustodiaTreState();
}

class _AddCustodiaTreState extends State<AddCustodiaTre> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController viaController;
  late TextEditingController cittaController;
  late TextEditingController regioneController;
  late TextEditingController raccontoController;

  DateTime? selectedInizio;
  DateTime? selectedFine;

  double? _lat;
  double? _lng;

  @override
  void initState() {
    super.initState();
    viaController = TextEditingController(text: widget.data.via);
    cittaController = TextEditingController(text: widget.data.citta);
    regioneController = TextEditingController(text: widget.data.regione);
    raccontoController = TextEditingController(text: widget.data.raccontoDettagliato);
    
    _lat = widget.data.lat;
    _lng = widget.data.lng;
    selectedInizio = widget.data.dataInizio;
    selectedFine = widget.data.dataFine;
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

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.data.via = viaController.text;
      widget.data.citta = cittaController.text;
      widget.data.regione = regioneController.text;
      widget.data.lat = _lat;
      widget.data.lng = _lng;
      widget.data.raccontoDettagliato = raccontoController.text;
      widget.data.dataInizio = selectedInizio;
      widget.data.dataFine = selectedFine;

      Navigator.push(context, MaterialPageRoute(builder: (context) => AddCustodiaQuattro(data: widget.data)));
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
        title: const Text('STEP 3/3 - DETTAGLI', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2C3E50), fontSize: 16)),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE3F2FD), Color(0xFFF5F9FF)], // Gradiente Blu Sicurezza ripristinato
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: kToolbarHeight + 40, left: 20, right: 20, bottom: 40),
          child: FrontAddCustodiaTre(
            formKey: _formKey,
            viaController: viaController,
            cittaController: cittaController,
            regioneController: regioneController,
            raccontoController: raccontoController,
            selectedInizio: selectedInizio,
            selectedFine: selectedFine,
            onInizioChanged: (d) => setState(() => selectedInizio = d),
            onFineChanged: (d) => setState(() => selectedFine = d),
            onPositionConfirmed: _updatePosition,
            onSubmit: _submit,
            lat: _lat,
            lng: _lng,
          ),
        ),
      ),
    );
  }
}
