import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petping/b_homes/b_user/social_profilo_utente_screen.dart';
import 'package:petping/b_homes/follow/user_follow_service.dart';
import 'package:easy_localization/easy_localization.dart';

class FollowShowScreen extends StatelessWidget {
  final String userId;
  final String currentUserId;
  final bool showFollowers;

  const FollowShowScreen({
    super.key,
    required this.userId,
    required this.currentUserId,
    required this.showFollowers,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryAzure = Colors.lightBlue[400]!;

    return DefaultTabController(
      length: 2,
      initialIndex: showFollowers ? 0 : 1,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text('follow_community_title'.tr(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1)),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1E293B),
          elevation: 0,
          bottom: TabBar(
            indicatorColor: primaryAzure,
            indicatorWeight: 3,
            labelColor: primaryAzure,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
            tabs: [
              Tab(text: 'follow_btn'.tr()),
              Tab(text: 'following_btn'.tr()),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildList(context, 'followers', false),
            _buildList(context, 'following', true),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, String field, bool isFollowingList) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('utenti').doc(userId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        if (!snapshot.data!.exists) return Center(child: Text('profile_not_found'.tr()));

        final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        final List ids = data[field] ?? [];

        if (ids.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline_rounded, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 15),
                Text('follow_empty_list'.tr(), style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold)),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 15),
          itemCount: ids.length,
          separatorBuilder: (context, index) => const Divider(height: 1, indent: 80, color: Color(0xFFF1F5F9)),
          itemBuilder: (context, index) {
            return _UserTile(
              userId: ids[index], 
              currentUserId: currentUserId, 
              isMyProfile: userId == currentUserId,
              isFollowingList: isFollowingList,
            );
          },
        );
      },
    );
  }
}

class _UserTile extends StatelessWidget {
  final String userId;
  final String currentUserId;
  final bool isMyProfile;
  final bool isFollowingList;

  const _UserTile({
    required this.userId, 
    required this.currentUserId, 
    required this.isMyProfile,
    required this.isFollowingList,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('utenti').doc(userId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox(height: 70);
        if (!snapshot.data!.exists) return const SizedBox.shrink();
        
        final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        final username = data['username'] ?? 'label_none'.tr();
        final photoUrl = data['fotoUrl'];

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            leading: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.lightBlue.withOpacity(0.2))),
              child: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.grey[100],
                backgroundImage: (photoUrl != null && photoUrl != '') ? NetworkImage(photoUrl) : null,
                child: (photoUrl == null || photoUrl == '') ? const Icon(Icons.person, color: Colors.grey) : null,
              ),
            ),
            title: Text(
              '@$username'.toUpperCase(), 
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF1E293B))
            ),
            subtitle: Text('follow_view_profile'.tr(), style: const TextStyle(fontSize: 11, color: Colors.grey)),
            trailing: (isMyProfile && isFollowingList) 
              ? IconButton(
                  icon: const Icon(Icons.person_remove_rounded, color: Colors.redAccent, size: 22),
                  onPressed: () => _confirmUnfollow(context, username),
                  tooltip: 'unfollow_btn'.tr(),
                )
              : const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SocialProfiloUtenteScreen(userId: userId),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _confirmUnfollow(BuildContext context, String username) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Text('unfollow_dialog_title'.tr(), style: const TextStyle(fontWeight: FontWeight.w900)),
        content: Text('unfollow_confirm_msg'.tr(args: [username])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('btn_cancel'.tr().toUpperCase(), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
          TextButton(
            onPressed: () async {
              await UserFollowService().smettiDiSeguire(currentUserId, userId);
              if (context.mounted) Navigator.pop(ctx);
            }, 
            child: Text('profile_btn_confirm'.tr(), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900))
          ),
        ],
      ),
    );
  }
}
