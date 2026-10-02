import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:petping/petsitting/models/sitter_model.dart';
import 'package:petping/utils/firebase_storage_helper.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:petping/models/user_profile_model.dart';
import 'sitter_registration_view.dart';

class SitterRegistrationScreen extends StatefulWidget {
  final bool isEditing;
  final SitterProfile? sitterProfile;
  final int? initialStep;

  const SitterRegistrationScreen({
    super.key,
    this.isEditing = false,
    this.sitterProfile,
    this.initialStep,
  });

  @override
  State<SitterRegistrationScreen> createState() => _SitterRegistrationScreenState();
}

class _SitterRegistrationScreenState extends State<SitterRegistrationScreen> {
  late final PageController _pageController;
  late int _currentStep;
  bool _isLoading = true;

  final Color primaryIndigo = const Color(0xFF6366F1);
  final Color bgLight = const Color(0xFFF8FAFC);
  final Color textColor = const Color(0xFF1E293B);

  // Controllers
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cognomeController = TextEditingController();
  final TextEditingController _dataNascitaController = TextEditingController();
  final TextEditingController _bioBreveController = TextEditingController();
  final TextEditingController _nazioneController = TextEditingController();
  final TextEditingController _regioneController = TextEditingController();
  final TextEditingController _cittaController = TextEditingController();   
  final TextEditingController _indirizzoController = TextEditingController(); 
  final TextEditingController _quartiereController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController(); 
  final TextEditingController _anniEsperienzaController = TextEditingController();
  final TextEditingController _descrizioneAltroController = TextEditingController();
  final TextEditingController _attrezzaturaAltroController = TextEditingController();

  // State
  String _telefonoPrefix = "+39";
  double? _lat;
  double? _lng;
  bool _emailVerified = false;
  bool _phoneVerified = false;
  bool _identityVerified = false;
  File? _fotoProfiloPro;
  String? _existingFotoUrl;
  File? _docFronte; 
  List<String> _specieExperience = [];
  bool _bisogniSpeciali = false;
  bool _somministrazioneFarmaci = false;
  bool _gestioneAnimaliDifficili = false;
  bool _prenotazioneLastMinute = false;
  double _raggioKm = 10.0;
  final List<Map<String, dynamic>> _certifications = [];
  List<String> _competenze = []; 
  Map<String, bool> _attrezzatura = {}; 

  final Map<String, bool> _serviziAttivi = {
    'Visita a domicilio': false,
    'Pensione Pet Stop': false,
    'Passeggiata': false,
    'Somministrazione farmaci': false,
    'Bagnetto e asciugatura': false,
    'Toilettatura professionale': false,
    'Taxi Pet': false,
  };
  final Map<String, double> _serviziPrezzi = {};
  final Map<String, int> _serviziMaxAnimali = {};
  final Map<String, String> _serviziOrari = {};
  final Map<String, String> _serviziNote = {};
  final Map<String, String> _serviziDurata = {};
  final Map<String, double> _serviziWeekendExtra = {};
  final Map<String, bool> _serviziWeekendAttivi = {};
  final Map<String, double> _serviziNotturnoExtra = {};
  final Map<String, bool> _serviziNotturnoAttivi = {};
  final Map<String, bool> _serviziAsciugaturaAttivi = {};
  final Map<String, double> _serviziTaxiPet = {};
  final Map<String, String> _serviziCheckIn = {};
  final Map<String, String> _serviziCheckOut = {};
  final Map<String, List<String>> _serviziTaglie = {};

  int _boardingDailyWalks = 3;
  List<String> _boardingToiletOptions = [];
  String _boardingToiletFrequency = 'Ogni 6 ore';
  String _boardingHygieneDescription = '';
  List<String> _boardingSpecialNeeds = [];

  double _taxiBaseFare = 0.0;
  double _taxiPricePerKm = 0.0;
  double _taxiPricePerMin = 0.0;
  double _taxiNightSurcharge = 0.0;
  List<String> _taxiSpecieAccettate = [];

