import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';

class LookDati extends StatefulWidget {
  const LookDati({super.key});

  @override
  State<LookDati> createState() => _LookDatiState();
}

class _LookDatiState extends State<LookDati> {
  final user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic> dati = {};
  Map<String, bool> visibilita = {};

  @override
  void initState() {
    super.initState();
    _caricaDati();
  }

  Future<void> _caricaDati() async {
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('utenti')
          .doc(user!.uid)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          dati = data;
          visibilita = Map<String, bool>.from(data['visibilita'] ?? {});
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final campi = {
      'username': 'profile_label_username'.tr(),
      'nome': 'profile_label_firstname'.tr(),
      'cognome': 'profile_label_lastname'.tr(),
      'dataNascita': 'profile_label_birthdate_full'.tr(),
      'email': 'profile_label_emails'.tr(),
      'telefono': 'profile_label_phones'.tr(),
      'nazione': 'profile_label_country'.tr(),
      'regione': 'profile_label_region'.tr(),
      'citta': 'profile_label_city'.tr(),
      'indirizzo': 'profile_label_address'.tr(),
      'bio': 'profile_label_bio'.tr(),
    };

    return Scaffold(
      appBar: AppBar(title: Text('profile_look_title'.tr())),
      body: dati.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (dati['fotoUrl'] != null &&
                    dati['fotoUrl'].toString().isNotEmpty)
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(dati['fotoUrl']),
                    ),
                  ),
                const SizedBox(height: 20),
                ...campi.entries.map((entry) {
                  final key = entry.key;
                  final label = entry.value;
                  final value = dati[key] ?? '';
                  final visibile = visibilita[key] ?? false;

                  if (!visibile || value.toString().isEmpty)
                    return const SizedBox.shrink();

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(value.toString()),
                      ],
                    ),
                  );
                }),
              ],
            ),
    );
  }
}
