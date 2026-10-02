import 'dart:io';
import 'package:flutter/material.dart';
import 'package:petping/b_homes/b_registrazioneutente/profile_bios.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:petping/tipologie/bandiere.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petping/social/social_memoria_firebase.dart';
import 'package:petping/social/social_stories_bar.dart'; 
import 'package:petping/social/story/social_story_editor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:petping/social/post/social_post_model.dart';
import 'package:petping/social/story/social_story_model.dart';
import 'package:petping/d_tab_sds/services/sds_cache_service.dart';
import 'package:petping/petsitting/screens/profile/sitter_profile_shortcut.dart';
import 'package:petping/b_homes/follow/a_follow/follow_show.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petping/social/social_modifica_profilo_screen.dart';
import 'package:petping/style/pet_style.dart';
import 'package:petping/b_homes/follow/user_follow_service.dart';
import 'package:petping/b_homes/d_message/chat_screen.dart';
import 'package:petping/b_homes/d_message/message_service.dart';
import 'package:petping/b_homes/b_user/blockuser/block_user_service.dart';
import 'package:petping/b_homes/b_user/segnala/segnala_utente.dart';
import 'package:petping/utils/ban_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:petping/models/user_profile_model.dart';

class SocialProfiloUtenteScreen extends StatefulWidget {
  final String userId;
  final String? nomeAutore;

  const SocialProfiloUtenteScreen({
    super.key, 
    required this.userId, 
    this.nomeAutore,
  });

  @override
  State<SocialProfiloUtenteScreen> createState() => _SocialProfiloUtenteScreenState();
}

class _SocialProfiloUtenteScreenState extends State<SocialProfiloUtenteScreen> {
  final Color mainColor = const Color(0xFF64B5B4);
  final Color lightBg = const Color(0xFFF2F5F8);
  final Color cardColor = Colors.white;
  final Color textColor = const Color(0xFF1A1A1A);
  final _followService = UserFollowService();

  String _calculateAge(String? birthDateString) {
    if (birthDateString == null || birthDateString.isEmpty) return 'gender_not_specified'.tr();
    try {
      DateTime birthDate = DateFormat('dd/MM/yyyy').parse(birthDateString);
      DateTime today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return age.toString();
    } catch (e) {
      return 'gender_not_specified'.tr();
    }
  }

  String _getFlag(String? countryName) {
    if (countryName == null || countryName.isEmpty) return "";
    String key = countryName.toLowerCase().trim();
    return countryFlags[key] ?? "";
  }

