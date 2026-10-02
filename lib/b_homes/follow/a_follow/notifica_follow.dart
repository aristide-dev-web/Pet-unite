import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petping/b_homes/b_user/social_profilo_utente_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class NotificaFollow extends StatelessWidget {
  final String currentUserId;

  const NotificaFollow({super.key, required this.currentUserId});

  Stream<QuerySnapshot> _getFollowNotifications() {
    return FirebaseFirestore.instance
        .collection('notifications')
        .doc(currentUserId)
        .collection('items')
        .where('type', isEqualTo: 'follow')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<DocumentSnapshot> _getUser(String userId) {
    return FirebaseFirestore.instance.collection('utenti').doc(userId).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('notif_follow_title'.tr())),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getFollowNotifications(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final notifiche = snapshot.data!.docs;

          if (notifiche.isEmpty) return Center(child: Text('notif_follow_empty'.tr()));

          return ListView.builder(
            itemCount: notifiche.length,
            itemBuilder: (context, index) {
              final notifica = notifiche[index];
              final fromUserId = notifica['fromUserId'];

              return FutureBuilder<DocumentSnapshot>(
                future: _getUser(fromUserId),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) return ListTile(title: Text('label_loading'.tr()));

                  final user = userSnapshot.data!;
                  final username = user['username'] ?? 'label_none'.tr();
                  final photoUrl = user['fotoUrl'];

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: (photoUrl != null && photoUrl.isNotEmpty) ? NetworkImage(photoUrl) : null,
                      child: (photoUrl == null || photoUrl.isEmpty) ? const Icon(Icons.person) : null,
                    ),
                    title: Text('notif_follow_msg'.tr(args: [username])),
                    subtitle: Text('notif_follow_sub'.tr()),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SocialProfiloUtenteScreen(
                            userId: fromUserId,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