  String _tipoCasa = '';
  bool _giardino = false;
  bool _altriAnimaliInCasa = false;
  bool _bambiniInCasa = false;
  bool _ambienteSicuro = false;
  final List<File?> _fotoCasaFiles = [];
  final List<String> _existingFotoCasaUrls = [];
  final List<File?> _fotoInserzioneFiles = [];
  final List<String> _existingFotoInserzioneUrls = [];

  final List<String> _razzeEscluse = [];
  final List<String> _comportamentiEsclusi = [];
  
  String? _stripeAccountId;
  bool _stripeOnboardingComplete = false;

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep ?? 0; 
    _pageController = PageController(initialPage: _currentStep);

    if (widget.sitterProfile != null) {
      _popolaCampi(widget.sitterProfile!);
      _isLoading = false;
       _emailVerified = true;
      _phoneVerified = true;
      _identityVerified = widget.sitterProfile!.verificato;
    } else {
      _caricaDatiEsistentiBios();
    }
  }

  Future<void> _caricaDatiEsistentiBios() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      final userBox = Hive.box<UserProfile>('user_profile_box');
      final profile = userBox.get(user.uid);
      if (profile != null) {
        setState(() {
          _nicknameController.text = profile.username;
          _nomeController.text = profile.nome;
          _cognomeController.text = profile.cognome;
          _emailController.text = profile.emails.isNotEmpty ? profile.emails.first : user.email ?? '';
          _existingFotoUrl = profile.fotoUrl;
          _dataNascitaController.text = profile.dataNascita;
          _cittaController.text = profile.citta;
          _indirizzoController.text = profile.indirizzo;
          _quartiereController.text = profile.quartiere;
          _nazioneController.text = profile.nazione;
          _regioneController.text = profile.regione;
          _lat = profile.lat;
          _lng = profile.lng;
          if (profile.telefoni.isNotEmpty) {
            String tel = profile.telefoni.first;
            if (tel.startsWith("+")) {
              _telefonoPrefix = tel.substring(0, 3);
              _telefonoController.text = tel.substring(3);
            } else {
              _telefonoController.text = tel;
            }
          }
        });

        if (profile.isPetSitter) {
          final sitterBox = Hive.box<SitterProfile>('sitters_box');
          SitterProfile? sitter = sitterBox.get(user.uid);
          if (sitter == null) {
            final doc = await FirebaseFirestore.instance.collection('sitters').doc(user.uid).get();
            if (doc.exists) {
              sitter = SitterProfile.fromFirestore(doc);
              await sitterBox.put(user.uid, sitter);
            }
          }
          if (sitter != null) {
            _popolaCampi(sitter);
          }
        }
      }
    } catch (e) {
      debugPrint("Errore Bio: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _popolaCampi(SitterProfile sitter) {
    setState(() {
      _nicknameController.text = sitter.username;
      _nomeController.text = sitter.nome;
      _cognomeController.text = sitter.cognome;
      _dataNascitaController.text = sitter.dataNascita;
      _bioBreveController.text = sitter.bio;
      _nazioneController.text = sitter.nazione;
      _regioneController.text = sitter.regione;
      _cittaController.text = sitter.citta;
      _indirizzoController.text = sitter.indirizzo;
      _quartiereController.text = sitter.quartiere;
      _emailController.text = sitter.email;
      if (sitter.telefono.startsWith("+")) {
        _telefonoPrefix = sitter.telefono.substring(0, 3);
        _telefonoController.text = sitter.telefono.substring(3);
      } else {
        _telefonoController.text = sitter.telefono;
      }
      _lat = sitter.lat;
      _lng = sitter.lng;
      _existingFotoUrl = sitter.fotoUrl;
      _anniEsperienzaController.text = sitter.anniEsperienza.toString();
      _specieExperience = List<String>.from(sitter.specieEsperienza);
      _bisogniSpeciali = sitter.bisogniSpeciali;
      _somministrazioneFarmaci = sitter.somministrazioneFarmaci;
      _gestioneAnimaliDifficili = sitter.gestioneAnimaliDifficili;
      _prenotazioneLastMinute = sitter.prenotazioneLastMinute;
      _raggioKm = sitter.raggioKm;
      _competenze = List<String>.from(sitter.competenze);
      _certifications.clear();
      _certifications.addAll(sitter.certificazioni.map((e) => Map<String, dynamic>.from(e)));

      _serviziPrezzi.clear();
      _serviziPrezzi.addAll(sitter.serviziPrezzi);
      _serviziMaxAnimali.clear();
      _serviziMaxAnimali.addAll(sitter.maxAnimali);
      _serviziOrari.clear();
      _serviziOrari.addAll(sitter.orariDisponibili);
      _serviziTaglie.clear();
      _serviziTaglie.addAll(sitter.serviziTaglie);
      _serviziNote.clear();
      _serviziNote.addAll(sitter.serviziNote);
      _serviziDurata.clear();
      _serviziDurata.addAll(sitter.serviziDurata);
      _serviziWeekendAttivi.clear();
      _serviziWeekendAttivi.addAll(sitter.serviziWeekendAttivi);
      _serviziWeekendExtra.clear();
      _serviziWeekendExtra.addAll(sitter.serviziWeekendExtra);
      _serviziNotturnoAttivi.clear();
      _serviziNotturnoAttivi.addAll(sitter.serviziNotturnoAttivi);
      _serviziNotturnoExtra.clear();
      _serviziNotturnoExtra.addAll(sitter.serviziNotturnoExtra);
      _serviziCheckIn.clear();
      _serviziCheckIn.addAll(sitter.serviziCheckIn);
      _serviziCheckOut.clear();
      _serviziCheckOut.addAll(sitter.serviziCheckOut);
      _serviziTaxiPet.clear();
      _serviziTaxiPet.addAll(sitter.serviziTaxiPet);

      _existingFotoInserzioneUrls.clear();
      _existingFotoInserzioneUrls.addAll(sitter.fotoChiSei.where((url) => url != sitter.fotoUrl));

      _existingFotoCasaUrls.clear();
      _existingFotoCasaUrls.addAll(sitter.fotoCasa);

      _razzeEscluse.clear();
      _razzeEscluse.addAll(sitter.razzeEscluse);
      _comportamentiEsclusi.clear();
      _comportamentiEsclusi.addAll(sitter.comportamentiEsclusi);
      _attrezzatura = Map<String, bool>.from(sitter.attrezzatura);
      _attrezzaturaAltroController.text = sitter.attrezzaturaAltro;
      _stripeAccountId = sitter.stripeAccountId;
      _stripeOnboardingComplete = sitter.stripeOnboardingComplete;
      
      _tipoCasa = sitter.tipoCasa;
      _giardino = sitter.giardino;
      _altriAnimaliInCasa = sitter.altriAnimali;
      _bambiniInCasa = sitter.bambini;
      _ambienteSicuro = sitter.ambienteSicuro;

      if (sitter.serviziAttivi.isNotEmpty) {
        for (var key in _serviziAttivi.keys) {
          _serviziAttivi[key] = sitter.serviziAttivi.contains(key);
        }
      }
    });
  }

  Future<void> _salvaSuHive(SitterProfile sitter) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final box = Hive.box<SitterProfile>('sitters_box');
      await box.put(user.uid, sitter);
    } catch (e) {
      debugPrint("⚠️ Errore Hive: $e");
    }
  }

  SitterProfile _createSitterProfile(String uid, String? fotoUrlFinal) {
    return SitterProfile(
      uid: uid,
      username: _nicknameController.text,
      nome: _nomeController.text,
      cognome: _cognomeController.text,
      email: _emailController.text,
      telefono: _telefonoPrefix + _telefonoController.text,
      dataNascita: _dataNascitaController.text,
      eta: _calculateAge(_dataNascitaController.text),
      citta: _cittaController.text,
      indirizzo: _indirizzoController.text,
      quartiere: _quartiereController.text,
      regione: _regioneController.text,
      nazione: _nazioneController.text,
      lat: _lat,
      lng: _lng,
      bio: _bioBreveController.text,
      fotoUrl: fotoUrlFinal ?? '',
      verificato: _identityVerified,
      anniEsperienza: int.tryParse(_anniEsperienzaController.text) ?? 0,
      specieEsperienza: List<String>.from(_specieExperience),
      bisogniSpeciali: _bisogniSpeciali,
      somministrazioneFarmaci: _somministrazioneFarmaci,
      gestioneAnimaliDifficili: _gestioneAnimaliDifficili,
      prenotazioneLastMinute: _prenotazioneLastMinute,
      raggioKm: _raggioKm,
      competenze: List<String>.from(_competenze),
      certificazioni: _certifications.map((e) => Map<String, dynamic>.from(e)..remove('file')).toList(),
      serviziAttivi: _serviziAttivi.entries.where((e) => e.value).map((e) => e.key).toList(),
      serviziPrezzi: Map<String, double>.from(_serviziPrezzi),
      serviziTaglie: Map<String, List<String>>.from(_serviziTaglie),
      serviziNote: Map<String, String>.from(_serviziNote),
      serviziDurata: Map<String, String>.from(_serviziDurata),
      maxAnimali: Map<String, int>.from(_serviziMaxAnimali),
      orariDisponibili: Map<String, String>.from(_serviziOrari),
      serviziWeekendAttivi: Map<String, bool>.from(_serviziWeekendAttivi),
      serviziWeekendExtra: Map<String, double>.from(_serviziWeekendExtra),
      serviziNotturnoAttivi: Map<String, bool>.from(_serviziNotturnoAttivi),
      serviziNotturnoExtra: Map<String, double>.from(_serviziNotturnoExtra),
      serviziCheckIn: Map<String, String>.from(_serviziCheckIn),
      serviziCheckOut: Map<String, String>.from(_serviziCheckOut),
      serviziTaxiPet: Map<String, double>.from(_serviziTaxiPet),
      tipoCasa: _tipoCasa,
      giardino: _giardino,
      altriAnimali: _altriAnimaliInCasa,
      bambini: _bambiniInCasa,
      ambienteSicuro: _ambienteSicuro,
      fotoCasa: List<String>.from(_existingFotoCasaUrls),
      fotoChiSei: List<String>.from(_existingFotoInserzioneUrls),
      razzeEscluse: List<String>.from(_razzeEscluse),
      comportamentiEsclusi: List<String>.from(_comportamentiEsclusi),
      attrezzatura: Map<String, bool>.from(_attrezzatura),
      attrezzaturaAltro: _attrezzaturaAltroController.text,
      stripeAccountId: _stripeAccountId,
      stripeOnboardingComplete: _stripeOnboardingComplete,
    );
  }

  int _calculateAge(String birthDateStr) {
    try {
      DateTime birthDate = DateFormat('dd/MM/yyyy').parse(birthDateStr);
      int age = DateTime.now().year - birthDate.year;
      if (DateTime.now().month < birthDate.month || (DateTime.now().month == birthDate.month && DateTime.now().day < birthDate.day)) age--;
      return age;
    } catch (_) {
      return 0;
    }
  }

  Future<void> _uploadMultiFotoInserzione(List<File> files) async {
    setState(() => _isLoading = true);
    try {
      for (var file in files) {
        String? url = await FirebaseStorageHelper.uploadImage(file, 'foto_inserzione');
        if (url != null) setState(() => _existingFotoInserzioneUrls.add(url));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadMultiFotoCasa(List<File> files) async {
    setState(() => _isLoading = true);
    try {
      for (var file in files) {
        String? url = await FirebaseStorageHelper.uploadImage(file, 'foto_casa');
        if (url != null) setState(() => _existingFotoCasaUrls.add(url));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _salvaTutto() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() => _isLoading = true);
    try {
      String? fotoUrlFinal = _existingFotoUrl;
      if (_fotoProfiloPro != null && await _fotoProfiloPro!.exists()) {
        fotoUrlFinal = await FirebaseStorageHelper.uploadImage(_fotoProfiloPro!, 'profili_sitter');
      }
      List<Map<String, dynamic>> certificazioniFinali = [];
      for (var cert in _certifications) {
        var certMap = Map<String, dynamic>.from(cert);
        if (certMap['file'] != null && certMap['file'] is File) {
          File f = certMap['file'];
          if (await f.exists()) {
            String? url = await FirebaseStorageHelper.uploadImage(f, 'certificazioni');
            certMap['fileUrl'] = url;
          }
        }
        certMap.remove('file');
        certificazioniFinali.add(certMap);
      }
      final sitterBase = _createSitterProfile(user.uid, fotoUrlFinal);
      final finalSitter = sitterBase.copyWith(
        fotoCasa: _existingFotoCasaUrls,
        fotoChiSei: _existingFotoInserzioneUrls,
        certificazioni: certificazioniFinali,
        competenze: List<String>.from(_competenze),
        somministrazioneFarmaci: _somministrazioneFarmaci,
        bisogniSpeciali: _bisogniSpeciali,
        gestioneAnimaliDifficili: _gestioneAnimaliDifficili,
        specieEsperienza: List<String>.from(_specieExperience),
        attrezzatura: Map<String, bool>.from(_attrezzatura),
      );
      Map<String, dynamic> userBiosMap = {
        'username': _nicknameController.text,
        'username_search': _nicknameController.text.toLowerCase(),
        'nome': _nomeController.text,
        'cognome': _cognomeController.text,
        'fotoUrl': fotoUrlFinal,
        'bio': _bioBreveController.text,
        'dataNascita': _dataNascitaController.text,
        'citta': _cittaController.text,
        'indirizzo': _indirizzoController.text,
        'quartiere': _quartiereController.text,
        'regione': _regioneController.text,
        'nazione': _nazioneController.text,
        'lat': _lat,
        'lng': _lng,
        'isPetSitter': true,
        'verificato': _identityVerified,
        'emailVerificata': _emailVerified,
        'phoneVerificata': _phoneVerified,
      };
      await FirebaseFirestore.instance.collection('utenti').doc(user.uid).set(userBiosMap, SetOptions(merge: true));
      await FirebaseFirestore.instance.collection('sitters').doc(user.uid).set(finalSitter.toMap(), SetOptions(merge: true));
      await _salvaSuHive(finalSitter);
      final userBox = Hive.box<UserProfile>('user_profile_box');
      final existingProfile = userBox.get(user.uid);
      if (existingProfile != null) {
        await userBox.put(user.uid, UserProfile.fromMap({...existingProfile.toMap(), ...userBiosMap}, user.uid));
      }
      setState(() => _isLoading = false);
      if (widget.isEditing) Navigator.of(context).pop();
      else {
        setState(() => _currentStep = 7);
        _pageController.jumpToPage(7); // Vai a "Inviato"
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('snack_save_error'.tr(args: [e.toString()]))));
    }
  }

  void _goToStripe() {
    setState(() => _currentStep = 8);
    _pageController.jumpToPage(8);
  }

  void _validateAndNext() {
    if (_currentStep == 0 && !widget.isEditing && !_identityVerified) {
      _showValidationMsg("ps_reg_error_identity".tr()); return;
    }
    if (_currentStep == 1) {
      if (_nicknameController.text.trim().isEmpty) { _showValidationMsg("ps_reg_error_name".tr()); return; }
      if (_fotoProfiloPro == null && (_existingFotoUrl == null || _existingFotoUrl!.isEmpty)) { _showValidationMsg("ps_reg_error_photo".tr()); return; }
      if (!_emailVerified) { _showValidationMsg("ps_reg_error_email".tr()); return; }
      if (_indirizzoController.text.trim().isEmpty || _lat == null || _lng == null) { _showValidationMsg("ps_reg_error_address".tr()); return; }
    }
    if (_currentStep == 2 && _bioBreveController.text.trim().length < 20) {
      _showValidationMsg("ps_reg_error_bio".tr()); return;
    }
    if (_currentStep == 4 && !_serviziAttivi.values.any((isActive) => isActive)) {
      _showValidationMsg("ps_reg_error_services".tr()); return;
    }
    _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    setState(() => _currentStep++);
  }

  void _showValidationMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.orange, behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    return SitterRegistrationView(
      currentStep: _currentStep, pageController: _pageController, isEditing: widget.isEditing, isLoading: _isLoading,
      primaryIndigo: primaryIndigo, bgLight: bgLight, textColor: textColor,
      nicknameController: _nicknameController, nomeController: _nomeController, cognomeController: _cognomeController,
      dataNascitaController: _dataNascitaController, bioBreveController: _bioBreveController, nazioneController: _nazioneController,
      regioneController: _regioneController, cittaController: _cittaController, indirizzoController: _indirizzoController,
      quartiereController: _quartiereController, telefonoController: _telefonoController, emailController: _emailController,
      telefonoPrefix: _telefonoPrefix, onPrefixChanged: (p) => setState(() => _telefonoPrefix = p),
      lat: _lat, lng: _lng, onLocationFound: (lat, lng) => setState(() { _lat = lat; _lng = lng; }),
      fotoProfiloPro: _fotoProfiloPro, existingFotoUrl: _existingFotoUrl, onFotoProPicked: (f) => setState(() => _fotoProfiloPro = f),
      docFronte: _docFronte, onDocFrontePicked: (f) => setState(() => _docFronte = f),
      emailVerified: _emailVerified, phoneVerified: _phoneVerified, identityVerified: _identityVerified,
      onEmailVerifiedChanged: (v) => setState(() => _emailVerified = v), onPhoneVerifiedChanged: (v) => setState(() => _phoneVerified = v),
      onIdentityVerified: (v) { setState(() => _identityVerified = v); if (v) _validateAndNext(); },
      anniEsperienzaController: _anniEsperienzaController, descrizioneAltroController: _descrizioneAltroController,
      specieEsperienza: _specieExperience, prenotazioneLastMinute: _prenotazioneLastMinute,
      onSpecieChanged: (s, v) => setState(() {
        if (v) {
          if (!_specieExperience.contains(s)) _specieExperience = [..._specieExperience, s];
        } else {
          _specieExperience = _specieExperience.where((item) => item != s).toList();
        }
      }),
      onLastMinuteChanged: (v) => setState(() => _prenotazioneLastMinute = v),
      raggioKm: _raggioKm, onRaggioKmChanged: (v) => setState(() => _raggioKm = v),
      fotoInserzioneFiles: _fotoInserzioneFiles, existingFotoInserzioneUrls: _existingFotoInserzioneUrls,
      onMultiFotoInserzionePicked: _uploadMultiFotoInserzione,
      onFotoInserzioneRemoved: (i) => setState(() => _fotoInserzioneFiles.removeAt(i)),
      onExistingFotoInserzioneRemoved: (i) => setState(() => _existingFotoInserzioneUrls.removeAt(i)),
      certifications: _certifications, 
      onCertificationAdded: (File file, String name, String? year) => setState(() => _certifications.add({'file': file, 'name': name, 'year': year})),
      onCertificationRemoved: (index) => setState(() => _certifications.removeAt(index)),
      competenze: _competenze, 
      onSkillToggled: (s, v) => setState(() {
        if (v) {
          if (!_competenze.contains(s)) _competenze = [..._competenze, s];
        } else {
          _competenze = _competenze.where((item) => item != s).toList();
        }
      }),
      bisogniSpeciali: _bisogniSpeciali, somministrazioneFarmaci: _somministrazioneFarmaci, gestioneAnimaliDifficili: _gestioneAnimaliDifficili,
      onBisogniSpecialiChanged: (v) => setState(() => _bisogniSpeciali = v), onFarmaciChanged: (v) => setState(() => _somministrazioneFarmaci = v),
      onDifficiliChanged: (v) => setState(() => _gestioneAnimaliDifficili = v),
      serviziAttivi: _serviziAttivi, serviziPrezzi: _serviziPrezzi, serviziMaxAnimali: _serviziMaxAnimali, serviziOrari: _serviziOrari,
      serviziNote: _serviziNote, serviziDurata: _serviziDurata, serviziWeekendExtra: _serviziWeekendExtra, serviziWeekendAttivi: _serviziWeekendAttivi,
      serviziNotturnoExtra: _serviziNotturnoExtra, serviziNotturnoAttivi: _serviziNotturnoAttivi, serviziAsciugaturaAttivi: _serviziAsciugaturaAttivi,
      serviziTaxiPet: _serviziTaxiPet, serviziCheckIn: _serviziCheckIn, serviziCheckOut: _serviziCheckOut, serviziTaglie: _serviziTaglie,
      boardingDailyWalks: _boardingDailyWalks, boardingToiletOptions: _boardingToiletOptions, boardingToiletFrequency: _boardingToiletFrequency,
      boardingHygieneDescription: _boardingHygieneDescription, boardingSpecialNeeds: _boardingSpecialNeeds,
      taxiBaseFare: _taxiBaseFare, taxiPricePerKm: _taxiPricePerKm, taxiPricePerMin: _taxiPricePerMin, taxiNightSurcharge: _taxiNightSurcharge,
      taxiSpecieAccettate: _taxiSpecieAccettate,
      onTaxiBaseFareChanged: (v) => setState(() => _taxiBaseFare = v), onTaxiPricePerKmChanged: (v) => setState(() => _taxiPricePerKm = v),
      onTaxiPricePerMinChanged: (v) => setState(() => _taxiPricePerMin = v), onTaxiNightSurchargeChanged: (v) => setState(() => _taxiNightSurcharge = v),
      onTaxiSpecieChanged: (s, v) => setState(() {
        if (v) {
          if (!_taxiSpecieAccettate.contains(s)) _taxiSpecieAccettate = [..._taxiSpecieAccettate, s];
        } else {
          _taxiSpecieAccettate = _taxiSpecieAccettate.where((item) => item != s).toList();
        }
      }),
      tipoCasa: _tipoCasa, giardino: _giardino, altriAnimaliInCasa: _altriAnimaliInCasa, bambiniInCasa: _bambiniInCasa, ambienteSicuro: _ambienteSicuro,
      onTipoCasaChanged: (v) => setState(() => _tipoCasa = v), onGiardinoChanged: (v) => setState(() => _giardino = v),
      onAltriAnimaliChanged: (v) => setState(() => _altriAnimaliInCasa = v), onBambiniChanged: (v) => setState(() => _bambiniInCasa = v),
      onSicuroChanged: (v) => setState(() => _ambienteSicuro = v),
      fotoCasaFiles: _fotoCasaFiles, existingFotoCasaUrls: _existingFotoCasaUrls,
      onFotoCasaPicked: (i, f) => setState(() { if (i < _fotoCasaFiles.length) _fotoCasaFiles[i] = f; else _fotoCasaFiles.add(f); }),
      onFotoCasaRemoved: (i) => setState(() => _fotoCasaFiles.removeAt(i)),
      onExistingFotoCasaRemoved: (i) => setState(() => _existingFotoCasaUrls.removeAt(i)),
      onMultiFotoCasaPicked: _uploadMultiFotoCasa, 
      onAttrezzaturaChanged: (item, val) => setState(() {
        _attrezzatura = Map<String, bool>.from(_attrezzatura)..[item] = val;
      }),
      onConfirmRevision: _salvaTutto,
      razzeEscluse: _razzeEscluse, comportamentiEsclusi: _comportamentiEsclusi,
      attrezzatura: _attrezzatura, attrezzaturaAltroController: _attrezzaturaAltroController,
      stripeAccountId: _stripeAccountId, stripeOnboardingComplete: _stripeOnboardingComplete,
      onStripeAccountCreated: (id) => setState(() => _stripeAccountId = id),
      onStripeOnboardingComplete: () => setState(() => _stripeOnboardingComplete = true),
      onStripeVerified: () => Navigator.pop(context), 
      onBack: () { if (_currentStep > 0) { _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut); setState(() => _currentStep--); } else Navigator.pop(context); },
      onNext: _validateAndNext, onResetScanner: () => _pageController.jumpToPage(0), onFinish: _goToStripe,
      onServizioToggled: (s, v) => setState(() => _serviziAttivi[s] = v), onPrezzoChanged: (s, v) => setState(() => _serviziPrezzi[s] = v),
      onMaxAnimaliChanged: (s, v) => setState(() => _serviziMaxAnimali[s] = v), onOrariChanged: (s, v) => setState(() => _serviziOrari[s] = v),
      onNoteChanged: (s, v) => setState(() => _serviziNote[s] = v), onDurataChanged: (s, v) => setState(() => _serviziDurata[s] = v),
      onWeekendToggled: (s, v) => setState(() => _serviziWeekendAttivi[s] = v), onWeekendExtraChanged: (s, v) => setState(() => _serviziWeekendExtra[s] = v),
      onNotturnoToggled: (s, v) => setState(() => _serviziNotturnoAttivi[s] = v), onNotturnoExtraChanged: (s, v) => setState(() => _serviziNotturnoExtra[s] = v),
      onAsciugaturaToggled: (s, v) => setState(() => _serviziAsciugaturaAttivi[s] = v), onTaxiPetChanged: (s, v) => setState(() => _serviziTaxiPet[s] = v),
      onCheckInChanged: (s, v) => setState(() => _serviziCheckIn[s] = v), onCheckOutChanged: (s, v) => setState(() => _serviziCheckOut[s] = v),
      onTagliaChanged: (s, t, v) => setState(() { if (v) _serviziTaglie.putIfAbsent(s, () => []).add(t); else _serviziTaglie[s]?.remove(t); }),
      onRazzaAggiunta: (r) => setState(() => _razzeEscluse.add(r)), onRazzaRimossa: (r) => setState(() => _razzeEscluse.remove(r)),
      onComportamentoAggiunto: (c) => setState(() => _comportamentiEsclusi.add(c)), onComportamentoRimossa: (c) => setState(() => _comportamentiEsclusi.remove(c)),
      onBoardingDailyWalksChanged: (v) => setState(() => _boardingDailyWalks = v),
      onBoardingToiletOptionChanged: (opt, v) => setState(() => v ? _boardingToiletOptions.add(opt) : _boardingToiletOptions.remove(opt)),
      onBoardingToiletFrequencyChanged: (v) => setState(() => _boardingToiletFrequency = v),
      onBoardingHygieneDescriptionChanged: (v) => setState(() => _boardingHygieneDescription = v),
      onBoardingSpecialNeedChanged: (opt, v) => setState(() => v ? _boardingSpecialNeeds.add(opt) : _boardingSpecialNeeds.remove(opt)),
    );
  }
}