  Future<void> _launch(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      debugPrint('Could not launch $url');
    }
  }

  void _confirmBlockUser(String currentUserId, String otherUserId, String username) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('profile_block_confirm_title'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text('profile_block_confirm_msg'.tr(args: [username])),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), 
            child: Text("btn_cancel".tr(), style: const TextStyle(color: Colors.grey))
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: Text("settings_label_blocked_users".tr(), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );

    if (confirm == true) {
      await BlockUserService.blockUser(blockerId: currentUserId, blockedId: otherUserId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("profile_block_success".tr()),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          )
        );
        Navigator.pop(context); 
      }
    }
  }

  void _confirmBanUser(String username, String uid) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('admin_ban_confirm_title'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        content: Text('admin_ban_confirm_msg'.tr(args: [username])),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), 
            child: Text("btn_cancel".tr(), style: const TextStyle(color: Colors.grey))
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text("BAN", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await BanService.banUser(uid);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("admin_ban_success".tr()),
              backgroundColor: Colors.black,
              behavior: SnackBarBehavior.floating,
            )
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red)
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final bool isMe = currentUserId == widget.userId;

    return Scaffold(
      backgroundColor: lightBg,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('utenti').doc(widget.userId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("profile_not_found".tr()));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHelloTalkHeader(userData, isMe, currentUserId),
                _buildUserInfoSection(userData, isMe),
                _buildMomentsCollection(),
                const SizedBox(height: 10),
                _buildSocialContent(userData),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHelloTalkHeader(Map<String, dynamic> userData, bool isMe, String currentUserId) {
    final Map<String, dynamic> vis = userData['visibilita'] ?? {};
    String? photoUrl = userData['fotoUrl'];
    String? coverUrl = userData['coverUrl'];
    String username = userData['username'] ?? 'label_user'.tr();
    bool showNome = vis['nome'] ?? true;
    bool showCognome = vis['cognome'] ?? true;
    String nome = showNome ? (userData['nome'] ?? '') : '';
    String cognome = showCognome ? (userData['cognome'] ?? '') : '';
    String fullName = '$nome $cognome'.trim();
    int following = (userData['following'] as List?)?.length ?? 0;
    int followers = (userData['followers'] as List?)?.length ?? 0;
    
    final List followersList = userData['followers'] ?? [];
    final bool isFollowing = followersList.contains(currentUserId);

    // Controllo se l'utente corrente è un admin globale
    final currentUserProfile = Hive.box<UserProfile>('user_profile_box').get(currentUserId);
    final bool isGlobalAdmin = currentUserProfile?.isAdmin ?? false;

    return Container(
      height: 500, 
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 320,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: (coverUrl != null && coverUrl.isNotEmpty) 
                    ? NetworkImage(coverUrl) as ImageProvider
                    : const AssetImage('assets/sfondi/temini e privacy.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: Icon(Icons.arrow_back_ios_new_rounded, color: mainColor, size: 20),
              ),
            ),
          ),
          
          if (!isMe)
            Positioned(
              top: 50,
              right: 20,
              child: Row(
                children: [
                  if (isGlobalAdmin) ...[
                    GestureDetector(
                      onTap: () => _confirmBanUser(username, widget.userId),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                        ),
                        child: const Icon(Icons.gavel_rounded, color: Colors.white, size: 22),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SegnalaUtenteScreen(
                          reportedUserId: widget.userId,
                          reportedUsername: username,
                        ),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                      ),
                      child: const Icon(Icons.report_problem_rounded, color: Colors.orangeAccent, size: 22),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _confirmBlockUser(currentUserId, widget.userId, username),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                      ),
                      child: const Icon(Icons.block_flipped, color: Colors.redAccent, size: 22),
                    ),
                  ),
                ],
              ),
            ),

          Positioned(
            top: 250,
            left: 20,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white, 
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: mainColor.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))
                    ]
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    backgroundImage: (photoUrl != null && photoUrl.isNotEmpty) ? NetworkImage(photoUrl) : null,
                    child: (photoUrl == null || photoUrl.isEmpty) ? Icon(Icons.person, color: mainColor, size: 45) : null,
                  ),
                ),
                if (isMe)
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SocialModificaProfiloScreen())),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [mainColor, mainColor.withOpacity(0.8)]),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
                      ),
                      child: const Icon(Icons.edit_rounded, size: 16, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            top: 325,
            left: 140,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  username.toUpperCase(),
                  style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                  overflow: TextOverflow.ellipsis,
                ),
                if (fullName.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    fullName, 
                    style: TextStyle(color: Colors.grey[600], fontSize: 15, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          
          Positioned(
            top: 400,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _statCount('$following', 'following_btn'.tr(), false),
                    const SizedBox(width: 15),
                    _statCount('$followers', 'follow_btn'.tr(), true),
                  ],
                ),
                if (!isMe) ...[
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          if (isFollowing) {
                            await _followService.smettiDiSeguire(currentUserId, widget.userId);
                          } else {
                            await _followService.segui(currentUserId, widget.userId);
                          }
                        },
                        child: Container(
                          height: 38,
                          padding: const EdgeInsets.symmetric(horizontal: 35),
                          decoration: BoxDecoration(
                            color: isFollowing ? Colors.grey[200] : mainColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              isFollowing ? 'following_btn'.tr().toUpperCase() : 'follow_btn'.tr().toUpperCase(),
                              style: TextStyle(
                                color: isFollowing ? Colors.black87 : Colors.white, 
                                fontWeight: FontWeight.w900, 
                                fontSize: 11,
                                letterSpacing: 1
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(
                          currentUserId: currentUserId,
                          otherUserId: widget.userId,
                          otherUsername: username,
                          messageService: MessageService(),
                        ))),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 4))
                            ],
                            border: Border.all(color: mainColor.withOpacity(0.3), width: 1.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.chat_bubble_outline_rounded, color: mainColor, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'btn_chat'.tr().toUpperCase(),
                                style: TextStyle(color: mainColor, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoSection(Map<String, dynamic> userData, bool isMe) {
    final Map<String, dynamic> vis = userData['visibilita'] ?? {};
    List telefoni = (vis['telefoni'] ?? true) ? (userData['telefoni'] as List? ?? []) : [];
    List emails = (vis['emails'] ?? true) ? (userData['emails'] as List? ?? []) : [];
    List whatsapp = (vis['whatsapp'] ?? true) ? (userData['whatsapp'] as List? ?? []) : [];
    String sex = userData['sesso'] ?? 'gender_not_specified'.tr();
    String age = _calculateAge(userData['dataNascita']);
    String flag = (vis['nazione'] ?? true) ? _getFlag(userData['nazione']) : "";
    List<String> locParts = [];
    if ((vis['indirizzo'] ?? true) && userData['indirizzo'] != null && userData['indirizzo'].toString().isNotEmpty) locParts.add(userData['indirizzo']);
    if ((vis['citta'] ?? true) && userData['citta'] != null && userData['citta'].toString().isNotEmpty) locParts.add(userData['citta']);
    if ((vis['regione'] ?? true) && userData['regione'] != null && userData['regione'].toString().isNotEmpty) locParts.add(userData['regione']);
    String fullLoc = locParts.join(', ');
    if (fullLoc.isEmpty) {
        fullLoc = ((vis['nazione'] ?? true) && (userData['nazione'] ?? "").isNotEmpty) ? (userData['nazione'] ?? "") : '';
    }
    if (flag.isNotEmpty && fullLoc.isNotEmpty) fullLoc += " $flag";
    else if (flag.isNotEmpty) fullLoc = flag;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: mainColor.withOpacity(0.15), width: 3),
              boxShadow: [
                BoxShadow(color: mainColor.withOpacity(0.08), blurRadius: 25, offset: const Offset(0, 10)),
              ],
            ),
            child: Column(
              children: [
                if (fullLoc.isNotEmpty)
                  _infoIconRow(icon: Icons.location_on_rounded, text: fullLoc, color: mainColor),
                if (telefoni.isNotEmpty) ...[
                  if (fullLoc.isNotEmpty) const SizedBox(height: 15),
                  _infoIconRow(icon: Icons.phone_android_rounded, text: telefoni.first.toString(), color: Colors.blueAccent, onTap: () => _launch('tel:${telefoni.first}')),
                ],
                if (whatsapp.isNotEmpty) ...[
                  const SizedBox(height: 15),
                  _infoIconRow(icon: Icons.chat_bubble_rounded, text: "WhatsApp: ${whatsapp.first}", color: const Color(0xFF25D366), onTap: () => _launch('https://wa.me/${whatsapp.first.toString().replaceAll('+', '').replaceAll(' ', '')}')),
                ],
                if (emails.isNotEmpty) ...[
                  const SizedBox(height: 15),
                  _infoIconRow(icon: Icons.alternate_email_rounded, text: emails.first.toString(), color: Colors.orangeAccent, onTap: () => _launch('mailto:${emails.first}')),
                ],
                if ((vis['dataNascita'] ?? true) || (vis['sesso'] ?? true)) ...[
                  Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: Divider(color: mainColor.withOpacity(0.1), height: 1)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (vis['dataNascita'] ?? true) _smallInfoTile('profile_age_label'.tr(), age),
                      if (vis['sesso'] ?? true) _smallInfoTile('profile_sex_label'.tr(), sex),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 25),
          
          if ((vis['bio'] ?? true) && (userData['bio'] ?? '').isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 15),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(25, 50, 25, 30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(35),
                      border: Border.all(color: mainColor.withOpacity(0.2), width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: mainColor.withOpacity(0.12),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Transform.translate(
                          offset: const Offset(0, -10),
                          child: Icon(Icons.format_quote_rounded, color: mainColor.withOpacity(0.15), size: 45),
                        ),
                        Text(
                          userData['bio'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: textColor.withOpacity(0.85),
                            fontSize: 15,
                            height: 1.8,
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.italic,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: -15,
                    left: 30,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [mainColor, mainColor.withOpacity(0.85)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: mainColor.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 5))
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            "profile_story_label".tr().toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white, 
                              fontSize: 11, 
                              fontWeight: FontWeight.w900, 
                              letterSpacing: 2.0
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMomentsCollection() {
    return ValueListenableBuilder(
      valueListenable: Hive.box<SocialStory>(SDSCacheService.storiesBoxName).listenable(),
      builder: (context, Box<SocialStory> box, _) {
        final profileStories = box.values.where((s) => s.uid == widget.userId).toList();
        if (profileStories.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
              child: Row(
                children: [
                  Container(width: 4, height: 18, decoration: BoxDecoration(color: mainColor, borderRadius: BorderRadius.circular(10))),
                  const SizedBox(width: 10),
                  Text("profile_moments_label".tr().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5, color: Color(0xFF1E293B))),
                ],
              ),
            ),
            SizedBox(
              height: 115,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: profileStories.length,
                itemBuilder: (context, index) {
                  final story = profileStories[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SocialStoryViewer(
                            groupedStories: {widget.userId: profileStories},
                            initialUserIndex: 0,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 85,
                      margin: const EdgeInsets.only(right: 15),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(colors: [mainColor, Colors.orangeAccent]),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: CircleAvatar(
                                radius: 35,
                                backgroundColor: Colors.grey[100],
                                backgroundImage: NetworkImage(story.immagineUrl),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(DateFormat('dd MMM').format(story.timestamp ?? DateTime.now()), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSocialContent(Map<String, dynamic> userData) {
    return Column(
      children: [
        const SizedBox(height: 15),
        ValueListenableBuilder(
          valueListenable: Hive.box<SocialPost>(SDSCacheService.postsBoxName).listenable(),
          builder: (context, Box<SocialPost> box, _) {
            final profilePosts = box.values.where((p) => p.uid == widget.userId && p.categoria == 'generale').toList();
            profilePosts.sort((a, b) => (b.timestamp ?? DateTime(2000)).compareTo(a.timestamp ?? DateTime(2000)));

            if (profilePosts.isEmpty) {
              return Padding(
                padding: const EdgeInsets.only(top: 40, bottom: 40),
                child: Center(child: Text("profile_no_posts".tr(), style: const TextStyle(color: Colors.grey))),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: profilePosts.length,
              itemBuilder: (context, index) {
                final post = profilePosts[index];
                return _buildRealPostCard(post.toMap());
              },
            );
          },
        ),
      ],
    );
  }

  Widget _statCount(String count, String label, bool isFollowers) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FollowShowScreen(
              userId: widget.userId,
              currentUserId: FirebaseAuth.instance.currentUser?.uid ?? '',
              showFollowers: isFollowers,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: mainColor.withOpacity(0.1)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(count, style: TextStyle(color: mainColor, fontWeight: FontWeight.w900, fontSize: 15)),
            const SizedBox(width: 6),
            Text(label.toUpperCase(), style: TextStyle(color: Colors.grey[500], fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }

  Widget _infoIconRow({required IconData icon, required String text, required Color color, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text, 
              style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onTap != null)
            Icon(Icons.open_in_new_rounded, size: 12, color: textColor.withOpacity(0.3)),
        ],
      ),
    );
  }

  Widget _smallInfoTile(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildRealPostCard(Map<String, dynamic> post) {
    final String autore = post['autore'] ?? 'label_none'.tr();
    final String testo = post['testo'] ?? '';
    final String? immagineUrl = post['immagineUrl'];
    final String? fotoProfilo = post['fotoProfilo'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20, 
                backgroundImage: (fotoProfilo != null && fotoProfilo.isNotEmpty) ? NetworkImage(fotoProfilo) : null,
                child: (fotoProfilo == null) ? const Icon(Icons.person, size: 20) : null,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(autore, style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 15)),
                    Text("profile_social_post_tag".tr(), style: TextStyle(color: Colors.grey[400], fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          if (testo.isNotEmpty) ...[
            const SizedBox(height: 15),
            Text(testo, style: TextStyle(color: textColor.withOpacity(0.85), height: 1.5, fontSize: 14, fontWeight: FontWeight.w500)),
          ],
          if (immagineUrl != null && immagineUrl.isNotEmpty) ...[
            const SizedBox(height: 15),
            ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image.network(immagineUrl, fit: BoxFit.cover),
            ),
          ],
        ],
      ),
    );
  }
}
