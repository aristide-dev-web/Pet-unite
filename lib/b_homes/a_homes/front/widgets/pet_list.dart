import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petping/b_homes/c_datianimale/tab_pet.dart';
import 'package:petping/b_homes/c_datianimale/a/pet_card.dart';
import 'package:petping/utils/navigator_helpers.dart';
import 'package:easy_localization/easy_localization.dart';

class PetList extends StatelessWidget {
  final String currentUserId;

  const PetList({super.key, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('animali')
            .where('userId', isEqualTo: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox.shrink();
          final pets = snapshot.data!.docs;
          if (pets.isEmpty) {
            return Padding(
              padding: const EdgeInsets.only(left: 25),
              child: Text(
                'home_empty_pets'.tr(),
                style: const TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: pets.length,
            itemBuilder: (context, index) {
              final doc = pets[index];
              final data = doc.data() as Map<String, dynamic>;

              return GestureDetector(
                onTap: () => pushWithFadeSlow(context, TabPet(animaleId: doc.id)),
                child: Container(
                  width: 170,
                  margin: const EdgeInsets.only(right: 15, bottom: 10, left: 5, top: 5),
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: SizedBox(
                      width: 180,
                      height: 210,
                      child: CartaAnimale(
                        animaleId: doc.id,
                        nome: data['nome'] ?? 'home_pet_fallback'.tr(),
                        sesso: data['sesso'] ?? 'gender_male'.tr(),
                        razza: data['razza'] ?? 'label_none'.tr(),
                        note: '',
                        temaCarta: data['temaCarta'] ?? 'nuvola_rosa',
                        fotoUrl: data['fotoUrl'],
                        day: data['day'],
                        month: data['month'],
                        year: data['year'],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
