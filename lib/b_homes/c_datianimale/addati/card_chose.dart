import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:petping/b_homes/a_homes/front/widgets/premium_paywall_dialog.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../tab_pet.dart'; 
import '../diariopet/back_diario.dart';
import 'package:easy_localization/easy_localization.dart';

class CardChose extends StatefulWidget {
  final Map<String, dynamic> datiAnimale;
  final File? foto;
  final List<File> fotoPassaporto;
  final String? temaIniziale;
  final String? animaleId; 

  const CardChose({
    super.key,
    required this.datiAnimale,
    required this.foto,
    required this.fotoPassaporto,
    this.temaIniziale,
    this.animaleId,
  });

  @override
  State<CardChose> createState() => _CardChoseState();
}

class _CardChoseState extends State<CardChose> with TickerProviderStateMixin, WidgetsBindingObserver {
  String? selected;
  late AnimationController _animationController;
  List<String> temiOrdinati = [];
  bool _isSaving = false;
  bool _isPremiumUser = false;

  final List<String> temiPremium = [
    "tigrato", "leopardato", "leopardato2", "leopardato_azzurro", "pink_leopard", "zebrato", "galassia", "oro"
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    selected = widget.temaIniziale;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _checkPremiumStatus();

    final List<String> temiBase = [
      "vortice_verde", "vortice_marrone", "vortice_blu", "vortice_viola", "aurora_artica", 
      "foresta_incantata", "oceano_cristallino", "deserto_seta", "terra_nobile", "energia_solare", 
      "nuvola_rosa", "fenicottero", "rosa_shocking", "galassia", "oro", "neon", 
      "arancione", "beije", "ghiaccio", "marrone", "verde", "verde_acqua",
      "tigrato", "leopardato", "leopardato2", "leopardato_azzurro", "pink_leopard", "zebrato"
    ];

    temiOrdinati = List.from(temiBase);
    if (widget.temaIniziale != null && temiOrdinati.contains(widget.temaIniziale)) {
      temiOrdinati.remove(widget.temaIniziale);
      temiOrdinati.insert(0, widget.temaIniziale!);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (var tema in temiOrdinati) {
      if (!_isProcedural(tema)) {
        precacheImage(_getAssetImage(tema), context);
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPremiumStatus();
    }
  }

  Future<void> _checkPremiumStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload(); 
      final doc = await FirebaseFirestore.instance.collection('utenti').doc(user.uid).get();
      if (mounted) {
        setState(() {
          _isPremiumUser = doc.data()?['isPremiumSOS'] == true;
        });
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _eseguiSalvataggio() async {
    if (selected == null) return;
    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw "User not logged in";

      final finalData = Map<String, dynamic>.from(widget.datiAnimale);
      finalData['temaCarta'] = selected;
      finalData['coloreDominante'] = selected; 
      finalData['userId'] = user.uid;
      finalData['updatedAt'] = Timestamp.now();

      String docId = widget.animaleId ?? "";

      if (widget.animaleId != null) {
        await FirebaseFirestore.instance.collection('animali').doc(widget.animaleId).update(finalData);
      } else {
        finalData['createdAt'] = Timestamp.now();
        final docRef = await FirebaseFirestore.instance.collection('animali').add(finalData);
        docId = docRef.id;
      }

      String? photoUrl;
      if (widget.foto != null && docId.isNotEmpty) {
        final ref = FirebaseStorage.instance.ref().child('foto_animali/$docId.jpg');
        await ref.putFile(widget.foto!);
        photoUrl = await ref.getDownloadURL();
        await FirebaseFirestore.instance.collection('animali').doc(docId).update({'fotoUrl': photoUrl});
      }

      final box = Hive.box<Animale>(animaliBoxName);
      final existingPet = box.get(docId);
      if (existingPet != null) {
        final updatedPet = Animale(
          id: docId,
          nome: finalData['nome'] ?? existingPet.nome,
          tipo: finalData['tipo'] ?? existingPet.tipo,
          razza: finalData['razza'] ?? existingPet.razza,
          sesso: finalData['sesso'] ?? existingPet.sesso,
          taglia: finalData['taglia'] ?? existingPet.taglia,
          peso: (finalData['peso'] ?? existingPet.peso).toString(),
          day: finalData['day'] ?? existingPet.day,
          month: finalData['month'] ?? existingPet.month,
          year: finalData['year'] ?? existingPet.year,
          coloreDominante: selected!,
          coloreSecondario: finalData['coloreSecondario'] ?? existingPet.coloreSecondario,
          coloreTerziario: finalData['coloreTerziario'] ?? existingPet.coloreTerziario,
          peloGrandezza: finalData['peloGrandezza'] ?? existingPet.peloGrandezza,
          peloTipo: finalData['peloTipo'] ?? existingPet.peloTipo,
          codaGrandezza: finalData['codaGrandezza'] ?? existingPet.codaGrandezza,
          codaTipo: finalData['codaTipo'] ?? existingPet.codaTipo,
          orecchieGrandezza: finalData['orecchieGrandezza'] ?? existingPet.orecchieGrandezza,
          orecchieTipo: finalData['orecchieTipo'] ?? existingPet.orecchieTipo,
          occhiColore: finalData['occhiColore'] ?? existingPet.occhiColore,
          occhiForma: finalData['occhiForma'] ?? existingPet.occhiForma,
          microchip: finalData['microchip'] ?? existingPet.microchip,
          microchipNumero: finalData['microchipNumero'] ?? existingPet.microchipNumero,
          vaccinato: finalData['vaccinato'] ?? existingPet.vaccinato,
          riproduttivo: finalData['riproduttivo'] ?? existingPet.riproduttivo,
          iperteso: finalData['iperteso'] ?? existingPet.iperteso,
          allergico: finalData['allergico'] ?? existingPet.allergico,
          allergie: finalData['allergie'] ?? existingPet.allergie,
          passaporto: finalData['passaporto'] ?? existingPet.passaporto,
          passaportoNumero: finalData['passaportoNumero'] ?? existingPet.passaportoNumero,
          passaportoNote: finalData['passaportoNote'] ?? existingPet.passaportoNote,
          noteGenerali: finalData['noteGenerali'] ?? existingPet.noteGenerali,
          fotoUrl: photoUrl ?? existingPet.fotoUrl,
          fegato: finalData['fegato'] ?? existingPet.fegato,
          fotoPassaportoUrls: existingPet.fotoPassaportoUrls,
        );
        await box.put(docId, updatedPet);
      }

      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.push(context, MaterialPageRoute(builder: (context) => TabPet(animaleId: docId)));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.animaleId != null ? 'profile_edit_success'.tr() : 'pet_card_creation_success'.tr()), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('snack_error_msg'.tr(args: [e.toString()])), backgroundColor: Colors.redAccent));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('pet_card_style_title'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.transparent, elevation: 0, centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity, height: double.infinity,
            decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFE1F5FE), Color(0xFFFFCCBC)])),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildPreview(),
                Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Text('pet_card_style_subtitle'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12),
                    itemCount: temiOrdinati.length,
                    itemBuilder: (context, index) => _buildThemeItem(temiOrdinati[index]),
                  ),
                )
              ],
            ),
          ),
          if (_isSaving) Container(color: Colors.black54, child: const Center(child: CircularProgressIndicator(color: Colors.white))),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildPreview() {
    return Container(
      height: 200, margin: const EdgeInsets.all(20), decoration: _getPreviewDecoration(),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Container(
                width: 80, height: 80, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)]),
                child: CircleAvatar(radius: 38, backgroundColor: Colors.white24, backgroundImage: widget.foto != null ? FileImage(widget.foto!) : null, child: widget.foto == null ? const Icon(Icons.pets, color: Colors.white, size: 30) : null),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 100),
              child: Text(
                selected?.replaceAll("_", " ").toUpperCase() ?? 'label_select_upper'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(color: _getPreviewTextColor(), fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 2, shadows: [if (selected != "neon") const Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2)), if (selected == "neon") const Shadow(color: Color(0xFF00FBFF), blurRadius: 10)]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPreviewTextColor() { if (selected == "neon") return const Color(0xFF00FBFF); if (["terra_nobile", "galassia", "rosa_shocking", "foresta_incantata", "vortice_marrone", "vortice_viola", "vortice_blu", "tigrato", "leopardato", "leopardato2", "leopardato_azzurro", "pink_leopard", "zebrato"].contains(selected)) return Colors.white; return Colors.black87; }

  BoxDecoration _getPreviewDecoration() {
    String t = selected ?? "beije";
    switch (t) {
      case "vortice_verde": return BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const RadialGradient(center: Alignment(-0.5, -0.6), radius: 1.5, colors: [Color(0xFFCCFF90), Color(0xFF76FF03), Color(0xFF64DD17)]));
      case "vortice_marrone": return BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const RadialGradient(center: Alignment(0.4, -0.3), radius: 1.6, colors: [Color(0xFF8D6E63), Color(0xFF5D4037), Color(0xFF3E2723)]));
      case "vortice_blu": return BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const RadialGradient(center: Alignment(-0.2, 0.5), radius: 1.4, colors: [Color(0xFF4FC3F7), Color(0xFF0288D1), Color(0xFF01579B)]));
      case "vortice_viola": return BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const RadialGradient(center: Alignment(0.6, 0.6), radius: 1.5, colors: [Color(0xFFE1BEE7), Color(0xFFBA68C8), Color(0xFF7B1FA2)]));
      case "nuvola_rosa": return BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors: [Color(0xFFFFE0E9), Color(0xFFFFB2C5)]));
      case "fenicottero": return BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors: [Color(0xFFFF80AB), Color(0xFFF06292)]));
      case "rosa_shocking": return BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors: [Color(0xFFFF4081), Color(0xFFC2185B)]));
      case "aurora_artica": return BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors: [Color(0xFFE0F7FA), Color(0xFF80DEEA)]));
      case "foresta_incantata": return BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)]));
      case "oceano_cristallino": return BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors: [Color(0xFF006064), Color(0xFF00ACC1)]));
      case "deserto_seta": return BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors: [Color(0xFFF5F5DC), Color(0xFFFFF9C4)]));
      case "terra_nobile": return BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors: [Color(0xFF3E2723), Color(0xFF5D4037)]));
      case "energia_solare": return BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors: [Color(0xFFFF6F00), Color(0xFFFFAB40)]));
      case "galassia": return BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors: [Color(0xFF1A237E), Color(0xFF880E4F)]));
      case "oro": return BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors: [Color(0xFFB8860B), Color(0xFFFFD700)]), border: Border.all(color: Colors.amber, width: 2));
      case "neon": return BoxDecoration(borderRadius: BorderRadius.circular(24), color: Colors.black, border: Border.all(color: const Color(0xFF00FBFF), width: 2));
      default: 
        String ext = "png";
        if (t == "tigrato" || t == "leopardato2" || t == "leopardato_azzurro") ext = "jpeg";
        if (t == "leopardato" || t == "pink_leopard" || t == "zebrato") ext = "jpg";
        String fileName = t;
        if (t == "leopardato_azzurro") fileName = "leopardato azzurro";
        if (t == "pink_leopard") fileName = "pink-leopard-print-q7955099k8tt6psh";
        return BoxDecoration(borderRadius: BorderRadius.circular(24), image: DecorationImage(image: AssetImage("assets/petcard/$fileName.$ext"), fit: BoxFit.cover, onError: (e, s) => const AssetImage("assets/petcard/beije.png")));
    }
  }

  Widget _buildThemeItem(String tema) {
    bool isSel = selected == tema;
    bool isPremium = temiPremium.contains(tema);
    bool isBlocked = isPremium && !_isPremiumUser;

    return GestureDetector(
      onTap: () async {
        if (isBlocked) {
          final result = await PremiumPaywallDialog.show(context);
          if (result == true) {
            _checkPremiumStatus();
          }
        } else {
          setState(() => selected = tema);
        }
      },
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: isSel ? Colors.blueAccent : Colors.white, width: 3),
              gradient: _getThemeGradient(tema),
              color: _isProcedural(tema) ? null : Colors.white,
              image: _isProcedural(tema) ? null : DecorationImage(image: _getAssetImage(tema), fit: BoxFit.cover, onError: (e, s) => {}),
            ),
            child: isSel ? const Center(child: Icon(Icons.check_circle, color: Colors.white, size: 30)) : null,
          ),
          if (isBlocked)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(15)),
                child: const Icon(Icons.lock_rounded, color: Colors.amber, size: 24),
              ),
            ),
        ],
      ),
    );
  }

  AssetImage _getAssetImage(String t) {
    String ext = "png";
    if (t == "tigrato" || t == "leopardato2" || t == "leopardato_azzurro") ext = "jpeg";
    if (t == "leopardato" || t == "pink_leopard" || t == "zebrato") ext = "jpg";
    String fileName = t;
    if (t == "leopardato_azzurro") fileName = "leopardato azzurro";
    if (t == "pink_leopard") fileName = "pink-leopard-print-q7955099k8tt6psh";
    return AssetImage("assets/petcard/$fileName.$ext");
  }

  bool _isProcedural(String t) => ["vortice_verde", "vortice_marrone", "vortice_blu", "vortice_viola", "aurora_artica", "foresta_incantata", "oceano_cristallino", "deserto_seta", "terra_nobile", "energia_solare", "nuvola_rosa", "fenicottero", "rosa_shocking", "galassia", "oro", "neon"].contains(t);

  Gradient? _getThemeGradient(String t) {
    switch (t) {
      case "vortice_verde": return const RadialGradient(colors: [Color(0xFFCCFF90), Color(0xFF64DD17)]);
      case "vortice_marrone": return const RadialGradient(colors: [Color(0xFF8D6E63), Color(0xFF3E2723)]);
      case "vortice_blu": return const RadialGradient(colors: [Color(0xFF4FC3F7), Color(0xFF01579B)]);
      case "vortice_viola": return const RadialGradient(colors: [Color(0xFFE1BEE7), Color(0xFF7B1FA2)]);
      case "nuvola_rosa": return const LinearGradient(colors: [Color(0xFFFFE0E9), Color(0xFFFFB2C5)]);
      case "fenicottero": return const LinearGradient(colors: [Color(0xFFFF80AB), Color(0xFFF06292)]);
      case "rosa_shocking": return const LinearGradient(colors: [Color(0xFFFF4081), Color(0xFFC2185B)]);
      case "aurora_artica": return const LinearGradient(colors: [Color(0xFFE0F7FA), Color(0xFF80DEEA)]);
      case "foresta_incantata": return const LinearGradient(colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)]);
      case "oceano_cristallino": return const LinearGradient(colors: [Color(0xFF006064), Color(0xFF00ACC1)]);
      case "deserto_seta": return const LinearGradient(colors: [Color(0xFFF5F5DC), Color(0xFFFFF9C4)]);
      case "terra_nobile": return const LinearGradient(colors: [Color(0xFF3E2723), Color(0xFF5D4037)]);
      case "energia_solare": return const LinearGradient(colors: [Color(0xFFFF6F00), Color(0xFFFFAB40)]);
      case "galassia": return const LinearGradient(colors: [Color(0xFF1A237E), Color(0xFF880E4F)]);
      case "oro": return const LinearGradient(colors: [Color(0xFFB8860B), Color(0xFFFFD700)]);
      default: return null;
    }
  }

  Widget _buildBottomBar() => Padding(
    padding: const EdgeInsets.fromLTRB(25, 10, 25, 30),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 5),
      onPressed: (selected == null || _isSaving) ? null : _eseguiSalvataggio,
      child: Text(_isSaving ? 'btn_saving_upper'.tr() : 'btn_save_complete_upper'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))
    )
  );
}

class AnimalCartoonPainter extends CustomPainter {
  final double animationValue;
  AnimalCartoonPainter({required this.animationValue});
  @override void paint(Canvas canvas, Size size) {}
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
