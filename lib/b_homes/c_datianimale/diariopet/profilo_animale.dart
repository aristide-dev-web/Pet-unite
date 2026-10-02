import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petping/b_homes/c_datianimale/modifica_animale.dart';
import 'package:easy_localization/easy_localization.dart';

class ProfiloAnimale extends StatelessWidget {
  final String animaleId;

  const ProfiloAnimale({super.key, required this.animaleId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('profile_data_title'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        // Proviamo a leggere dalla collezione 'animali' che è lo standard del progetto
        future: FirebaseFirestore.instance.collection('animali').doc(animaleId).get().then((doc) async {
          if (doc.exists) return doc;
          // Se non esiste in 'animali', facciamo un tentativo di backup su 'PET'
          return await FirebaseFirestore.instance.collection('PET').doc(animaleId).get();
        }),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.pets_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('pet_list_empty'.tr(), style: const TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: (data['fotoUrl'] != null && data['fotoUrl'] != '')
                          ? NetworkImage(data['fotoUrl'])
                          : null,
                      child: (data['fotoUrl'] == null || data['fotoUrl'] == '')
                          ? const Icon(Icons.pets, size: 50, color: Colors.grey)
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              
              _buildSectionTitle('pet_section_identity_birth'.tr().toUpperCase()),
              _buildInfo('pet_label_name'.tr(), data['nome']),
              _buildInfo('pet_label_type'.tr(), data['tipo']),
              _buildInfo('pet_label_breed'.tr(), data['razza']),
              _buildInfo('profile_label_gender'.tr(), data['sesso']),
              _buildInfo('profile_label_birthdate_full'.tr(), data['dataNascita']),
              _buildInfo('pet_label_weight'.tr(), data['peso'] != null ? "${data['peso']} kg" : null),
              
              const SizedBox(height: 20),
              _buildSectionTitle('pet_section_appearance'.tr().toUpperCase()),
              _buildInfo('pet_label_color_primary'.tr(), data['coloreDominante']),
              _buildInfo('pet_label_color_secondary'.tr(), data['coloreSecondario']),
              _buildInfo('pet_label_color_tertiary'.tr(), data['coloreTerziario']),
              _buildInfo('pet_label_microchip'.tr(), data['microchip']),
              _buildInfo('pet_label_microchip_num'.tr(), data['microchipNumero']),
              
              const SizedBox(height: 20),
              _buildSectionTitle('pet_section_health'.tr().toUpperCase()),
              _buildInfo('pet_label_vaccinations'.tr(), data['vaccinato']),
              _buildInfo('pet_label_sterilized'.tr(), data['riproduttivo']),
              _buildInfo('pet_label_allergic'.tr(), data['allergie']),
              _buildNoteBox('pet_label_notes'.tr(), data['noteGenerali']),
              
              const SizedBox(height: 40),
              
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.edit_rounded, size: 18),
                      label: Text('pet_menu_edit'.tr().toUpperCase()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ModificaAnimale(animaleId: animaleId),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmDelete(context, animaleId),
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      label: Text('pet_menu_delete'.tr().toUpperCase()),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: Colors.teal.shade700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildInfo(String label, dynamic value) {
    if (value == null || value.toString().trim().isEmpty || value.toString() == 'null') return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value.toString(),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.black87),
              textAlign: Alignment.centerLeft == Alignment.centerLeft ? TextAlign.right : TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteBox(String label, dynamic value) {
    if (value == null || value.toString().trim().isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 5),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.amber.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.brown)),
          const SizedBox(height: 8),
          Text(value.toString(), style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4)),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final conferma = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('dialog_confirm_delete_title'.tr()),
        content: Text('dialog_confirm_delete_text'.tr()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('btn_cancel'.tr().toUpperCase())),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('btn_delete'.tr().toUpperCase()),
          ),
        ],
      ),
    );

    if (conferma == true) {
      try {
        // Eliminiamo da entrambe le possibili collezioni per sicurezza
        await FirebaseFirestore.instance.collection('animali').doc(id).delete();
        await FirebaseFirestore.instance.collection('PET').doc(id).delete();
        if (context.mounted) Navigator.pop(context);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('msg_error_delete'.tr(args: [e.toString()]))));
        }
      }
    }
  }
}
