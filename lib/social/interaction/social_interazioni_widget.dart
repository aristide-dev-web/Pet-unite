import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petping/social/social_interazioni_firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';


class CommentSectionWidget extends StatefulWidget {
  final String postId;
  final SocialInterazioniFirebase service;

  const CommentSectionWidget({
    super.key,
    required this.postId,
    required this.service,
  });

  @override
  State<CommentSectionWidget> createState() => _CommentSectionWidgetState();
}

class _CommentSectionWidgetState extends State<CommentSectionWidget> {
  final TextEditingController _controller = TextEditingController();

  void _inviaCommento() async {
    final user = FirebaseAuth.instance.currentUser;
    final testo = _controller.text.trim();

    if (user != null && testo.isNotEmpty) {
      await widget.service.aggiungiCommento(
        widget.postId,
        user.uid,
        user.displayName ?? 'label_none'.tr(),
        testo,
      );
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: widget.service.leggiCommenti(widget.postId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox();

            final commenti = snapshot.data!.docs;

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: commenti.length,
              itemBuilder: (context, index) {
                final commento = commenti[index];
                return ListTile(
                  title: Text(commento['autore'] ?? 'label_none'.tr()),
                  subtitle: Text(commento['testo'] ?? ''),
                );
              },
            );
          },
        ),
        const Divider(),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(hintText: 'social_comment_hint'.tr()),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _inviaCommento,
            ),
          ],
        ),
      ],
    );
  }
}

class LikeButtonWidget extends StatelessWidget {
  final String postId;
  final SocialInterazioniFirebase service;

  const LikeButtonWidget({
    super.key,
    required this.postId,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return const SizedBox();

    return StreamBuilder<int>(
      stream: service.contaLike(postId),
      builder: (context, snapshot) {
        final likeCount = snapshot.data ?? 0;

        return IconButton(
          icon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.thumb_up_alt_outlined),
              const SizedBox(width: 4),
              Text('$likeCount'),
            ],
          ),
          onPressed: () => service.aggiungiLike(postId, user.uid),
        );
      },
    );
  }
}