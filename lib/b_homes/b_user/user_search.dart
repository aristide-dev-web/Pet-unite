import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petping/b_homes/b_user/social_profilo_utente_screen.dart'; // Importato il profilo social
import 'package:petping/b_homes/follow/user_follow_service.dart';
import 'package:petping/b_homes/b_user/blockuser/block_user_service.dart';
import 'package:easy_localization/easy_localization.dart';

class UserSearch extends StatefulWidget {
  final String currentUserId;

  const UserSearch({super.key, required this.currentUserId});

  @override
  State<UserSearch> createState() => _UserSearchState();
}

class _UserSearchState extends State<UserSearch> {
  String searchQuery = '';
  final UserFollowService _followService = UserFollowService();
  List<String> blockedIds = [];

  @override
  void initState() {
    super.initState();
    _loadBlockedUsers();
  }

  Future<void> _loadBlockedUsers() async {
    final meToThem = await BlockUserService.getBlockedUserIds(widget.currentUserId);
    final themToMe = await BlockUserService.getUsersWhoBlockedMe(widget.currentUserId);
    if (mounted) {
      setState(() {
        blockedIds = {...meToThem, ...themToMe}.toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryAzure = Colors.lightBlue[400]!;
    final utentiRef = FirebaseFirestore.instance.collection('utenti');

    return Scaffold(
      appBar: AppBar(
        title: Text('search_friends_title'.tr()),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'search_nickname_hint'.tr(),
                prefixIcon: Icon(Icons.search, color: primaryAzure),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.trim();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: searchQuery.isEmpty
                  ? null
                  : utentiRef
                        .where('username_search', isGreaterThanOrEqualTo: searchQuery.toLowerCase())
                        .where('username_search', isLessThan: '${searchQuery.toLowerCase()}\uf8ff')
                        .snapshots(),
              builder: (context, snapshot) {
                if (searchQuery.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_search, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('search_community_empty'.tr(), style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final utenti = snapshot.data!.docs
                    .where((doc) => doc.id != widget.currentUserId && !blockedIds.contains(doc.id))
                    .toList();

                if (utenti.isEmpty) {
                  return Center(child: Text('search_no_results'.tr()));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: utenti.length,
                  itemBuilder: (context, index) {
                    final userDoc = utenti[index];
                    final userData = userDoc.data() as Map<String, dynamic>;
                    final username = userData['username'] ?? 'label_user_simple'.tr();
                    final userId = userDoc.id;
                    final photoUrl = userData['fotoUrl'];
                    
                    final List following = userData['followers'] ?? [];
                    final bool isAlreadyFollowing = following.contains(widget.currentUserId);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 0,
                      color: Colors.grey[50],
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10),
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: (photoUrl != null && photoUrl != '') ? NetworkImage(photoUrl) : null,
                          child: (photoUrl == null || photoUrl == '') ? const Icon(Icons.person) : null,
                        ),
                        title: Text('$username', style: const TextStyle(fontWeight: FontWeight.bold)),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SocialProfiloUtenteScreen(
                                userId: userId,
                              ),
                            ),
                          ).then((_) => _loadBlockedUsers()); // Ricarica in caso di blocco dal profilo
                        },
                        trailing: ElevatedButton(
                          onPressed: () async {
                            if (isAlreadyFollowing) {
                              await _followService.smettiDiSeguire(widget.currentUserId, userId);
                            } else {
                              await _followService.segui(widget.currentUserId, userId);
                            }
                            setState(() {});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isAlreadyFollowing ? Colors.grey[300] : primaryAzure,
                            foregroundColor: isAlreadyFollowing ? Colors.black87 : Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: Text(isAlreadyFollowing ? 'following_btn'.tr() : 'follow_btn'.tr(), style: const TextStyle(fontSize: 12)),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
