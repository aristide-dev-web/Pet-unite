import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:petping/utils/image_picker_helper.dart';
import 'package:petping/utils/firebase_storage_helper.dart';
import 'package:petping/utils/prefisso.dart';
import 'package:petping/zoom.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:petping/petsitting/models/sitter_model.dart';
import 'package:easy_localization/easy_localization.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final user = FirebaseAuth.instance.currentUser;
  late TabController _tabController;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController cognomeController = TextEditingController();
  final TextEditingController dataNascitaController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController nazioneController = TextEditingController();
  final TextEditingController RegioneController = TextEditingController();
  final TextEditingController cittaController = TextEditingController();
  final TextEditingController quartiereController = TextEditingController();
  final TextEditingController indirizzoController = TextEditingController();
  final _searchController = TextEditingController();

  // Mappa
  final MapController _mapController = MapController();
  LatLng? _selectedPosition;
  bool _isSearching = false;
  bool _showConfirmButton = false;
  bool isPetSitter = false;
  bool _isUploadingPhoto = false;

  String sesso = 'Non specificato';
  List<TextEditingController> emailControllers = [TextEditingController()];
  
  List<TextEditingController> telefonoControllers = [TextEditingController()];
  List<String> telefonoPrefixes = ["+39"];

  List<TextEditingController> whatsappControllers = [TextEditingController()];
  List<String> whatsappPrefixes = ["+39"];

  String? fotoUrl;
  File? _selectedImage;

  Map<String, bool> visibilita = {
    'username': true, 
    'nome': false, 
    'cognome': false,
    'dataNascita': false, 
    'emails': false, 
    'telefoni': false, 
    'whatsapp': false, 
    'nazione': false, 
    'regione': false, 
    'citta': false, 
    'indirizzo': false,
    'bio': false, 
    'sesso': false,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
    _caricaDatiProfilo();
  }

  @override
  void dispose() {
    _tabController.dispose();
    usernameController.dispose();
    nomeController.dispose();
    cognomeController.dispose();
    dataNascitaController.dispose();
    bioController.dispose();
    nazioneController.dispose();
    RegioneController.dispose();
    cittaController.dispose();
    quartiereController.dispose();
    indirizzoController.dispose();
    _searchController.dispose();
    for (var c in whatsappControllers) c.dispose();
    for (var c in emailControllers) c.dispose();
    for (var c in telefonoControllers) c.dispose();
    super.dispose();
  }

  Future<void> _caricaDatiProfilo() async {
    if (user == null) return;

    final sitterBox = Hive.box<SitterProfile>('sitters_box');
    final localSitter = sitterBox.get(user!.uid);
    
    if (mounted) {
      setState(() {
        isPetSitter = localSitter != null; 
      });
    }
    
    final doc = await FirebaseFirestore.instance.collection('utenti').doc(user!.uid).get();

    _syncSitterStatus();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        isPetSitter = isPetSitter || (data['isPetSitter'] ?? false);
        
        usernameController.text = data['username'] ?? '';
        nomeController.text = data['nome'] ?? '';
        cognomeController.text = data['cognome'] ?? '';
        dataNascitaController.text = data['dataNascita'] ?? '';
        sesso = data['sesso'] ?? 'Non specificato';
        nazioneController.text = data['nazione'] ?? '';
        RegioneController.text = data['regione'] ?? '';
        cittaController.text = data['citta'] ?? '';
        quartiereController.text = data['quartiere'] ?? '';
        indirizzoController.text = data['indirizzo'] ?? '';
        bioController.text = data['bio'] ?? '';
        fotoUrl = data['fotoUrl'];
        visibilita = Map<String, bool>.from(data['visibilita'] ?? visibilita);
        
        visibilita['username'] = true;

        double? lat = (data['lat'] as num?)?.toDouble();
        double? lng = (data['lng'] as num?)?.toDouble();
        if (lat != null && lng != null) {
          _selectedPosition = LatLng(lat, lng);
        }

        if (data['emails'] != null) emailControllers = (data['emails'] as List).map((e) => TextEditingController(text: e.toString())).toList();
        
        if (data['telefoni'] != null) {
          telefonoControllers.clear();
          telefonoPrefixes.clear();
          for (var t in (data['telefoni'] as List)) {
            final split = PrefixSelector.splitPhone(t.toString());
            telefonoControllers.add(TextEditingController(text: split["number"]));
            telefonoPrefixes.add(split["prefix"]!);
          }
        }

        if (data['whatsapp'] != null) {
          whatsappControllers.clear();
          whatsappPrefixes.clear();
          if (data['whatsapp'] is List) {
            for (var w in (data['whatsapp'] as List)) {
              final split = PrefixSelector.splitPhone(w.toString());
              whatsappControllers.add(TextEditingController(text: split["number"]));
              whatsappPrefixes.add(split["prefix"]!);
            }
          } else {
            final split = PrefixSelector.splitPhone(data['whatsapp'].toString());
            whatsappControllers.add(TextEditingController(text: split["number"]));
            whatsappPrefixes.add(split["prefix"]!);
          }
        }
      });
    }
  }

  Future<void> _syncSitterStatus() async {
    try {
      final sitterDoc = await FirebaseFirestore.instance.collection('sitters').doc(user!.uid).get();
      if (sitterDoc.exists && mounted) {
        final sitter = SitterProfile.fromMap(sitterDoc.data()!, sitterDoc.id);
        await Hive.box<SitterProfile>('sitters_box').put(user!.uid, sitter);
        setState(() => isPetSitter = true);
      }
    } catch (e) { }
  }

  Future<void> _searchAddress(String address) async {
    if (address.isEmpty) return;
    setState(() => _isSearching = true);
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        final newPos = LatLng(loc.latitude, loc.longitude);
        setState(() {
          _selectedPosition = newPos;
          _showConfirmButton = true;
        });
        _mapController.move(newPos, 15.0);
        FocusScope.of(context).unfocus();

        List<Placemark> placemarks = await placemarkFromCoordinates(loc.latitude, loc.longitude);
        if (placemarks.isNotEmpty) {
          Placemark p = placemarks[0];
          setState(() {
            indirizzoController.text = "${p.thoroughfare ?? ''} ${p.subThoroughfare ?? ''}".trim();
            cittaController.text = p.locality ?? p.subLocality ?? '';
            quartiereController.text = p.subLocality ?? '';
            RegioneController.text = p.administrativeArea ?? '';
            nazioneController.text = p.country ?? '';
            visibilita['nazione'] = true;
          });
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("profile_error_address_not_found".tr())));
    } finally {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _handleConfirm() async {
    if (_selectedPosition == null) return;
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(_selectedPosition!.latitude, _selectedPosition!.longitude);
      if (placemarks.isNotEmpty) {
        Placemark p = placemarks[0];
        setState(() {
          indirizzoController.text = "${p.thoroughfare ?? ''} ${p.subThoroughfare ?? ''}".trim();
          cittaController.text = p.locality ?? p.subLocality ?? '';
          quartiereController.text = p.subLocality ?? '';
          RegioneController.text = p.administrativeArea ?? '';
          nazioneController.text = p.country ?? '';
          _showConfirmButton = false;
          visibilita['nazione'] = true;
        });
      }
    } catch (e) {
      setState(() => _showConfirmButton = false);
    }
  }

  Future<void> _salvaProfilo() async {
    if (user != null && _formKey.currentState!.validate()) {
      final List<String> telefoniSalvati = [];
      for (int i = 0; i < telefonoControllers.length; i++) {
        String n = telefonoControllers[i].text.trim();
        if (n.isNotEmpty) telefoniSalvati.add("${telefonoPrefixes[i]}$n");
      }

      final List<String> whatsappSalvati = [];
      for (int i = 0; i < whatsappControllers.length; i++) {
        String n = whatsappControllers[i].text.trim();
        if (n.isNotEmpty) whatsappSalvati.add("${whatsappPrefixes[i]}$n");
      }

      final String username = usernameController.text.trim();
      visibilita['username'] = true;

      final data = {
        'username': username,
        'username_search': username.toLowerCase(),
        'nome': nomeController.text.trim(),
        'cognome': cognomeController.text.trim(),
        'dataNascita': dataNascitaController.text.trim(),
        'sesso': sesso,
        'emails': emailControllers.map((c) => c.text.trim()).toList(),
        'telefoni': telefoniSalvati,
        'whatsapp': whatsappSalvati,
        'nazione': nazioneController.text.trim(),
        'regione': RegioneController.text.trim(),
        'citta': cittaController.text.trim(),
        'quartiere': quartiereController.text.trim(),
        'indirizzo': indirizzoController.text.trim(),
        'bio': bioController.text.trim(),
        'fotoUrl': fotoUrl ?? '',
        'visibilita': visibilita,
        'lat': _selectedPosition?.latitude,
        'lng': _selectedPosition?.longitude,
        'isPetSitter': isPetSitter,
        'profiloCreato': true,
      };
      await FirebaseFirestore.instance.collection('utenti').doc(user!.uid).set(data, SetOptions(merge: true));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('profile_save_success'.tr()), backgroundColor: Colors.orangeAccent, behavior: SnackBarBehavior.floating));
        Navigator.pop(context); 
      }
    }
  }

  Future<void> _salvaEChiudi() async {
    await _salvaProfilo();
  }

  @override
  Widget build(BuildContext context) {
    List<Color> tabColors = [Colors.blueAccent, Colors.green, Colors.orangeAccent];
    Color activeColor = tabColors[_tabController.index];

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text('profile_title'.tr(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5, color: Color(0xFF1E293B))),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(95),
          child: _buildDynamicTabBar(activeColor),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildAccountTab(),
                  _buildContattiTab(),
                  _buildInfoTab(),
                ],
              ),
            ),
            _buildActionBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicTabBar(Color activeColor) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 15),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
      child: TabBar(
        controller: _tabController,
        onTap: (index) => setState(() {}),
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.white, boxShadow: [BoxShadow(color: activeColor.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 5))]),
        labelColor: activeColor,
        unselectedLabelColor: Colors.blueGrey[300],
        labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5),
        tabs: [
          Tab(height: 55, icon: const Icon(Icons.person_rounded, size: 24), text: "profile_tab_account".tr()),
          Tab(height: 55, icon: const Icon(Icons.alternate_email_rounded, size: 24), text: "profile_tab_contacts".tr()),
          Tab(height: 55, icon: const Icon(Icons.explore_rounded, size: 24), text: "profile_tab_location".tr()),
        ],
      ),
    );
  }

  Widget _buildAccountTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildAvatarSection(),
          const SizedBox(height: 25),
          _buildTopQuickInfo(),
          const SizedBox(height: 30),
          _buildPokeCard(
            title: "profile_section_identity".tr(),
            color: const Color(0xFFE0F2FE),
            accentColor: Colors.blueAccent,
            icon: Icons.badge_rounded,
            children: [
              _buildField("profile_label_username".tr(), usernameController, Icons.alternate_email, 'username', labelColor: Colors.blue[800]!),
              const SizedBox(height: 15),
              _buildField("profile_label_firstname".tr(), nomeController, Icons.face_rounded, 'nome', labelColor: Colors.blue[800]!),
              const SizedBox(height: 15),
              _buildField("profile_label_lastname".tr(), cognomeController, Icons.face_retouching_natural, 'cognome', labelColor: Colors.blue[800]!),
              const SizedBox(height: 15),
              _buildField("profile_label_bio".tr(), bioController, Icons.auto_awesome_rounded, 'bio', maxLines: 4, labelColor: Colors.blue[800]!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopQuickInfo() {
    String genderValue = sesso;
    if (sesso == 'Maschio') genderValue = 'gender_male'.tr();
    else if (sesso == 'Femmina') genderValue = 'gender_female'.tr();
    else if (sesso == 'Altro') genderValue = 'gender_other'.tr();
    else if (sesso == 'Non specificato') genderValue = 'gender_not_specified'.tr();

    return Row(
      children: [
        Expanded(child: _buildSelectionTile(label: "profile_label_gender".tr(), visKey: 'sesso', value: genderValue, icon: sesso == 'Maschio' ? Icons.male : (sesso == 'Femmina' ? Icons.female : Icons.transgender), color: const Color(0xFFF3E5F5), accent: Colors.purple, onTap: () => _showSessoPicker())),
        const SizedBox(width: 15),
        Expanded(child: _buildSelectionTile(label: "profile_label_birthdate".tr(), visKey: 'dataNascita', value: dataNascitaController.text.isEmpty ? "profile_select_placeholder".tr() : dataNascitaController.text, icon: Icons.cake_rounded, color: const Color(0xFFFFEBEE), accent: const Color(0xFFF06292), onTap: () => _selectDate(context))),
      ],
    );
  }

  Widget _buildContattiTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: _buildPokeCard(
        title: "profile_section_contacts".tr(),
        color: const Color(0xFFDCFCE7),
        accentColor: Colors.green[700]!,
        icon: Icons.contact_emergency_rounded,
        children: [
          Row(
            children: [
              _sectionHeader("profile_label_emails".tr()),
              const Spacer(),
              _buildVisibilityBadge('emails'),
            ],
          ),
          const SizedBox(height: 10),
          ...emailControllers.asMap().entries.map((e) => _buildDynamicRow(e.key, e.value, emailControllers, Icons.email_outlined, Colors.green[800]!)),
          _addBtn(() => setState(() => emailControllers.add(TextEditingController())), "profile_btn_add_email".tr()),

          const Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Divider()),

          Row(
            children: [
              _sectionHeader("profile_label_phones".tr()),
              const Spacer(),
              _buildVisibilityBadge('telefoni'),
            ],
          ),
          const SizedBox(height: 10),
          ...telefonoControllers.asMap().entries.map((e) => _buildPhoneRow(e.key)),
          _addBtn(() => setState(() {
            telefonoControllers.add(TextEditingController());
            telefonoPrefixes.add("+39");
          }), "profile_btn_add_phone".tr()),

          const Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Divider()),

          Row(
            children: [
              _sectionHeader("profile_label_whatsapp".tr()),
              const Spacer(),
              _buildVisibilityBadge('whatsapp'),
            ],
          ),
          const SizedBox(height: 10),
          ...whatsappControllers.asMap().entries.map((e) => _buildWhatsAppRow(e.key)),
          _addBtn(() => setState(() {
            whatsappControllers.add(TextEditingController());
            whatsappPrefixes.add("+39");
          }), "profile_btn_add_whatsapp".tr()),
        ],
      ),
    );
  }

  Widget _buildWhatsAppRow(int index) {
    final color = Colors.green[800]!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PrefixSelector(onSelected: (p) => setState(() => whatsappPrefixes[index] = p)))),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: color.withOpacity(0.1))),
              child: Text(whatsappPrefixes[index], style: TextStyle(fontWeight: FontWeight.bold, color: color)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: whatsappControllers[index],
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              decoration: InputDecoration(
                hintText: index == 0 ? "profile_label_whatsapp".tr() : "profile_hint_extra".tr(),
                hintStyle: TextStyle(color: color.withOpacity(0.3), fontSize: 13),
                filled: true,
                fillColor: Colors.white.withOpacity(0.8),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: color.withOpacity(0.1))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: color.withOpacity(0.1))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: color, width: 1.5)),
              ),
            ),
          ),
          if (index > 0)
            IconButton(onPressed: () => setState(() { whatsappControllers.removeAt(index); whatsappPrefixes.removeAt(index); }), icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 28)),
        ],
      ),
    );
  }

  Widget _buildPhoneRow(int index) {
    final color = Colors.green[800]!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PrefixSelector(onSelected: (p) => setState(() {
              telefonoPrefixes[index] = p;
              if (index == 0 && whatsappPrefixes.isNotEmpty) whatsappPrefixes[0] = p;
            })))),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: color.withOpacity(0.1))),
              child: Text(telefonoPrefixes[index], style: TextStyle(fontWeight: FontWeight.bold, color: color)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: telefonoControllers[index],
              onChanged: index == 0 ? (val) => setState(() {
                if (whatsappControllers.isNotEmpty) whatsappControllers[0].text = val;
              }) : null,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              decoration: InputDecoration(
                hintText: index == 0 ? "profile_hint_main".tr() : "profile_hint_extra".tr(),
                hintStyle: TextStyle(color: color.withOpacity(0.3), fontSize: 13),
                filled: true,
                fillColor: Colors.white.withOpacity(0.8),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: color.withOpacity(0.1))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: color.withOpacity(0.1))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: color, width: 1.5)),
              ),
            ),
          ),
          if (index > 0)
            IconButton(onPressed: () => setState(() { telefonoControllers.removeAt(index); telefonoPrefixes.removeAt(index); }), icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 28)),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildPokeCard(
            title: "profile_section_map".tr(),
            color: const Color(0xFFFFF1E6),
            accentColor: const Color(0xFFFFB347),
            icon: Icons.map_rounded,
            children: [
              _buildLabel("profile_map_instruction".tr()),
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orangeAccent.withOpacity(0.3), width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _selectedPosition ?? const LatLng(41.9028, 12.4964),
                          initialZoom: _selectedPosition != null ? 15.0 : 5.0,
                          onTap: (tapPos, latlng) {
                            setState(() {
                              _selectedPosition = latlng;
                              _showConfirmButton = true;
                            });
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.petping.app',
                          ),
                          if (_selectedPosition != null)
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: _selectedPosition!,
                                  width: 40,
                                  height: 40,
                                  child: const Icon(Icons.person_pin_circle, color: Colors.orange, size: 40),
                                ),
                              ],
                            ),
                        ],
                      ),

                      Positioned(
                        top: 10, left: 10, right: 10,
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.95), borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)]),
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
                            decoration: InputDecoration(
                              hintText: "profile_map_search_hint".tr(),
                              border: InputBorder.none,
                              prefixIcon: const Icon(Icons.search, size: 18, color: Colors.orangeAccent),
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              suffixIcon: _isSearching
                                ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orangeAccent))
                                : IconButton(icon: const Icon(Icons.send_rounded, size: 18), onPressed: () => _searchAddress(_searchController.text)),
                            ),
                            onSubmitted: (val) => _searchAddress(val),
                          ),
                        ),
                      ),

                      if (_showConfirmButton)
                        Positioned(
                          bottom: 10, left: 50, right: 50,
                          child: GestureDetector(
                            onTap: _handleConfirm,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(color: Colors.orangeAccent, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 5)]),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                                  const SizedBox(width: 8),
                                  Text("profile_btn_confirm_pos".tr(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),
              _buildField("profile_label_country".tr(), nazioneController, Icons.public_rounded, 'nazione', labelColor: const Color(0xFFD35400)),
              const SizedBox(height: 15),
              _buildField("profile_label_region".tr(), RegioneController, Icons.explore_outlined, 'regione', labelColor: const Color(0xFFD35400)),
              const SizedBox(height: 15),
              _buildField("profile_label_city".tr(), cittaController, Icons.location_city_rounded, 'citta', labelColor: const Color(0xFFD35400)),
              const SizedBox(height: 15),
              _buildField("profile_label_neighborhood".tr(), quartiereController, Icons.near_me_rounded, 'quartiere', labelColor: const Color(0xFFD35400)),
              const SizedBox(height: 15),
              _buildField("profile_label_address".tr(), indirizzoController, Icons.home_rounded, 'indirizzo', labelColor: const Color(0xFFD35400)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text, style: const TextStyle(color: Color(0xFFD35400), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.0)),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, String visKey, {int maxLines = 1, required Color labelColor, bool hideLabel = false}) {
    bool isLocked = isPetSitter && (visKey == 'nome' || visKey == 'cognome');

    if (visKey == 'bio') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 16, color: labelColor),
            const SizedBox(width: 8),
            Text(label.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: labelColor, letterSpacing: 0.8)),
            const Spacer(),
            _buildVisibilityBadge(visKey, controller),
          ]),
          const SizedBox(height: 18),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: labelColor.withOpacity(0.15), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: labelColor.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: TextFormField(
                    controller: controller,
                    maxLines: maxLines,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, height: 1.4, color: Color(0xFF1E293B)),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "profile_hint_bio".tr(),
                      hintStyle: TextStyle(color: labelColor.withOpacity(0.3), fontSize: 13, fontStyle: FontStyle.italic),
                      contentPadding: const EdgeInsets.fromLTRB(20, 25, 20, 20),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      counterText: "",
                    ),
                  ),
                ),
              ),
              Positioned(
                top: -12,
                left: 15,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: labelColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: labelColor.withOpacity(0.3), blurRadius: 5, offset: const Offset(0, 2))],
                  ),
                  child: Text(
                    "profile_bio_history_label".tr(),
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ValueListenableBuilder(
              valueListenable: controller,
              builder: (context, value, child) {
                return Text(
                  "profile_bio_char_count".tr(args: [value.text.length.toString()]),
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: labelColor.withOpacity(0.4)),
                );
              },
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!hideLabel)
          Row(children: [
            Icon(icon, size: 16, color: labelColor),
            const SizedBox(width: 8),
            Text(label.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: labelColor, letterSpacing: 0.8)),
            const Spacer(),
            if (visKey != 'username') _buildVisibilityBadge(visKey, controller),
          ]),
        if (!hideLabel) const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          readOnly: isLocked,
          validator: visKey == 'username' ? (v) => v == null || v.trim().isEmpty ? 'profile_error_username_required'.tr() : null : null,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.8),
            suffixIcon: isLocked ? const Icon(Icons.lock_outline, size: 18, color: Colors.orange) : null,
            hintText: isLocked ? "profile_locked_hint".tr() : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: labelColor.withOpacity(0.1))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: labelColor.withOpacity(0.1))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: labelColor, width: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionTile({required String label, required String visKey, required String value, required IconData icon, required Color color, required Color accent, required VoidCallback onTap}) {
    bool isLocked = isPetSitter && visKey == 'dataNascita' && value != "profile_select_placeholder".tr();

    return Column(
      children: [
        GestureDetector(
          onTap: isLocked ? null : onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(22), border: Border.all(color: accent.withOpacity(0.2), width: 2)),
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(icon, size: 14, color: accent),
                  if (label.isNotEmpty) ...[const SizedBox(width: 6), Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: accent.withOpacity(0.7), letterSpacing: 1))],
                  if (isLocked) ...[const SizedBox(width: 6), const Icon(Icons.lock_outline, size: 12, color: Colors.orange)],
                ]),
                const SizedBox(height: 6),
                Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: accent), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        _buildVisibilityBadge(visKey),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Colors.orangeAccent),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => dataNascitaController.text = DateFormat('dd/MM/yyyy').format(picked));
    }
  }

  void _showSessoPicker() {
    showModalBottomSheet(context: context, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))), builder: (context) => Container(padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24), child: Column(mainAxisSize: MainAxisSize.min, children: ['Maschio', 'Femmina', 'Altro', 'Non specificato'].map((s) => ListTile(leading: Icon(s == 'Maschio' ? Icons.male : (s == 'Femmina' ? Icons.female : Icons.transgender), color: Colors.purple), title: Text(s == 'Maschio' ? 'gender_male'.tr() : (s == 'Femmina' ? 'gender_female'.tr() : (s == 'Altro' ? 'gender_other'.tr() : 'gender_not_specified'.tr())), style: const TextStyle(fontWeight: FontWeight.bold)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), onTap: () { setState(() => sesso = s); Navigator.pop(context); })).toList())));
  }

  Widget _buildVisibilityBadge(String key, [TextEditingController? controller]) {
    bool isVisible = visibilita[key] ?? false;
    return GestureDetector(
      onTap: () {
        setState(() {
          visibilita[key] = !isVisible;
          if (visibilita[key] == true && (key == 'indirizzo' || key == 'citta' || key == 'regione')) {
            visibilita['nazione'] = true;
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: isVisible ? Colors.green[50] : Colors.grey[200], borderRadius: BorderRadius.circular(12), border: Border.all(color: isVisible ? Colors.green[300]! : Colors.grey[400]!, width: 1.5)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(isVisible ? Icons.visibility : Icons.visibility_off, size: 12, color: isVisible ? Colors.green[700] : Colors.grey[600]), const SizedBox(width: 6), Text(isVisible ? "profile_visibility_public".tr() : "profile_visibility_private".tr(), style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: isVisible ? Colors.green[700] : Colors.grey[600]))]),
      ),
    );
  }

  Widget _buildPokeCard({required String title, required Color color, required Color accentColor, required IconData icon, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), border: Border.all(color: color, width: 4), boxShadow: [BoxShadow(color: accentColor.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))]),
      child: Column(
        children: [
          Container(padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20), decoration: BoxDecoration(gradient: LinearGradient(colors: [color, color.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: const BorderRadius.vertical(top: Radius.circular(28))), child: Row(children: [Icon(icon, size: 22, color: accentColor), const SizedBox(width: 10), Text(title.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w900, color: accentColor, letterSpacing: 1.2))])),
          Padding(padding: const EdgeInsets.all(20), child: Column(children: children)),
        ],
      ),
    );
  }

  Widget _buildDynamicRow(int index, TextEditingController controller, List list, IconData icon, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            decoration: InputDecoration(
              hintText: index == 0 ? "profile_hint_main".tr() : "profile_hint_extra".tr(),
              hintStyle: TextStyle(color: color.withOpacity(0.3), fontSize: 13),
              filled: true,
              fillColor: Colors.white.withOpacity(0.8),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: color.withOpacity(0.1))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: color.withOpacity(0.1))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: color, width: 1.5)),
            ),
          ),
        ),
        if (index > 0)
          Padding(padding: const EdgeInsets.only(top: 8, left: 8), child: IconButton(onPressed: () => setState(() => list.removeAt(index)), icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 28))),
      ],
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blueAccent.withOpacity(0.2), width: 4),
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.blue[50],
              backgroundImage: _selectedImage != null
                  ? FileImage(_selectedImage!)
                  : (fotoUrl != null && fotoUrl!.isNotEmpty ? NetworkImage(fotoUrl!) : null) as ImageProvider?,
              child: _isUploadingPhoto
                  ? const CircularProgressIndicator(color: Colors.blueAccent)
                  : (fotoUrl == null || fotoUrl!.isEmpty) && _selectedImage == null
                      ? Icon(Icons.person_add_rounded, size: 45, color: Colors.blue[200])
                      : null,
            ),
          ),
          GestureDetector(
            onTap: _isUploadingPhoto ? null : _pickAndUploadImage,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: _isUploadingPhoto ? Colors.grey : Colors.blueAccent,
              child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 35),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, -5))]),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isUploadingPhoto ? null : _salvaEChiudi,
              style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(18),
                  side: BorderSide(color: Colors.grey[300]!, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
              child: Text("profile_btn_save_exit".tr(),
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      color: _isUploadingPhoto ? Colors.grey[400] : Colors.grey[700],
                      letterSpacing: 1)),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: ElevatedButton(
              onPressed: _isUploadingPhoto
                  ? null
                  : () {
                      if (_tabController.index < 2) {
                        _tabController.animateTo(_tabController.index + 1,
                            duration: const Duration(milliseconds: 500), curve: Curves.easeOutBack);
                      } else {
                        _salvaProfilo();
                      }
                    },
              style: ElevatedButton.styleFrom(
                  backgroundColor: _isUploadingPhoto ? Colors.grey : Colors.blueAccent,
                  elevation: 5,
                  shadowColor: Colors.blueAccent.withOpacity(0.4),
                  padding: const EdgeInsets.all(18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
              child: _isUploadingPhoto
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(_tabController.index == 2 ? "profile_btn_confirm_pos".tr() : "profile_btn_next".tr(),
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 12, color: Colors.white, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadImage() async {
    final image = await ImagePickerHelper.pickImageFromGallery();
    if (image != null) {
      if (!mounted) return;
      final editedImage = await Navigator.push<File>(
          context, MaterialPageRoute(builder: (_) => PhotoEditorPage(imageFile: image)));
      if (editedImage != null) {
        setState(() {
          _selectedImage = editedImage;
          _isUploadingPhoto = true;
        });
        try {
          final url = await FirebaseStorageHelper.uploadImage(editedImage, 'profile_images');
          if (url != null) {
            setState(() => fotoUrl = url);
            // Salva immediatamente l'URL nel database per evitare discrepanze
            if (user != null) {
              await FirebaseFirestore.instance
                  .collection('utenti')
                  .doc(user!.uid)
                  .update({'fotoUrl': url});
            }
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Errore durante il caricamento dell'immagine")));
          }
        } finally {
          if (mounted) setState(() => _isUploadingPhoto = false);
        }
      }
    }
  }

  Widget _sectionHeader(String text) {
    return Padding(padding: const EdgeInsets.only(bottom: 0, top: 8), child: Text(text.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.blueGrey, letterSpacing: 1.2)));
  }

  Widget _addBtn(VoidCallback onTap, String label) {
    return TextButton.icon(onPressed: onTap, icon: const Icon(Icons.add_circle_outline_rounded, size: 20), label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)));
  }
}
