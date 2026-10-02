import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petping/d_tab_sds/custodia_animali/add_custodia_uno.dart';
import 'package:petping/d_tab_sds/d_smarriti/DettaglioAnimaleScreen.dart';
import 'package:easy_localization/easy_localization.dart';

class ButtonCustodiaHome extends StatelessWidget {
  const ButtonCustodiaHome({super.key});

  @override
  Widget build(BuildContext context) {
    const Color blueSecurity = Color(0xFF2980B9); 
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('animali_custodia')
          .where('uid_utente', isEqualTo: currentUserId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return FloatingActionButton(
            heroTag: "fab_custodia_loading",
            onPressed: null,
            backgroundColor: blueSecurity.withOpacity(0.5),
            child: const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
          );
        }

        final bool hasReports = snapshot.hasData && snapshot.data!.docs.isNotEmpty;

        return FloatingActionButton.extended(
          heroTag: "fab_custodia_main",
          onPressed: () {
            if (hasReports) {
              _mostraDashboardCustodia(context, currentUserId);
            } else {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AddCustodiaUno()));
            }
          },
          backgroundColor: blueSecurity,
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          icon: Icon(
            hasReports ? Icons.view_list_rounded : Icons.handshake_rounded,
            color: Colors.white,
          ),
          label: Text(
            hasReports ? "custodia_fab_my_ads_label".tr() : "custodia_fab_found_label".tr(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1),
          ),
        );
      },
    );
  }

  void _mostraDashboardCustodia(BuildContext context, String userId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DashboardCustodiaContent(
          currentUserId: userId,
          onAdd: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddCustodiaUno()))
      ),
    );
  }
}

class _DashboardCustodiaContent extends StatelessWidget {
  final String currentUserId;
  final VoidCallback onAdd;
  const _DashboardCustodiaContent({required this.currentUserId, required this.onAdd});

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
          Text("custodia_dash_title".tr(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF2C3E50))),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('animali_custodia').where('uid_utente', isEqualTo: currentUserId).snapshots(),
              builder: (context, snapshot) {
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) return Center(child: Text("sos_dash_empty".tr()));
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return ListTile(
                      leading: CircleAvatar(backgroundImage: (data['immagine'] != null && data['immagine'] != '') ? NetworkImage(data['immagine']) : null, child: (data['immagine'] == null || data['immagine'] == '') ? const Icon(Icons.pets) : null),
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
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2980B9), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              child: Text("custodia_btn_new".tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
