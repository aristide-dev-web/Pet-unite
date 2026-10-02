import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:petping/d_tab_sds/adozione_animali/add/add_adozione_animal_screen.dart';
import 'package:petping/d_tab_sds/custodia_animali/add_custodia_uno.dart';
import 'package:petping/social/post/social_nuovo_post_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petping/social/story/social_story_editor.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petping/social/social_memoria_firebase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petping/d_tab_sds/d_smarriti/addpet/addanimalsmar/add_uno.dart';
import 'package:petping/d_tab_sds/d_smarriti/addpet/lost_animal_data.dart';
import 'package:petping/d_tab_sds/d_smarriti/DettaglioAnimaleScreen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:petping/b_homes/c_datianimale/diariopet/back_diario.dart';
import 'package:petping/petdex/petdex_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class AddChoiceScreen extends StatefulWidget {
  final String currentUserId;
  const AddChoiceScreen({super.key, required this.currentUserId});

  @override
  State<AddChoiceScreen> createState() => _AddChoiceScreenState();
}

class _AddChoiceScreenState extends State<AddChoiceScreen> with SingleTickerProviderStateMixin {
  final _socialService = SocialMemoriaFirebase();
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _nav(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _handleSosTap() async {
    final reports = await FirebaseFirestore.instance
        .collection('animali_smarriti')
        .where('uid_utente', isEqualTo: widget.currentUserId)
        .get();

    if (mounted) {
      if (reports.docs.isNotEmpty) {
        _mostraDashboardSmarriti(context);
      } else {
        _mostraPopUpIniziale(context);
      }
    }
  }

  void _mostraPopUpIniziale(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: Text("sos_dialog_hi".tr(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF2C3E50))),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "sos_dialog_select_pet".tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey, height: 1.4),
              ),
              const SizedBox(height: 25),
              Text(
                "sos_dialog_registered_pets".tr(),
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Colors.orange),
              ),
              const SizedBox(height: 15),
              _buildPetSelector(context),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text("btn_cancel".tr().toUpperCase(), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
  }

  void _mostraDashboardSmarriti(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => _SosDashboardContent(
          currentUserId: widget.currentUserId,
          onNewReport: () => _mostraPopUpIniziale(context)
      ),
    );
  }

  Widget _buildPetSelector(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Animale>(animaliBoxName).listenable(),
      builder: (context, Box<Animale> box, _) {
        final pets = box.values.toList();

        if (pets.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("add_choice_no_pets".tr(), style: const TextStyle(fontSize: 12, color: Colors.grey)),
          );
        }

        return SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: pets.length,
            itemBuilder: (itemContext, index) {
              final Animale pet = pets[index];
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _selezionaEProcedi(context, pet);
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.grey[100],
                        backgroundImage: (pet.fotoUrl != null && pet.fotoUrl != '') ? NetworkImage(pet.fotoUrl!) : null,
                        child: (pet.fotoUrl == null || pet.fotoUrl == '') ? const Icon(Icons.pets, color: Colors.orange) : null,
                      ),
                      const SizedBox(height: 8),
                      Text(pet.nome.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF2C3E50))),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _selezionaEProcedi(BuildContext context, Animale pet) {
    String? cleanMicrochip(String? val) {
      if (val == null) return null;
      String s = val.replaceAll(RegExp(r'[^0-9]'), '');
      return s.length >= 5 ? s : null;
    }

    String? mapToFeature(String? val) {
      if (val == null) return null;
      String s = val.toLowerCase();
      if (s.contains('piccol')) return 'Piccole';
      if (s.contains('grand')) return 'Grandi';
      if (s.contains('medi')) return 'Medie';
      return null;
    }

    final dataPrecompilata = LostAnimalData(
      nome: pet.nome,
      tipo: pet.tipo, 
      razza: pet.razza,
      sesso: pet.sesso,
      microchipNumero: cleanMicrochip(pet.microchipNumero),
      coloreDominante: pet.coloreDominante,
      coloreSecondario: pet.coloreSecondario,
      occhiColore: pet.occhiColore,
      orecchieGrandezza: mapToFeature(pet.orecchieGrandezza),
      codaGrandezza: mapToFeature(pet.codaGrandezza),
      noteCicatrici: pet.noteGenerali,
      haCicatrici: pet.noteGenerali.trim().isNotEmpty,
    );

    Navigator.push(context, MaterialPageRoute(builder: (context) => AddUno(prefilledData: dataPrecompilata)));
  }

  Future<void> _pickAndUploadStory() async {
    final userDoc = await FirebaseFirestore.instance.collection('utenti').doc(widget.currentUserId).get();
    final userData = userDoc.data() ?? {};
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null && mounted) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SocialStoryEditor(imageFile: File(image.path))),
      );
      if (result != null && result is Map) {
        await _socialService.creaStoria(
          uid: widget.currentUserId,
          autore: userData['username'] ?? 'User',
          fotoProfilo: userData['fotoUrl'],
          immagineFile: result['image'],
        );
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('snack_story_published'.tr())));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 30, spreadRadius: 5)
          ],
        ),
        padding: const EdgeInsets.fromLTRB(25, 15, 25, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50, height: 5,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(height: 30),
            Text(
              "add_choice_title".tr(),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A), letterSpacing: -0.5),
            ),
            const SizedBox(height: 30),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 18,
              crossAxisSpacing: 18,
              childAspectRatio: 1.1,
              children: [
                _buildItem(Icons.auto_awesome_motion_rounded, "add_choice_storie".tr(), Colors.purpleAccent, Colors.purple[100]!, _pickAndUploadStory),
                _buildItem(Icons.grid_view_rounded, "add_choice_post".tr(), const Color(0xFF64B5B4), const Color(0xFFB2DFDB), () => _nav(const SocialNuovoPostScreen())),
                _buildItem(Icons.event_available_rounded, "add_choice_evento".tr(), Colors.orangeAccent, Colors.orange[100]!, () => _nav(const SocialNuovoPostScreen(categoriaIniziale: 'eventi'))),
                _buildItem(Icons.favorite_rounded, "add_choice_donazione".tr(), Colors.pinkAccent, Colors.pink[100]!, () => _nav(const AddAdozioneAnimalScreen())),
                _buildItem(Icons.emergency_share_rounded, "add_choice_sos".tr(), Colors.redAccent, Colors.red[100]!, _handleSosTap),
                _buildItem(Icons.shield_rounded, "add_choice_custodia".tr(), Colors.blueAccent, Colors.blue[100]!, () => _nav(const AddCustodiaUno())),
                _buildItem(Icons.collections_bookmark_rounded, "PETDEX", Colors.amber, Colors.amber[100]!, () => _nav(const PetDexScreen())),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(IconData icon, String label, Color color, Color effectColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: color.withOpacity(0.1), width: 1.5),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.12), blurRadius: 15, offset: const Offset(0, 8)),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return FractionallySizedBox(
                    widthFactor: 4.0,
                    alignment: Alignment(-1.5 + (_controller.value * 3.0), 0.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            effectColor.withOpacity(0),
                            effectColor.withOpacity(0.4),
                            effectColor.withOpacity(0.6),
                            effectColor.withOpacity(0.4),
                            effectColor.withOpacity(0),
                          ],
                          stops: const [0.1, 0.4, 0.5, 0.6, 0.9],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    child: Icon(icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 10),
                  Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF2D3142))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SosDashboardContent extends StatelessWidget {
  final String currentUserId;
  final VoidCallback onNewReport;
  const _SosDashboardContent({required this.currentUserId, required this.onNewReport});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(35))),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)))),
          const SizedBox(height: 25),
          Text("sos_dash_title".tr(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF2C3E50))),
          const SizedBox(height: 25),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('animali_smarriti')
                  .where('uid_utente', isEqualTo: currentUserId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.orange));
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) return Center(child: Text("sos_dash_empty".tr()));
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: (data['immagine'] != null && data['immagine'] != '') ? NetworkImage(data['immagine']) : null,
                        child: (data['immagine'] == null || data['immagine'] == '') ? const Icon(Icons.pets) : null,
                      ),
                      title: Text(data['nome']?.toString().toUpperCase() ?? 'label_none'.tr()),
                      subtitle: Text('sos_dash_lost_at'.tr(args: [data['citta'] ?? 'gender_not_specified'.tr()])),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DettaglioAnimaleScreen(data: data, currentUserId: currentUserId, docId: docs[index].id))),
                    );
                  },
                );
              },
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                onNewReport();
              },
              icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white),
              label: Text("sos_btn_new_report".tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE67E22), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            ),
          ),
        ],
      ),
    );
  }
}
