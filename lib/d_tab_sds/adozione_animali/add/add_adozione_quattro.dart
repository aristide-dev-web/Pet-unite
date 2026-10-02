import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petping/d_tab_sds/adozione_animali/adozione_animal_data.dart';
import 'package:petping/d_tab_sds/adozione_animali/front/front_add_adozione_quattro.dart';
import 'package:petping/utils/prefisso.dart';
import 'package:easy_localization/easy_localization.dart';

class AddAdozioneQuattro extends StatefulWidget {
  final AdozioneAnimalData data;

  const AddAdozioneQuattro({super.key, required this.data});

  @override
  State<AddAdozioneQuattro> createState() => _AddAdozioneQuattroState();
}

class _AddAdozioneQuattroState extends State<AddAdozioneQuattro> {
  static const Color greenHope = Color(0xFF27AE60);
  static const Color darkBlue = Color(0xFF2C3E50);
  
  // CARD DATA
  final List<TextEditingController> _phoneCard = [];
  final List<String> _prefixesCard = [];
  final List<TextEditingController> _whatsappCard = [];
  final List<String> _whatsappPrefixesCard = [];
  final List<TextEditingController> _emailCard = [];
  bool _mostraContattiCard = true;

  // BIO DATA
  final List<TextEditingController> _phoneBio = [];
  final List<String> _prefixesBio = [];
  final List<TextEditingController> _whatsappBio = [];
  final List<String> _whatsappPrefixesBio = [];
  final List<TextEditingController> _emailBio = [];
  bool _aggiornaContattiBio = false;
  
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _caricaDatiEsistenti();
  }

  Future<void> _caricaDatiEsistenti() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _initVuoti();
      return;
    }
    final doc = await FirebaseFirestore.instance.collection('utenti').doc(user.uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      final List<dynamic> emails = data['emails'] ?? [];
      final List<dynamic> telefoni = data['telefoni'] ?? [];
      final dynamic whatsappData = data['whatsapp'];
      
      setState(() {
        if (emails.isNotEmpty) {
          for (var e in emails) {
            _emailCard.add(TextEditingController(text: e.toString()));
            _emailBio.add(TextEditingController(text: e.toString()));
          }
        } else {
          _emailCard.add(TextEditingController());
          _emailBio.add(TextEditingController());
        }
        
        if (telefoni.isNotEmpty) {
          for (var t in telefoni) {
            final split = PrefixSelector.splitPhone(t.toString());
            _phoneCard.add(TextEditingController(text: split["number"]));
            _prefixesCard.add(split["prefix"]!);
            _phoneBio.add(TextEditingController(text: split["number"]));
            _prefixesBio.add(split["prefix"]!);
          }
        } else {
          _phoneCard.add(TextEditingController());
          _prefixesCard.add("+39");
          _phoneBio.add(TextEditingController());
          _prefixesBio.add("+39");
        }

        if (whatsappData != null) {
          final List<dynamic> wsList = whatsappData is List ? whatsappData : [whatsappData];
          for (var w in wsList) {
            final split = PrefixSelector.splitPhone(w.toString());
            _whatsappCard.add(TextEditingController(text: split["number"]));
            _whatsappPrefixesCard.add(split["prefix"]!);
            _whatsappBio.add(TextEditingController(text: split["number"]));
            _whatsappPrefixesBio.add(split["prefix"]!);
          }
        } else {
          _whatsappCard.add(TextEditingController());
          _whatsappPrefixesCard.add("+39");
          _whatsappBio.add(TextEditingController());
          _whatsappPrefixesBio.add("+39");
        }
      });
    } else {
      _initVuoti();
    }
  }

  void _initVuoti() {
    setState(() {
      _phoneCard.add(TextEditingController()); _prefixesCard.add("+39");
      _phoneBio.add(TextEditingController()); _prefixesBio.add("+39");
      _whatsappCard.add(TextEditingController()); _whatsappPrefixesCard.add("+39");
      _whatsappBio.add(TextEditingController()); _whatsappPrefixesBio.add("+39");
      _emailCard.add(TextEditingController());
      _emailBio.add(TextEditingController());
    });
  }

  @override
  void dispose() {
    for (var c in [..._phoneCard, ..._emailCard, ..._whatsappCard, ..._phoneBio, ..._emailBio, ..._whatsappBio]) c.dispose();
    super.dispose();
  }

  Future<void> _submitFinal() async {
    setState(() => _isSaving = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final cardPhones = <String>[];
      for(int i=0; i<_phoneCard.length; i++) {
        String n = _phoneCard[i].text.trim();
        if (n.isNotEmpty) cardPhones.add("${_prefixesCard[i]}$n");
      }
      final cardWs = <String>[];
      for(int i=0; i<_whatsappCard.length; i++) {
        String n = _whatsappCard[i].text.trim();
        if (n.isNotEmpty) cardWs.add("${_whatsappPrefixesCard[i]}$n");
      }
      final cardEmails = _emailCard.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();
      
      final bioPhones = <String>[];
      for(int i=0; i<_phoneBio.length; i++) {
        String n = _phoneBio[i].text.trim();
        if (n.isNotEmpty) bioPhones.add("${_prefixesBio[i]}$n");
      }
      final bioWs = <String>[];
      for(int i=0; i<_whatsappBio.length; i++) {
        String n = _whatsappBio[i].text.trim();
        if (n.isNotEmpty) bioWs.add("${_whatsappPrefixesBio[i]}$n");
      }
      final bioEmails = _emailBio.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();

      List<String> imageUrls = [];
      if (widget.data.immagini != null) {
        for (int i = 0; i < widget.data.immagini!.length; i++) {
          String path = 'adozioni/${user.uid}_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
          TaskSnapshot snap = await FirebaseStorage.instance.ref().child(path).putFile(widget.data.immagini![i]);
          imageUrls.add(await snap.ref.getDownloadURL());
        }
      }

      await FirebaseFirestore.instance.collection('animali_adozione').add({
        'uid_utente': user.uid,
        'nome_utente': user.displayName ?? 'Utente PetPing',
        'nome': widget.data.nome,
        'specie': widget.data.tipo,
        'razza': widget.data.razza,
        'sesso': widget.data.sesso,
        'eta': widget.data.eta,
        'immagini': imageUrls,
        'immagine': imageUrls.isNotEmpty ? imageUrls[0] : '',
        'colore_dominante': widget.data.coloreDominante,
        'colore_secondario': widget.data.coloreSecondario,
        'occhi_colore': widget.data.occhiColore,
        'orecchie': widget.data.orecchieGrandezza,
        'coda': widget.data.codaGrandezza,
        'microchip': widget.data.microchipNumero,
        'vaccinato': widget.data.vaccinato,
        'vaccinatoNote': widget.data.vaccinatoNote,
        'sverminato': widget.data.sverminato,
        'sverminatoNote': widget.data.sverminatoNote,
        'sterilizzato': widget.data.sterilizzato,
        'sterilizzatoNote': widget.data.sterilizzatoNote,
        'haCicatrici': widget.data.haCicatrici,
        'cicatriciNote': widget.data.cicatriciNote,
        'haAllergie': widget.data.haAllergie,
        'allergieNote': widget.data.allergieNote,
        'via': widget.data.via,
        'citta': widget.data.citta,
        'regione': widget.data.regione,
        'posizione': GeoPoint(widget.data.lat ?? 0, widget.data.lng ?? 0),
        'lat': widget.data.lat,
        'lng': widget.data.lng,
        'descrizione': widget.data.raccontoDettagliato,
        'contatti': {
          'telefoni': cardPhones,
          'whatsapp': cardWs,
          'emails': cardEmails,
          'privacy': _mostraContattiCard,
        },
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'disponibile',
      });

      if (_aggiornaContattiBio) {
        await FirebaseFirestore.instance.collection('utenti').doc(user.uid).update({
          'telefoni': bioPhones,
          'emails': bioEmails,
          'whatsapp': bioWs,
        });
      }
      
      setState(() => _isSaving = false);
      if (mounted) _showSuccessDialog();

    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('snack_error_msg'.tr(args: [e.toString()]))));
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Text('custodia_add_success_title'.tr(), style: const TextStyle(fontWeight: FontWeight.w900, color: greenHope)),
        content: Text('adozione_add_quattro_success_msg'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).popUntil((route) => route.isFirst),
            child: Text('age_got_it'.tr().toUpperCase(), style: const TextStyle(color: darkBlue, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text('profile_tab_contacts'.tr(), style: const TextStyle(color: darkBlue, fontWeight: FontWeight.w900, fontSize: 14)),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: FrontAddAdozioneQuattro(
              phoneCard: _phoneCard,
              prefixesCard: _prefixesCard,
              whatsappCard: _whatsappCard,
              whatsappPrefixesCard: _whatsappPrefixesCard,
              emailCard: _emailCard,
              mostraContattiCard: _mostraContattiCard,
              onToggleCard: (v) => setState(() => _mostraContattiCard = v),
              phoneBio: _phoneBio,
              prefixesBio: _prefixesBio,
              whatsappBio: _whatsappBio,
              whatsappPrefixesBio: _whatsappPrefixesBio,
              emailBio: _emailBio,
              aggiornaContattiBio: _aggiornaContattiBio,
              onToggleBio: (v) => setState(() => _aggiornaContattiBio = v),
              onAddPhone: (isBio) => setState(() { (isBio ? _phoneBio : _phoneCard).add(TextEditingController()); (isBio ? _prefixesBio : _prefixesCard).add("+39"); }),
              onAddWs: (isBio) => setState(() { (isBio ? _whatsappBio : _whatsappCard).add(TextEditingController()); (isBio ? _whatsappPrefixesBio : _whatsappPrefixesCard).add("+39"); }),
              onAddEmail: (isBio) => setState(() => (isBio ? _emailBio : _emailCard).add(TextEditingController())),
              onRemovePhone: (i, isBio) => setState(() { (isBio ? _phoneBio : _phoneCard).removeAt(i); (isBio ? _prefixesBio : _prefixesCard).removeAt(i); }),
              onRemoveWs: (i, isBio) => setState(() { (isBio ? _whatsappBio : _whatsappCard).removeAt(i); (isBio ? _whatsappPrefixesBio : _whatsappPrefixesCard).removeAt(i); }),
              onRemoveEmail: (i, isBio) => setState(() => (isBio ? _emailBio : _emailCard).removeAt(i)),
              onSubmit: _submitFinal,
            ),
          ),
          if (_isSaving) Container(color: Colors.black45, child: const Center(child: CircularProgressIndicator(color: greenHope))),
          _buildBottomAction(),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.white, Colors.white.withOpacity(0)])),
        child: SizedBox(
          width: double.infinity, 
          height: 60, 
          child: ElevatedButton(
            onPressed: _isSaving ? null : _submitFinal, 
            style: ElevatedButton.styleFrom(backgroundColor: greenHope, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))), 
            child: Text('adozione_add_quattro_publish_btn'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1))
          )
        ),
      ),
    );
  }
}
