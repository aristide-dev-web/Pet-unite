import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petping/d_tab_sds/a_tab/fix_photo.dart';
import 'package:petping/utils/prefisso.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:petping/tipologie/tipologia.dart';
import 'package:easy_localization/easy_localization.dart';

class ModificaSmarriti extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> initialData;

  const ModificaSmarriti({
    super.key,
    required this.docId,
    required this.initialData,
  });

  @override
  State<ModificaSmarriti> createState() => _ModificaSmarritiState();
}

class _ModificaSmarritiState extends State<ModificaSmarriti> with SingleTickerProviderStateMixin {
  static const Color darkBrown = Color(0xFF4E342E);
  static const Color vintageGold = Color(0xFFC5A059);
  static const Color parchment = Color(0xFFFEFAE0);

  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // STEP 1 DATA
  late TextEditingController _nomeController;
  late TextEditingController _razzaController;
  String? _selectedSpecie;
  String? _selectedSesso;
  List<dynamic> _existingImages = [];
  List<File> _newImages = [];

  // STEP 2 DATA
  late TextEditingController _microchipController;
  late TextEditingController _colorePrimarioController;
  late TextEditingController _coloreSecondarioController;
  late TextEditingController _coloreOcchiController;
  late TextEditingController _orecchieController;
  late TextEditingController _codaController;
  late TextEditingController _noteCicatriciController;
  bool _haCicatrici = false;

  // STEP 3 DATA
  late TextEditingController _viaController;
  late TextEditingController _cittaController;
  late TextEditingController _regioneController;
  late TextEditingController _raccontoController;
  late TextEditingController _ricompensaController;
  int? _sDay, _sMonth, _sYear;
  double? _lat, _lng;
  late MapController _mapController;
  final TextEditingController _mapSearchController = TextEditingController();
  LatLng? _tempPos;
  bool _showConfirmPos = false;
  bool _isSearchingMap = false;

  // STEP 4 DATA (CARD)
  final List<TextEditingController> _phoneControllers = [];
  final List<String> _phonePrefixes = [];
  final List<TextEditingController> _emailControllers = [];
  late TextEditingController _whatsappController;
  String _whatsappPrefix = "+39";
  bool _mostraContattiCard = false;

  // BIO DATA
  final List<TextEditingController> _phoneBio = [];
  final List<String> _prefixesBio = [];
  final List<TextEditingController> _emailBio = [];
  late TextEditingController _whatsappBioController;
  String _whatsappBioPrefix = "+39";
  bool _aggiornaContattiBio = false;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _mapController = MapController();

    // STEP 1
    _nomeController = TextEditingController(text: widget.initialData['nome']);
    _razzaController = TextEditingController(text: widget.initialData['razza']);
    _selectedSpecie = widget.initialData['specie'];
    _selectedSesso = widget.initialData['sesso'];
    _existingImages = List.from(widget.initialData['immagini'] ?? []);

    // STEP 2
    _microchipController = TextEditingController(text: widget.initialData['microchip']);
    _colorePrimarioController = TextEditingController(text: widget.initialData['colore_dominante']);
    _coloreSecondarioController = TextEditingController(text: widget.initialData['colore_secondario']);
    _coloreOcchiController = TextEditingController(text: widget.initialData['colore_occhi']);
    _orecchieController = TextEditingController(text: widget.initialData['orecchie']);
    _codaController = TextEditingController(text: widget.initialData['coda']);
    _noteCicatriciController = TextEditingController(text: widget.initialData['note_cicatrici']);
    _haCicatrici = widget.initialData['ha_cicatrici'] ?? false;

    // STEP 3
    _viaController = TextEditingController(text: widget.initialData['via']);
    _cittaController = TextEditingController(text: widget.initialData['città']);
    _regioneController = TextEditingController(text: widget.initialData['regione']);
    _raccontoController = TextEditingController(text: widget.initialData['racconto_dettagliato'] ?? widget.initialData['note']);
    _ricompensaController = TextEditingController(text: widget.initialData['ricompensa']);
    _lat = widget.initialData['lat'];
    _lng = widget.initialData['lng'];
    if (_lat != null && _lng != null) _tempPos = LatLng(_lat!, _lng!);

    final dateSmar = widget.initialData['data_smarrimento'];
    if (dateSmar != null && dateSmar.toString().contains('-')) {
      final parts = dateSmar.toString().split('-');
      if (parts.length == 3) {
        _sYear = int.tryParse(parts[0]);
        _sMonth = int.tryParse(parts[1]);
        _sDay = int.tryParse(parts[2]);
      }
    }

