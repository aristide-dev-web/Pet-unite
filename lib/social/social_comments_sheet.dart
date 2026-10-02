import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petping/style/pet_style.dart';
import 'package:petping/social/notific/social_notification_model.dart';
import 'package:petping/utils/notific_principal.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:petping/b_homes/b_user/social_profilo_utente_screen.dart';

class SocialCommentsSheet extends StatefulWidget {
  final String postId;
  final String postOwnerId;
  final String currentUserId;
  final Map<String, dynamic> userData;

  const SocialCommentsSheet({
    super.key,
    required this.postId,
    required this.postOwnerId,
    required this.currentUserId,
    required this.userData,
  });

  @override
  State<SocialCommentsSheet> createState() => _SocialCommentsSheetState();
}

class _SocialCommentsSheetState extends State<SocialCommentsSheet> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();

  Future<void> _toggleCommentLike(String commentId, String commentOwnerId) async {
    final likeRef = FirebaseFirestore.instance
        .collection('post')
        .doc(widget.postId)
        .collection('commenti')
        .doc(commentId)
        .collection('likes')
        .doc(widget.currentUserId);
    
    final doc = await likeRef.get();

    if (doc.exists) {
      await likeRef.delete();
    } else {
      await likeRef.set({'timestamp': FieldValue.serverTimestamp()});
      if (commentOwnerId != widget.currentUserId) {
        SocialNotificationService().sendNotification(
          toUserId: commentOwnerId,
          type: 'like',
          text: 'social_comments_notif_like'.tr(),
          postId: widget.postId,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 40,
            height: 5,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
          ),
          Text("social_comments_title".tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Divider(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('post')
                  .doc(widget.postId)
                  .collection('commenti')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (ctx, i) {
                    final commentDoc = docs[i];
                    final c = commentDoc.data() as Map<String, dynamic>;
                    final commentId = commentDoc.id;
                    return ListTile(
                      leading: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SocialProfiloUtenteScreen(
                                userId: c['uid'],
                                nomeAutore: c['autore'],
                              ),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          backgroundImage: c['fotoProfilo'] != null ? NetworkImage(c['fotoProfilo']) : null,
                          radius: 18,
                        ),
                      ),
                      title: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SocialProfiloUtenteScreen(
                                    userId: c['uid'],
                                    nomeAutore: c['autore'],
                                  ),
                                ),
                              );
                            },
                            child: Text(c['autore'] ?? 'social_comments_default_user'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: PetStyle.primary)),
                          ),
                          const Spacer(),
                          StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('post')
                                .doc(widget.postId)
                                .collection('commenti')
                                .doc(commentId)
                                .collection('likes')
                                .doc(widget.currentUserId)
                                .snapshots(),
                            builder: (context, likeSnap) {
                              final hasLiked = likeSnap.data?.exists ?? false;
                              return IconButton(
                                icon: Icon(hasLiked ? Icons.favorite : Icons.favorite_border, size: 16, color: hasLiked ? Colors.pink : Colors.grey),
                                onPressed: () => _toggleCommentLike(commentId, c['uid']),
                              );
                            },
                          )
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c['testo'] ?? '', style: const TextStyle(color: Colors.black87, fontSize: 14)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('post')
                                    .doc(widget.postId)
                                    .collection('commenti')
                                    .doc(commentId)
                                    .collection('likes')
                                    .snapshots(),
                                builder: (context, countSnap) => Text("${countSnap.data?.docs.length ?? 0} ${'social_comments_like_count'.tr()}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                              ),
                              const SizedBox(width: 15),
                              GestureDetector(
                                onTap: () {
                                  _commentController.text = "@${c['autore']} ";
                                  _commentController.selection = TextSelection.fromPosition(TextPosition(offset: _commentController.text.length));
                                  _commentFocusNode.requestFocus();
                                },
                                child: Text("social_comments_reply".tr(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(15, 10, 15, 10 + MediaQuery.of(context).viewInsets.bottom),
            decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade200))),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    focusNode: _commentFocusNode,
                    decoration: InputDecoration(hintText: "social_comments_input_hint".tr(args: [widget.userData['username'] ?? 'social_comments_default_user'.tr()]), border: InputBorder.none),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: PetStyle.primary),
                  onPressed: () async {
                    if (_commentController.text.trim().isEmpty) return;
                    final text = _commentController.text.trim();
                    _commentController.clear();
                    
                    await FirebaseFirestore.instance.collection('post').doc(widget.postId).collection('commenti').add({
                      'uid': widget.currentUserId,
                      'autore': widget.userData['username'] ?? 'social_comments_default_user'.tr(),
                      'fotoProfilo': widget.userData['fotoUrl'],
                      'testo': text,
                      'timestamp': FieldValue.serverTimestamp(),
                    });

                    if (widget.postOwnerId != widget.currentUserId) {
                      SocialNotificationService().sendNotification(
                        toUserId: widget.postOwnerId,
                        type: 'comment',
                        text: 'social_comments_notif_comment'.tr(args: [text]),
                        postId: widget.postId,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
