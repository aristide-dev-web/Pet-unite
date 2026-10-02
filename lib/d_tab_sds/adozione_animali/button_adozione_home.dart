import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petping/d_tab_sds/adozione_animali/add/add_adozione_uno.dart';
import 'package:petping/d_tab_sds/d_smarriti/DettaglioAnimaleScreen.dart';
import 'package:easy_localization/easy_localization.dart';

class ButtonAdozioneHome extends StatelessWidget {
  const ButtonAdozioneHome({super.key});

  @override
  Widget build(BuildContext context) {
    const Color greenHope = Color(0xFF27AE60);
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('animali_adozione')
          .where('uid_utente', isEqualTo: currentUserId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return FloatingActionButton(
            heroTag: "fab_adozione_loading",
            onPressed: null,
            backgroundColor: greenHope.withOpacity(0.5),
            child: const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
          );
        }

        final bool hasReports = snapshot.hasData && snapshot.data!.docs.isNotEmpty;

        return FloatingActionButton.extended(
          heroTag: "fab_adozione_main",
          onPressed: () {
            if (hasReports) {
              _mostraDashboardAdozioni(context, currentUserId);
            } else {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AddAdozioneUno()));
            }
          },
          backgroundColor: greenHope,
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          icon: Icon(
            hasReports ? Icons.favorite_rounded : Icons.add_circle_outline_rounded,
            color: Colors.white,
          ),
          label: Text(
            hasReports ? "adozione_fab_main_label".tr() : "adozione_fab_add_label".tr(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1),
          ),
        );
      },
    );
  }

  void _mostraDashboardAdozioni(BuildContext context, String userId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DashboardAdozioniContent(
          currentUserId: userId,
          onAdd: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddAdozioneUno()))
      ),
    );
  }
}

class _DashboardAdozioniContent extends StatelessWidget {
  final String currentUserId;
  final VoidCallback onAdd;
  const _DashboardAdozioniContent({required this.currentUserId, required this.onAdd});

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
          Text("adozione_dash_title".tr(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF2C3E50))),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('animali_adozione').where('uid_utente', isEqualTo: currentUserId).snapshots(),
              builder: (context, snapshot) {
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) return Center(child: Text("social_page_empty_posts".tr())); // Reuse or create new
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return ListTile(
                      leading: CircleAvatar(backgroundImage: (data['immagine'] != null && data['immagine'] != '') ? NetworkImage(data['immagine']) : null, child: (data['immagine'] == null || data['immagine'] == '') ? const Icon(Icons.favorite) : null),
                      title: Text(data['nome']?.toUpperCase() ?? 'pet_type_other'.tr().toUpperCase()),
                      subtitle: Text("${'profile_label_city'.tr()}: ${data['citta'] ?? 'gender_not_specified'.tr()}"),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DettaglioAnimaleScreen(data: data, currentUserId: currentUserId, docId: docs[index].id))),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () { 
                Navigator.pop(context);
                onAdd(); 
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF27AE60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              child: Text("adozione_btn_new".tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