    // STEP 4 (CARD)
    final contatti = widget.initialData['contatti_alternativi'];
    _mostraContattiCard = contatti?['privacy_attiva'] ?? false;
    
    _whatsappController = TextEditingController();
    if (contatti != null && contatti['whatsapp'] != null) {
      final split = PrefixSelector.splitPhone(contatti['whatsapp'].toString());
      _whatsappController.text = split["number"] ?? "";
      _whatsappPrefix = split["prefix"] ?? "+39";
    }

    if (contatti != null && contatti['telefoni'] != null && (contatti['telefoni'] as List).isNotEmpty) {
      for (var t in (contatti['telefoni'] as List)) {
        final split = PrefixSelector.splitPhone(t.toString());
        final ctrl = TextEditingController(text: split["number"]);
        _phoneControllers.add(ctrl);
        _phonePrefixes.add(split["prefix"] ?? "+39");
        if (_phoneControllers.length == 1 && _whatsappController.text.isEmpty) {
          _whatsappController.text = ctrl.text;
          _whatsappPrefix = split["prefix"] ?? "+39";
          ctrl.addListener(() => _whatsappController.text = ctrl.text);
        }
      }
    } else {
      final ctrl = TextEditingController();
      _phoneControllers.add(ctrl);
      _phonePrefixes.add("+39");
      ctrl.addListener(() => _whatsappController.text = ctrl.text);
    }

    if (contatti != null && contatti['emails'] != null && (contatti['emails'] as List).isNotEmpty) {
      for (var e in (contatti['emails'] as List)) {
        _emailControllers.add(TextEditingController(text: e.toString()));
      }
    } else {
      _emailControllers.add(TextEditingController());
    }

