import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SocialHomePost extends StatelessWidget {
  final String userId;

  const SocialHomePost({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('post')
          .where('userId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('pet_list_empty'.tr()));
        }

        final posts = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final doc = posts[index];
            final testo = doc['testo'] ?? '';
            final immagineUrl = doc['immagineUrl'];

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(testo),
                subtitle: immagineUrl != null && immagineUrl != ''
                    ? Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Image.network(immagineUrl),
                )
                    : null,
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'modifica') {
                      _mostraDialogModifica(context, doc);
                    } else if (value == 'elimina') {
                      doc.reference.delete();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'modifica',
                      child: Text('btn_edit_post'.tr()),
                    ),
                    PopupMenuItem(
                      value: 'elimina',
                      child: Text('btn_delete_post'.tr()),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _mostraDialogModifica(BuildContext context, DocumentSnapshot doc) {
    final controller = TextEditingController(text: doc['testo']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('btn_edit_post'.tr()),
        content: TextField(
          controller: controller,
          maxLines: null,
          decoration: InputDecoration(hintText: 'social_hint_desc_default'.tr()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('btn_cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              doc.reference.update({'testo': controller.text});
              Navigator.pop(context);
            },
            child: Text('btn_save'.tr()),
          ),
        ],
      ),
    );
  }
}