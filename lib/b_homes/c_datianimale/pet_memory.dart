import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import 'addati/aggiungi_animale.dart';
import 'diariopet/profilo_animale.dart';

class PetMemory extends StatelessWidget {
  const PetMemory({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(child: Text('qr_user_not_authenticated'.tr()));
    }

    return Scaffold(
      appBar: AppBar(title: Text('pet_list_title'.tr())),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('animali')
            .where('userId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('pet_list_empty'.tr()));
          }

          final animali = snapshot.data!.docs;

          return ListView.builder(
            itemCount: animali.length,
            itemBuilder: (context, index) {
              final data = animali[index].data() as Map<String, dynamic>;
              final animaleId = animali[index].id;

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      data['fotoUrl'] != null && data['fotoUrl'] != ''
                      ? NetworkImage(data['fotoUrl'])
                      : const AssetImage('assets/images/default_pet.png')
                            as ImageProvider,
                ),
                title: Text(data['nome'] ?? 'label_none'.tr()),
                subtitle: Text(
                  '${data['tipo'] ?? ''} - ${data['razza'] ?? ''}',
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProfiloAnimale(animaleId: animaleId),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AggiungiAnimale()),
          );
        },
        tooltip: 'home_btn_add'.tr(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