    // BIO INITIALIZATION
    _whatsappBioController = TextEditingController();
    _caricaDatiBio();
  }

  Future<void> _caricaDatiBio() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance.collection('utenti').doc(user.uid).get();
    if (doc.exists) {
      final d = doc.data()!;
      setState(() {
        if (d['whatsapp'] != null) {
          final s = PrefixSelector.splitPhone(d['whatsapp'].toString());
          _whatsappBioController.text = s["number"] ?? "";
          _whatsappBioPrefix = s["prefix"] ?? "+39";
        }

        if (d['telefoni'] != null && (d['telefoni'] as List).isNotEmpty) {
          for (var t in (d['telefoni'] as List)) {
            final s = PrefixSelector.splitPhone(t.toString());
            final ctrl = TextEditingController(text: s["number"]);
            _phoneBio.add(ctrl);
            _prefixesBio.add(s["prefix"] ?? "+39");
            if (_phoneBio.length == 1 && _whatsappBioController.text.isEmpty) {
              _whatsappBioController.text = ctrl.text;
              _whatsappBioPrefix = s["prefix"] ?? "+39";
              ctrl.addListener(() => _whatsappBioController.text = ctrl.text);
            }
          }
        }
        if (d['emails'] != null) {
          for (var e in (d['emails'] as List)) {
            _emailBio.add(TextEditingController(text: e.toString()));
          }
        }
      });
    }
    if (_phoneBio.isEmpty) {
      final ctrl = TextEditingController();
      _phoneBio.add(ctrl);
      _prefixesBio.add("+39");
      ctrl.addListener(() => _whatsappBioController.text = ctrl.text);
    }
    if (_emailBio.isEmpty) _emailBio.add(TextEditingController());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nomeController.dispose(); _razzaController.dispose(); _microchipController.dispose();
    _colorePrimarioController.dispose(); _coloreSecondarioController.dispose();
    _coloreOcchiController.dispose(); _orecchieController.dispose(); _codaController.dispose();
    _noteCicatriciController.dispose(); _viaController.dispose(); _cittaController.dispose();
    _regioneController.dispose(); _raccontoController.dispose(); _ricompensaController.dispose();
    _mapSearchController.dispose(); _whatsappController.dispose();
    _whatsappBioController.dispose();
    for (var c in _phoneControllers) c.dispose();
    for (var c in _emailControllers) c.dispose();
    for (var c in _phoneBio) c.dispose();
    for (var c in _emailBio) c.dispose();
    super.dispose();
  }

  // IMAGE LOGIC
  Future<void> _pickImages() async {
    final List<XFile> picked = await ImagePicker().pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() => _newImages.addAll(picked.map((x) => File(x.path))));
      _openFixPhoto();
    }
  }

  Future<void> _openFixPhoto() async {
    if (_newImages.isEmpty) return;
    final List<File>? fixed = await Navigator.push(context, MaterialPageRoute(builder: (context) => FixPhotoScreen(images: _newImages)));
    if (fixed != null) setState(() => _newImages = fixed);
  }

  // MAP LOGIC
  Future<void> _searchMap(String query) async {
    if (query.isEmpty) return;
    setState(() => _isSearchingMap = true);
    try {
      List<Location> locs = await locationFromAddress(query);
      if (locs.isNotEmpty) {
        final newP = LatLng(locs.first.latitude, locs.first.longitude);
        setState(() { _tempPos = newP; _showConfirmPos = true; });
        _mapController.move(newP, 15.0);
        FocusScope.of(context).unfocus();
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('map_address_not_found'.tr())));
    } finally {
      setState(() => _isSearchingMap = false);
    }
  }

  Future<void> _confirmPos() async {
    if (_tempPos == null) return;
    try {
      List<Placemark> pm = await placemarkFromCoordinates(_tempPos!.latitude, _tempPos!.longitude);
      if (pm.isNotEmpty) {
        Placemark p = pm[0];
        setState(() {
          _viaController.text = "${p.thoroughfare ?? ''} ${p.subThoroughfare ?? ''}".trim();
          _cittaController.text = p.locality ?? p.subLocality ?? '';
          _regioneController.text = p.administrativeArea ?? '';
          _lat = _tempPos!.latitude; _lng = _tempPos!.longitude;
          _showConfirmPos = false;
        });
      }
    } catch (_) {
      setState(() { _lat = _tempPos!.latitude; _lng = _tempPos!.longitude; _showConfirmPos = false; });
    }
  }

  // ELIMINA LOGIC
  Future<void> _deleteSegnalazione() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('sos_delete_report'.tr().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900)),
        content: Text('dialog_confirm_delete_text'.tr()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('btn_cancel'.tr().toUpperCase(), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('btn_delete'.tr().toUpperCase(), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w900))),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isSaving = true);
      try {
        await FirebaseFirestore.instance.collection('animali_smarriti').doc(widget.docId).delete();
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('snack_sos_deleted'.tr()), backgroundColor: Colors.redAccent));
        }
      } catch (e) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('msg_error_delete'.tr(args: [e.toString()]))));
      }
    }
  }

  // SAVE LOGIC
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('sos_edit_check_required'.tr())));
       return;
    }
    setState(() => _isSaving = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      List<String> finalUrls = List<String>.from(_existingImages);
      for (int i = 0; i < _newImages.length; i++) {
        String path = 'lost_pets/edited_${widget.docId}_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        TaskSnapshot snap = await FirebaseStorage.instance.ref().child(path).putFile(_newImages[i]);
        finalUrls.add(await snap.ref.getDownloadURL());
      }

      final phones = <String>[];
      for(int i=0; i<_phoneControllers.length; i++) {
        if (_phoneControllers[i].text.trim().isNotEmpty) {
          phones.add("${_phonePrefixes[i]}${_phoneControllers[i].text.trim()}");
        }
      }
      final emails = _emailControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();
      String? wsFinal;
      if (_whatsappController.text.trim().isNotEmpty) wsFinal = "$_whatsappPrefix${_whatsappController.text.trim()}";

      await FirebaseFirestore.instance.collection('animali_smarriti').doc(widget.docId).update({
        'nome': _nomeController.text.trim(),
        'specie': _selectedSpecie,
        'razza': _razzaController.text.trim(),
        'sesso': _selectedSesso,
        'immagini': finalUrls,
        'immagine': finalUrls.isNotEmpty ? finalUrls[0] : '',
        'microchip': _microchipController.text.trim(),
        'colore_dominante': _colorePrimarioController.text.trim(),
        'colore_secondario': _coloreSecondarioController.text.trim(),
        'colore_occhi': _coloreOcchiController.text.trim(),
        'orecchie': _orecchieController.text.trim(),
        'coda': _codaController.text.trim(),
        'ha_cicatrici': _haCicatrici,
        'note_cicatrici': _noteCicatriciController.text.trim(),
        'via': _viaController.text.trim(),
        'città': _cittaController.text.trim(),
        'regione': _regioneController.text.trim(),
        'lat': _lat, 'lng': _lng,
        'posizione': GeoPoint(_lat ?? 0, _lng ?? 0),
        'data_smarrimento': _sDay != null && _sMonth != null && _sYear != null
            ? '$_sYear-${_sMonth.toString().padLeft(2, '0')}-${_sDay.toString().padLeft(2, '0')}'
            : widget.initialData['data_smarrimento'],
        'racconto_dettagliato': _raccontoController.text.trim(),
        'ricompensa': _ricompensaController.text.trim(),
        'contatti_alternativi': {
          'telefoni': phones,
          'emails': emails,
          'whatsapp': wsFinal,
          'privacy_attiva': _mostraContattiCard,
        },
      });

      if (_aggiornaContattiBio) {
        final phonesBio = <String>[];
        for(int i=0; i<_phoneBio.length; i++) {
          if (_phoneBio[i].text.trim().isNotEmpty) {
            phonesBio.add("${_prefixesBio[i]}${_phoneBio[i].text.trim()}");
          }
        }
        final emailsBio = _emailBio.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();
        String? wsBioFinal;
        if (_whatsappBioController.text.trim().isNotEmpty) wsBioFinal = "$_whatsappBioPrefix${_whatsappBioController.text.trim()}";

        await FirebaseFirestore.instance.collection('utenti').doc(user.uid).update({
          'telefoni': phonesBio,
          'emails': emailsBio,
          'whatsapp': wsBioFinal,
        });
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('snack_sos_updated'.tr()), backgroundColor: Colors.green));
      }
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('snack_error_msg'.tr(args: [e.toString()]))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text('sos_edit_title'.tr(args: [widget.initialData['nome']?.toUpperCase() ?? '']), style: const TextStyle(color: darkBrown, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
        leading: IconButton(icon: const Icon(Icons.close, color: darkBrown), onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(
            onPressed: _deleteSegnalazione,
            icon: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
            tooltip: 'sos_delete_report'.tr(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: vintageGold,
          unselectedLabelColor: Colors.grey,
          indicatorColor: vintageGold,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
          tabs: [
            Tab(icon: const Icon(Icons.pets_rounded, size: 18), text: 'sos_edit_tab_identity'.tr()),
            Tab(icon: const Icon(Icons.accessibility_new_rounded, size: 18), text: 'sos_edit_tab_physical'.tr()),
            Tab(icon: const Icon(Icons.history_rounded, size: 18), text: 'sos_edit_tab_location'.tr()),
            Tab(icon: const Icon(Icons.contact_phone_rounded, size: 18), text: 'sos_edit_tab_contacts'.tr()),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: Stack(
          children: [
            TabBarView(
              controller: _tabController,
              children: [
                _buildTabWrapper(_step1()),
                _buildTabWrapper(_step2()),
                _buildTabWrapper(_step3()),
                _buildTabWrapper(_step4()),
              ],
            ),
            if (_isSaving) Container(color: Colors.black45, child: const Center(child: CircularProgressIndicator(color: vintageGold))),
          ],
        ),
      ),
    );
  }

  Widget _buildTabWrapper(Widget content) {
    return Container(
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
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 40),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), borderRadius: BorderRadius.circular(30)),
              child: Column(
                children: [
                  content,
                  const SizedBox(height: 35),
                  _buildSaveAndExitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveAndExitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: darkBrown,
          foregroundColor: parchment,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 5,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('profile_btn_save_exit'.tr(), style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
            const SizedBox(width: 10),
            const Icon(Icons.check_circle_outline, size: 20),
          ],
        ),
      ),
    );
  }

  // --- STEP 1: IDENTITÀ (Identico ad AddUno) ---
  Widget _step1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildLabel('sos_edit_gallery_label'.tr()),
            if (_newImages.isNotEmpty)
              GestureDetector(onTap: _openFixPhoto, child: Text('sos_edit_manage_photos'.tr(), style: const TextStyle(color: vintageGold, fontWeight: FontWeight.w900, fontSize: 10))),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _existingImages.length + _newImages.length + 1,
            itemBuilder: (context, i) {
              int tot = _existingImages.length + _newImages.length;
              if (i == tot) return tot < 5 ? _buildAddImageButton() : const SizedBox.shrink();
              bool isEx = i < _existingImages.length;
              return _buildImagePreview(i, isExisting: isEx);
            },
          ),
        ),
        const SizedBox(height: 30),
        _buildLabel('sos_edit_gender_label'.tr()),
        Row(
          children: [
            _buildSessoButton(label: 'gender_male'.tr().toUpperCase(), isSelected: _selectedSesso == 'Maschio', icon: Icons.male_rounded, activeColor: Colors.blue.shade400, onTap: () => setState(() => _selectedSesso = 'Maschio')),
            const SizedBox(width: 12),
            _buildSessoButton(label: 'gender_female'.tr().toUpperCase(), isSelected: _selectedSesso == 'Femmina', icon: Icons.female_rounded, activeColor: Colors.pink.shade300, onTap: () => setState(() => _selectedSesso = 'Femmina')),
          ],
        ),
        const SizedBox(height: 25),
        _buildLabel('sos_edit_name_label'.tr()),
        _buildTextField(_nomeController, 'Rex', validator: (v) => v!.isEmpty ? 'register_error_nickname_empty'.tr() : null),
        const SizedBox(height: 20),
        _buildLabel('sos_edit_species_label'.tr()),
        _buildAutocompleteField(hint: 'Cane', options: allTipiOrdinati, initialValue: _selectedSpecie, onSelected: (val) => setState(() => _selectedSpecie = val)),
        const SizedBox(height: 20),
        _buildLabel('sos_edit_breed_label'.tr()),
        _buildAutocompleteField(hint: 'Pastore Tedesco', options: razzePerSpecie[_selectedSpecie] ?? [], initialValue: _razzaController.text, controller: _razzaController, onSelected: (val) => _razzaController.text = val ?? ''),
      ],
    );
  }

  // --- STEP 2: FISICO (Identico ad AddDue) ---
  Widget _step2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('sos_edit_microchip_label'.tr()),
        _buildTextField(_microchipController, 'sos_edit_microchip_hint'.tr()),
        const SizedBox(height: 30),
        _buildLabel('sos_edit_colors_label'.tr()),
        Row(
          children: [
            Expanded(child: _buildColorDropdown(hint: 'sos_edit_color_primary_hint'.tr(), controller: _colorePrimarioController)),
            const SizedBox(width: 10),
            Expanded(child: _buildColorDropdown(hint: 'sos_edit_color_secondary_hint'.tr(), controller: _coloreSecondarioController)),
          ],
        ),
        const SizedBox(height: 25),
        _buildLabel('sos_edit_eyes_color_label'.tr()),
        _buildColorDropdown(hint: 'profile_select_placeholder'.tr(), controller: _coloreOcchiController, isEye: true),
        const SizedBox(height: 25),
        Row(
          children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('sos_edit_ears_label'.tr()), _buildFeatureDropdown(hint: 'profile_select_placeholder'.tr(), controller: _orecchieController)])),
            const SizedBox(width: 15),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('sos_edit_tail_label'.tr()), _buildFeatureDropdown(hint: 'profile_select_placeholder'.tr(), controller: _codaController)])),
          ],
        ),
        const SizedBox(height: 25),
        _buildLabel('sos_edit_scars_question'.tr()),
        Row(
          children: [
            _buildSelectionButton(label: 'yes'.tr().toUpperCase(), isSelected: _haCicatrici, onTap: () => setState(() => _haCicatrici = true)),
            const SizedBox(width: 12),
            _buildSelectionButton(label: 'no'.tr().toUpperCase(), isSelected: !_haCicatrici, onTap: () => setState(() => _haCicatrici = false)),
          ],
        ),
        const SizedBox(height: 25),
        _buildLabel('sos_edit_notes_label'.tr()),
        _buildTextField(_noteCicatriciController, 'pet_diary_memory_desc_label'.tr() + '...', maxLines: 3),
      ],
    );
  }

  // --- STEP 3: LUOGO & STORIA (Identico ad AddTre) ---
  Widget _step3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('sos_edit_last_seen_label'.tr()),
        _buildMapSection(),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(child: _buildTextField(_viaController, 'profile_label_address'.tr())),
            const SizedBox(width: 8),
            IconButton(onPressed: () => _searchMap("${_viaController.text} ${_cittaController.text}"), icon: const Icon(Icons.map_outlined, color: vintageGold)),
          ],
        ),
        Row(
          children: [
            Expanded(child: _buildTextField(_cittaController, 'profile_label_city'.tr())),
            const SizedBox(width: 10),
            Expanded(child: _buildTextField(_regioneController, 'profile_label_region'.tr())),
          ],
        ),
        const SizedBox(height: 25),
        _buildLabel('sos_edit_when_question'.tr()),
        Row(
          children: [
            _buildDateDropdown(flex: 2, label: 'GG', value: _sDay, items: 31, offset: 1, onChanged: (v) => setState(() => _sDay = v)),
            const SizedBox(width: 8),
            _buildDateDropdown(flex: 2, label: 'MM', value: _sMonth, items: 12, offset: 1, onChanged: (v) => setState(() => _sMonth = v)),
            const SizedBox(width: 8),
            _buildDateDropdown(flex: 3, label: 'AAAA', value: _sYear, items: 6, isYear: true, onChanged: (v) => setState(() => _sYear = v)),
          ],
        ),
        const SizedBox(height: 25),
        _buildLabel('sos_edit_story_label'.tr()),
        _buildTextField(_raccontoController, 'sos_add_story_hint'.tr(), maxLines: 3),
        const SizedBox(height: 25),
        _buildLabel('sos_edit_reward_label'.tr()),
        _buildTextField(_ricompensaController, 'sos_add_reward_hint'.tr()),
      ],
    );
  }

  // --- STEP 4: CONTATTI ---
  Widget _step4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildContactSection(
          title: 'sos_edit_contacts_card_title'.tr(),
          icon: Icons.style_rounded,
          color: vintageGold,
          isVisible: _mostraContattiCard,
          onVisibilityChanged: (v) => setState(() => _mostraContattiCard = v),
          children: [
            ..._phoneControllers.asMap().entries.map((e) => _buildContactInput(e.value, 'profile_label_phones'.tr(), Icons.phone, () => setState(() { _phoneControllers.removeAt(e.key); _phonePrefixes.removeAt(e.key); }), isPhone: true, prefix: _phonePrefixes[e.key], onPrefixTap: () => _pickPrefix(_phonePrefixes, e.key))),
            _addBtn('sos_edit_add_phone'.tr(), () => setState(() { _phoneControllers.add(TextEditingController()); _phonePrefixes.add("+39"); }), vintageGold),
            const Divider(),
            Text('sos_edit_whatsapp_card_label'.tr(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.grey, letterSpacing: 1)),
            const SizedBox(height: 8),
            _buildContactInput(_whatsappController, "Numero WhatsApp", Icons.chat_rounded, () => _whatsappController.clear(), isPhone: true, prefix: _whatsappPrefix, onPrefixTap: _pickPrefixWhatsApp),
            const Divider(),
            ..._emailControllers.asMap().entries.map((e) => _buildContactInput(e.value, "Email", Icons.email, () => setState(() => _emailControllers.removeAt(e.key)))),
            _addBtn('sos_edit_add_email'.tr(), () => setState(() => _emailControllers.add(TextEditingController())), vintageGold),
          ],
        ),
        const SizedBox(height: 25),
        _buildContactSection(
          title: 'sos_edit_contacts_bio_title'.tr(),
          icon: Icons.account_circle_rounded,
          color: Colors.blue,
          isVisible: _aggiornaContattiBio,
          onVisibilityChanged: (v) => setState(() => _aggiornaContattiBio = v),
          children: [
            ..._phoneBio.asMap().entries.map((e) => _buildContactInput(e.value, "Cellulare Profilo", Icons.phone_android, () => setState(() { _phoneBio.removeAt(e.key); _prefixesBio.removeAt(e.key); }), isPhone: true, prefix: _prefixesBio[e.key], onPrefixTap: () => _pickPrefix(_prefixesBio, e.key))),
            _addBtn("Aggiungi Telefono Bio", () => setState(() { _phoneBio.add(TextEditingController()); _prefixesBio.add("+39"); }), Colors.blue),
            const Divider(),
            Text('sos_edit_whatsapp_bio_label'.tr(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.grey, letterSpacing: 1)),
            const SizedBox(height: 8),
            _buildContactInput(_whatsappBioController, "WhatsApp Bio", Icons.chat_bubble_outline_rounded, () => _whatsappBioController.clear(), isPhone: true, prefix: _whatsappBioPrefix, onPrefixTap: () => _pickPrefixWhatsAppBio()),
            const Divider(),
            ..._emailBio.asMap().entries.map((e) => _buildContactInput(e.value, "Email Profilo", Icons.email_outlined, () => setState(() => _emailBio.removeAt(e.key)))),
            _addBtn("Aggiungi Email Bio", () => setState(() => _emailBio.add(TextEditingController())), Colors.blue),
          ],
        ),
      ],
    );
  }

  // --- HELPER UI ---
  Widget _buildLabel(String t) => Padding(padding: const EdgeInsets.only(left: 4, bottom: 8), child: Text(t, style: const TextStyle(color: darkBrown, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.0)));

  InputDecoration _inputDecoration(String h) => InputDecoration(hintText: h, hintStyle: TextStyle(color: darkBrown.withOpacity(0.3), fontSize: 13), filled: true, fillColor: Colors.white.withOpacity(0.5), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: darkBrown.withOpacity(0.1))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: vintageGold, width: 2)));

  Widget _buildTextField(TextEditingController c, String h, {int maxLines = 1, String? Function(String?)? validator}) => TextFormField(controller: c, maxLines: maxLines, validator: validator, style: const TextStyle(color: darkBrown, fontWeight: FontWeight.w600, fontSize: 14), decoration: _inputDecoration(h));

  Widget _buildSessoButton({required String label, required IconData icon, required bool isSelected, required Color activeColor, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: isSelected ? activeColor.withOpacity(0.15) : Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(12), border: Border.all(color: isSelected ? activeColor : darkBrown.withOpacity(0.1), width: 2)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 18, color: isSelected ? activeColor : darkBrown.withOpacity(0.4)), const SizedBox(width: 8), Text(label, style: TextStyle(color: isSelected ? activeColor : darkBrown.withOpacity(0.6), fontWeight: FontWeight.bold, fontSize: 12))]),
        ),
      ),
    );
  }

  Widget _buildSelectionButton({required String label, required bool isSelected, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: isSelected ? vintageGold.withOpacity(0.2) : Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(12), border: Border.all(color: isSelected ? vintageGold : darkBrown.withOpacity(0.1), width: 2)),
          child: Center(child: Text(label, style: TextStyle(color: isSelected ? darkBrown : darkBrown.withOpacity(0.5), fontWeight: FontWeight.bold))),
        ),
      ),
    );
  }

  Widget _buildImagePreview(int i, {required bool isExisting}) {
    return Stack(
      children: [
        Container(width: 100, margin: const EdgeInsets.only(right: 12), decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: vintageGold.withOpacity(0.2)), image: DecorationImage(image: isExisting ? NetworkImage(_existingImages[i]) : FileImage(_newImages[i - _existingImages.length]) as ImageProvider, fit: BoxFit.cover))),
        Positioned(top: 5, right: 17, child: GestureDetector(onTap: () => setState(() => isExisting ? _existingImages.removeAt(i) : _newImages.removeAt(i - _existingImages.length)), child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle), child: const Icon(Icons.close, color: Colors.white, size: 14)))),
      ],
    );
  }

  Widget _buildAddImageButton() => GestureDetector(onTap: _pickImages, child: Container(width: 100, margin: const EdgeInsets.only(right: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: vintageGold.withOpacity(0.5), width: 2)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.add_a_photo_rounded, color: vintageGold, size: 30), const SizedBox(height: 4), Text('home_btn_add'.tr(), style: const TextStyle(color: vintageGold, fontSize: 10, fontWeight: FontWeight.bold))])));

  Widget _buildAutocompleteField({required String hint, required List<String> options, String? initialValue, required ValueChanged<String?> onSelected, TextEditingController? controller}) {
    return Autocomplete<String>(
      optionsBuilder: (textValue) {
        if (textValue.text.isEmpty) return const Iterable<String>.empty();
        return options.where((o) => o.toLowerCase().contains(textValue.text.toLowerCase()));
      },
      onSelected: onSelected,
      initialValue: TextEditingValue(text: initialValue ?? ''),
      fieldViewBuilder: (ctx, fieldController, focusNode, onS) {
        if (controller != null && fieldController.text.isEmpty && controller.text.isNotEmpty) fieldController.text = controller.text;
        return TextFormField(controller: fieldController, focusNode: focusNode, style: const TextStyle(color: darkBrown, fontWeight: FontWeight.w600), decoration: _inputDecoration(hint));
      },
    );
  }

  Widget _buildColorDropdown({required String hint, required TextEditingController controller, bool isEye = false}) {
    final List<String> options = isEye ? ['Marroni', 'Azzurri', 'Verdi', 'Gialli', 'Eterocromi (diversi)', 'Neri'] : ['Nero', 'Bianco', 'Marrone', 'Grigio', 'Fulvo', 'Arancio', 'Tigrato', 'Pezzato'];
    return DropdownButtonFormField<String>(value: options.contains(controller.text) ? controller.text : null, decoration: _inputDecoration(hint), items: options.map((v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontSize: 14, color: darkBrown)))).toList(), onChanged: (v) => controller.text = v ?? '');
  }

  Widget _buildFeatureDropdown({required String hint, required TextEditingController controller}) {
    final List<String> options = ['Lunghe', 'Medie', 'Corte', 'Assenti'];
    return DropdownButtonFormField<String>(value: options.contains(controller.text) ? controller.text : null, decoration: _inputDecoration(hint), items: options.map((v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontSize: 14, color: darkBrown)))).toList(), onChanged: (v) => controller.text = v ?? '');
  }

  Widget _buildMapSection() {
    return Container(
      height: 220,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: vintageGold.withOpacity(0.3), width: 2)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _tempPos ?? const LatLng(41.9028, 12.4964),
                initialZoom: _tempPos != null ? 15.0 : 5.0,
                onTap: (t, l) => setState(() { _tempPos = l; _showConfirmPos = true; }),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.petping.app',
                ),
                if (_tempPos != null) MarkerLayer(markers: [Marker(point: _tempPos!, width: 40, height: 40, child: const Icon(Icons.location_on, color: Colors.orange, size: 40))]),
              ],
            ),
            Positioned(top: 10, left: 10, right: 10, child: Container(height: 45, decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(12)), child: TextField(controller: _mapSearchController, decoration: InputDecoration(hintText: 'sos_edit_search_hint'.tr(), border: InputBorder.none, prefixIcon: const Icon(Icons.search, size: 18, color: vintageGold), suffixIcon: _isSearchingMap ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2)) : IconButton(icon: const Icon(Icons.send), onPressed: () => _searchMap(_mapSearchController.text))), onSubmitted: _searchMap))),
            if (_showConfirmPos) Positioned(bottom: 10, left: 50, right: 50, child: GestureDetector(onTap: _confirmPos, child: Container(padding: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(color: darkBrown, borderRadius: BorderRadius.circular(20)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.check, color: Colors.white, size: 16), const SizedBox(width: 8), Text('sos_edit_confirm_pos_btn'.tr(), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))])))),
          ],
        ),
      ),
    );
  }

  Widget _buildDateDropdown({required int flex, required String label, required int? value, required int items, int offset = 0, bool isYear = false, required ValueChanged<int?> onChanged}) {
    return Expanded(flex: flex, child: DropdownButtonFormField<int>(value: value, decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(fontSize: 10, color: darkBrown), filled: true, fillColor: Colors.white.withOpacity(0.5), contentPadding: const EdgeInsets.symmetric(horizontal: 10), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: darkBrown.withOpacity(0.1)))), items: List.generate(items, (i) { final val = isYear ? DateTime.now().year - i : i + offset; return DropdownMenuItem(value: val, child: Text(val.toString(), style: const TextStyle(fontSize: 13, color: darkBrown))); }), onChanged: onChanged));
  }

  Widget _buildContactSection({required String title, required IconData icon, required Color color, required bool isVisible, required ValueChanged<bool> onVisibilityChanged, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), border: Border.all(color: color.withOpacity(0.3), width: 2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: color), const SizedBox(width: 10), Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: darkBrown, fontSize: 12)), const Spacer(), _buildVisibilityBadge(isVisible, onVisibilityChanged, color)]),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildVisibilityBadge(bool isVisible, ValueChanged<bool> onTap, Color color) {
    return GestureDetector(
      onTap: () => onTap(!isVisible),
      child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: isVisible ? color.withOpacity(0.1) : Colors.grey[200], borderRadius: BorderRadius.circular(10), border: Border.all(color: isVisible ? color : Colors.grey)), child: Row(children: [Icon(isVisible ? Icons.visibility : Icons.visibility_off, size: 12, color: isVisible ? color : Colors.grey), const SizedBox(width: 5), Text(isVisible ? "PUB".tr().toUpperCase() : "PRI".tr().toUpperCase(), style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.blueGrey))])),
    );
  }

  Widget _buildContactInput(TextEditingController c, String h, IconData i, VoidCallback onRem, {bool isPhone = false, String? prefix, VoidCallback? onPrefixTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          if (isPhone && prefix != null) GestureDetector(onTap: onPrefixTap, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12), decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)), child: Text(prefix, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)))),
          const SizedBox(width: 8),
          Expanded(child: TextField(controller: c, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600), decoration: InputDecoration(prefixIcon: Icon(i, size: 16), hintText: h, filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)))),
          IconButton(onPressed: onRem, icon: const Icon(Icons.cancel, color: Colors.redAccent, size: 20)),
        ],
      ),
    );
  }

  void _pickPrefix(List<String> list, int index) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => PrefixSelector(onSelected: (p) => setState(() => list[index] = p))));
  }

  void _pickPrefixWhatsApp() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => PrefixSelector(onSelected: (p) => setState(() => _whatsappPrefix = p))));
  }

  void _pickPrefixWhatsAppBio() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => PrefixSelector(onSelected: (p) => setState(() => _whatsappBioPrefix = p))));
  }

  Widget _addBtn(String t, VoidCallback onTap, Color color) => TextButton(onPressed: onTap, child: Text(t, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)));
}
