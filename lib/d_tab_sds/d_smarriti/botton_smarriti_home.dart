import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:petping/d_tab_sds/d_smarriti/addpet/addanimalsmar/add_uno.dart';
import 'package:petping/d_tab_sds/d_smarriti/addpet/lost_animal_data.dart';
import 'package:petping/d_tab_sds/d_smarriti/DettaglioAnimaleScreen.dart';

class BottonSmarritiHome extends StatelessWidget {
  const BottonSmarritiHome({super.key});

  @override
  Widget build(BuildContext context) {
    const Color orangeRescue = Color(0xFFE67E22);
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('animali_smarriti')
          .where('uid_utente', isEqualTo: currentUserId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return FloatingActionButton(
            heroTag: "fab_smarriti_loading",
            onPressed: null,
            backgroundColor: orangeRescue.withOpacity(0.5),
            child: const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
          );
        }

        final bool hasReports = snapshot.hasData && snapshot.data!.docs.isNotEmpty;

        return FloatingActionButton.extended(
          heroTag: "fab_smarriti_main",
          onPressed: () {
            if (hasReports) {
              _mostraDashboardSmarriti(context, currentUserId);
            } else {
              _mostraPopUpIniziale(context);
            }
          },
          backgroundColor: orangeRescue,
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          icon: Icon(
            hasReports ? Icons.pets_rounded : Icons.warning_amber_rounded,
            color: Colors.white,
          ),
          label: Text(
            hasReports ? "sos_fab_my_sos".tr() : "sos_fab_lost_pet".tr(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1),
          ),
        );
      },
    );
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

  void _mostraDashboardSmarriti(BuildContext context, String userId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => _DashboardSmarritiContent(
          currentUserId: userId,
          onNewReport: () => _mostraPopUpIniziale(context)
      ),
    );
  }

  Widget _buildPetSelector(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('animali').where('userId', isEqualTo: userId).snapshots(),
      builder: (snapshotContext, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 50, child: Center(child: CircularProgressIndicator(color: Colors.orange)));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("msg_no_pets_registered".tr(), style: const TextStyle(fontSize: 12, color: Colors.grey)),
          );
        }

        final pets = snapshot.data!.docs;
        return SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: pets.length,
            itemBuilder: (itemContext, index) {
              final petData = pets[index].data() as Map<String, dynamic>;
              return GestureDetector(
                onTap: () {
                  Navigator.pop(snapshotContext); // Chiude il dialogo
                  _selezionaEProcedi(context, petData); // Procedi usando il contesto originale
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.grey[100],
                        backgroundImage: (petData['fotoUrl'] != null && petData['fotoUrl'] != '') ? NetworkImage(petData['fotoUrl']) : null,
                        child: (petData['fotoUrl'] == null || petData['fotoUrl'] == '') ? const Icon(Icons.pets, color: Colors.orange) : null,
                      ),
                      const SizedBox(height: 8),
                      Text(petData['nome']?.toString().toUpperCase() ?? 'PET', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF2C3E50))),
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

  void _selezionaEProcedi(BuildContext context, Map<String, dynamic> petData) {
    dynamic getValue(List<String> keys) {
      for (var key in keys) {
        if (petData.containsKey(key) && petData[key] != null) return petData[key];
      }
      return null;
    }

    String? cleanMicrochip(dynamic val) {
      if (val == null) return null;
      String s = val.toString().replaceAll(RegExp(r'[^0-9]'), '');
      return s.length >= 5 ? s : null;
    }

    String? mapToFeature(dynamic val) {
      if (val == null) return null;
      String s = val.toString().toLowerCase();
      if (s.contains('piccol')) return 'Piccole';
      if (s.contains('grand')) return 'Grandi';
      if (s.contains('medi')) return 'Medie';
      return null;
    }

    final dataPrecompilata = LostAnimalData(
      nome: getValue(['nome', 'name']),
      tipo: getValue(['tipo', 'specie', 'species']), 
      razza: getValue(['razza', 'breed']),
      sesso: getValue(['sesso', 'gender']),
      microchipNumero: cleanMicrochip(getValue(['microchipNumero', 'microchip', 'codice_microchip', 'chip'])),
      coloreDominante: getValue(['coloreDominante', 'colore_dominante', 'colore']),
      coloreSecondario: getValue(['coloreSecondario', 'colore_secondario']),
      occhiColore: getValue(['occhiColore', 'coloreOcchi', 'colore_occhi']),
      orecchieGrandezza: mapToFeature(getValue(['orecchieGrandezza', 'orecchie'])),
      codaGrandezza: mapToFeature(getValue(['codaGrandezza', 'coda'])),
      noteCicatrici: getValue(['note', 'descrizione']),
      haCicatrici: (getValue(['note']) != null && getValue(['note']).toString().trim().isNotEmpty),
    );

    Navigator.push(context, MaterialPageRoute(builder: (context) => AddUno(prefilledData: dataPrecompilata)));
  }
}

class _DashboardSmarritiContent extends StatelessWidget {
  final String currentUserId;
  final VoidCallback onNewReport;

  const _DashboardSmarritiContent({required this.currentUserId, required this.onNewReport});

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
                      title: Text(data['nome']?.toString().toUpperCase() ?? 'PET'),
                      subtitle: Text("sos_dash_lost_at".tr(args: [data['citta'] ?? 'N/D'])),
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
