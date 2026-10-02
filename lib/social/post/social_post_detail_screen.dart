import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petping/social/post/social_post_model.dart';
import 'package:petping/style/pet_style.dart';
import 'package:petping/utils/notific_principal.dart';
import 'package:easy_localization/easy_localization.dart';

class SocialPostDetailScreen extends StatefulWidget {
  final String postId;
  final String currentUserId;

  const SocialPostDetailScreen({
    super.key,
    required this.postId,
    required this.currentUserId,
  });

  @override
  State<SocialPostDetailScreen> createState() => _SocialPostDetailScreenState();
}

class _SocialPostDetailScreenState extends State<SocialPostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('social_tab_feed'.tr(), style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('post').doc(widget.postId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (!snapshot.data!.exists) return Center(child: Text("post_detail_not_exists".tr()));

          final post = SocialPost.fromFirestore(snapshot.data!);
          
          return Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    _buildPostHeader(post),
                    if (post.testo.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Text(post.testo, style: const TextStyle(fontSize: 16, height: 1.4)),
                      ),
                    if (post.immagineUrl != null)
                      Image.network(post.immagineUrl!, width: double.infinity, fit: BoxFit.fitWidth),
                    const Divider(),
                    _buildCommentsSection(post),
                  ],
                ),
              ),
              _buildCommentInput(post),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPostHeader(SocialPost post) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: post.fotoProfilo != null ? NetworkImage(post.fotoProfilo!) : null,
            backgroundColor: PetStyle.lightGrey,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(post.autore, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text(post.ruoloAutore, style: TextStyle(color: PetStyle.grey, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsSection(SocialPost post) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('post')
          .doc(post.id)
          .collection('commenti')
          .orderBy('timestamp')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final docs = snapshot.data!.docs;
        
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final c = docs[index].data() as Map<String, dynamic>;
            return ListTile(
              leading: CircleAvatar(
                radius: 16,
                backgroundImage: c['fotoProfilo'] != null ? NetworkImage(c['fotoProfilo']) : null,
              ),
              title: Text(c['autore'] ?? 'label_user'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: Text(c['testo'] ?? ''),
            );
          },
        );
      },
    );
  }

  Widget _buildCommentInput(SocialPost post) {
    return Container(
      padding: EdgeInsets.fromLTRB(15, 10, 15, 10 + MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              focusNode: _commentFocusNode,
              decoration: InputDecoration(hintText: "social_comment_hint".tr(), border: InputBorder.none),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: PetStyle.primary),
            onPressed: () async {
              if (_commentController.text.trim().isEmpty) return;
              final text = _commentController.text.trim();
              _commentController.clear();
              
              await FirebaseFirestore.instance.collection('post').doc(post.id).collection('commenti').add({
                'uid': widget.currentUserId,
                'autore': 'Io', // Qui andrebbe il nome reale
                'testo': text,
                'timestamp': FieldValue.serverTimestamp(),
              });

              if (post.uid != widget.currentUserId) {
                SocialNotificationService().sendNotification(
                  toUserId: post.uid,
                  type: 'comment',
                  text: 'post_notif_commented'.tr(),
                  postId: post.id,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
