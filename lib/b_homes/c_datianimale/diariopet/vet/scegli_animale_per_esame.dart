import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import 'aggiungi_esame.dart';

class ScegliAnimalePerEsame extends StatelessWidget {
  final List<String> filePaths;
  final bool isFromShare;

  const ScegliAnimalePerEsame({
    super.key, 
    required this.filePaths,
    this.isFromShare = false,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text("vet_access_required".tr())),
        body: Center(child: Text("vet_login_to_upload".tr())),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("vet_choose_animal_title".tr()),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('animali')
            .where('userId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final animali = snapshot.data?.docs ?? [];

          if (animali.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Text(
                  "vet_no_animals_registered".tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: animali.length,
            itemBuilder: (context, index) {
              final doc = animali[index];
              final data = doc.data() as Map<String, dynamic>;
              final nome = data['nome'] ?? 'vet_no_name'.tr();

              return Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.pets)),
                  title: Text(nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AggiungiEsame(
                          animaleId: doc.id,
                          filePaths: filePaths,
                          isFromShare: isFromShare,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
