import 'dart:io';
import 'package:flutter/material.dart';
import 'package:petping/b_homes/b_registrazioneutente/profile_bios.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:petping/tipologie/bandiere.dart';
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
import 'package:petping/social/post/social_edit_post_modal.dart';
import 'package:petping/social/social_comments_sheet.dart';
import 'package:petping/utils/notific_principal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';

class FrontSocialScreen extends StatefulWidget {
  final String currentUserId;
  final Map<String, dynamic> userData;
  final VoidCallback onSwitchBack;
  final VoidCallback onUpdateCover;

  const FrontSocialScreen({
    super.key, 
    required this.currentUserId, 
    required this.userData,
    required this.onSwitchBack,
    required this.onUpdateCover,
  });

  @override
  State<FrontSocialScreen> createState() => _FrontSocialScreenState();
}

class _FrontSocialScreenState extends State<FrontSocialScreen> {
  final Color mainColor = const Color(0xFF64B5B4);
  final Color lightBg = const Color(0xFFFFFFFF); 
  final Color cardColor = Colors.white;
  final Color textColor = const Color(0xFF1A1A1A);
  final _socialService = SocialMemoriaFirebase();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _launch(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      debugPrint('Could not launch $url');
    }
  }

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

  Future<void> _pickAndUploadStory() async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('social_moments_add_title'.tr(), style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.blueGrey, letterSpacing: 1.2)),
            const SizedBox(height: 20),
            ListTile(
              leading: CircleAvatar(backgroundColor: mainColor.withOpacity(0.1), child: Icon(Icons.camera_alt_rounded, color: mainColor)),
              title: Text('social_moments_camera'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: CircleAvatar(backgroundColor: mainColor.withOpacity(0.1), child: Icon(Icons.photo_library_rounded, color: mainColor)),
              title: Text('social_moments_gallery'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );

    if (source != null) {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source, imageQuality: 70);
      
      if (image != null) {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SocialStoryEditor(imageFile: File(image.path))),
        );

        if (result != null && result is Map) {
          try {
            await _socialService.creaStoria(
              uid: widget.currentUserId,
              autore: widget.userData['username'] ?? 'label_user'.tr(),
              fotoProfilo: widget.userData['fotoUrl'],
              immagineFile: result['image'],
            );
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('snack_story_published'.tr()))
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('snack_error_msg'.tr(args: [e.toString()]))),
              );
            }
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              const Color(0xFFF5FFFF), 
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHelloTalkHeader(),
              _buildUserInfoSection(),
              _buildMomentsCollection(),
              const SizedBox(height: 10),
              _buildSocialContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelloTalkHeader() {
    final Map<String, dynamic> vis = widget.userData['visibilita'] ?? {};
    String? photoUrl = widget.userData['fotoUrl'];
    String? coverUrl = widget.userData['coverUrl'];
    String username = widget.userData['username'] ?? 'label_user'.tr();
    bool showNome = vis['nome'] ?? true;
    bool showCognome = vis['cognome'] ?? true;
    String nome = showNome ? (widget.userData['nome'] ?? '') : '';
    String cognome = showCognome ? (widget.userData['cognome'] ?? '') : '';
    String fullName = '$nome $cognome'.trim();
    int following = (widget.userData['following'] as List?)?.length ?? 0;
    int followers = (widget.userData['followers'] as List?)?.length ?? 0;

    return Container(
      height: 440,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: widget.onUpdateCover,
            child: Container(
              height: 320,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: coverUrl != null 
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
                    colors: [
                      Colors.black.withOpacity(0.15), 
                      Colors.transparent,
                      Colors.white.withOpacity(0.2),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 260,
            right: 20,
            child: GestureDetector(
              onTap: widget.onUpdateCover,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: mainColor.withOpacity(0.5), width: 2),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 15, offset: const Offset(0, 5))
                  ],
                ),
                child: Icon(Icons.camera_alt_rounded, color: mainColor, size: 22),
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: widget.onSwitchBack,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 4))
                      ],
                      border: Border.all(color: mainColor.withOpacity(0.3), width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.home_rounded, color: mainColor, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'home'.tr().toUpperCase(),
                          style: const TextStyle(color: Color(0xFF64B5B4), fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const SitterProfileShortcut(),
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
                      BoxShadow(color: mainColor.withOpacity(0.25), blurRadius: 30, offset: const Offset(0, 10))
                    ]
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    backgroundImage: (photoUrl != null && photoUrl.isNotEmpty) ? NetworkImage(photoUrl) : null,
                    child: (photoUrl == null || photoUrl.isEmpty) ? Icon(Icons.person, color: mainColor, size: 45) : null,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
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
            top: 390,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _statCount('$following', 'following_btn'.tr(), false),
                const SizedBox(width: 15),
                _statCount('$followers', 'follow_btn'.tr(), true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoSection() {
    final Map<String, dynamic> vis = widget.userData['visibilita'] ?? {};
    List telefoni = (vis['telefoni'] ?? true) ? (widget.userData['telefoni'] as List? ?? []) : [];
    List emails = (vis['emails'] ?? true) ? (widget.userData['emails'] as List? ?? []) : [];
    List whatsapp = (vis['whatsapp'] ?? true) ? (widget.userData['whatsapp'] as List? ?? []) : [];
    String sex = widget.userData['sesso'] ?? 'gender_not_specified'.tr();
    String age = _calculateAge(widget.userData['dataNascita']);
    String flag = (vis['nazione'] ?? true) ? _getFlag(widget.userData['nazione']) : "";
    List<String> locParts = [];
    if ((vis['indirizzo'] ?? true) && widget.userData['indirizzo'] != null && widget.userData['indirizzo'].toString().isNotEmpty) locParts.add(widget.userData['indirizzo']);
    if ((vis['citta'] ?? true) && widget.userData['citta'] != null && widget.userData['citta'].toString().isNotEmpty) locParts.add(widget.userData['citta']);
    if ((vis['regione'] ?? true) && widget.userData['regione'] != null && widget.userData['regione'].toString().isNotEmpty) locParts.add(widget.userData['regione']);
    String fullLoc = locParts.join(', ');
    if (fullLoc.isEmpty) {
        fullLoc = ((vis['nazione'] ?? true) && (widget.userData['nazione'] ?? "").isNotEmpty) ? (widget.userData['nazione'] ?? "") : '';
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
              border: Border.all(color: mainColor.withOpacity(0.1), width: 3),
              boxShadow: [
                BoxShadow(color: mainColor.withOpacity(0.05), blurRadius: 30, offset: const Offset(0, 10)),
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
                  Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: Divider(color: mainColor.withOpacity(0.05), height: 1)),
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
          
          if ((vis['bio'] ?? true) && (widget.userData['bio'] ?? '').isNotEmpty)
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
                          color: mainColor.withOpacity(0.1),
                          blurRadius: 35,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Transform.translate(
                          offset: const Offset(0, -10),
                          child: Icon(Icons.format_quote_rounded, color: mainColor.withOpacity(0.12), size: 45),
                        ),
                        Text(
                          widget.userData['bio'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: textColor.withOpacity(0.8),
                            fontSize: 15,
                            height: 1.8,
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.italic,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 25),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 50,
                              height: 1.5,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [Colors.transparent, mainColor.withOpacity(0.2)]),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15),
                              child: Icon(Icons.pets_rounded, color: mainColor.withOpacity(0.3), size: 20),
                            ),
                            Container(
                              width: 50,
                              height: 1.5,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [mainColor.withOpacity(0.2), Colors.transparent]),
                              ),
                            ),
                          ],
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
                          BoxShadow(color: mainColor.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 5))
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
        final myStories = box.values.where((s) => s.uid == widget.currentUserId).toList();
        if (myStories.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
              child: Row(
                children: [
                  Container(width: 4, height: 18, decoration: BoxDecoration(color: mainColor, borderRadius: BorderRadius.circular(10))),
                  const SizedBox(width: 10),
                  Text('social_moments_my_label'.tr().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5, color: Color(0xFF1E293B))),
                ],
              ),
            ),
            SizedBox(
              height: 115,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: myStories.length,
                itemBuilder: (context, index) {
                  final story = myStories[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SocialStoryViewer(
                            groupedStories: {widget.currentUserId: myStories},
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
                              gradient: LinearGradient(colors: [mainColor, Colors.orangeAccent, Colors.purpleAccent.withOpacity(0.5)]),
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
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }

  Widget _buildSocialContent() {
    return Column(
      children: [
        ValueListenableBuilder(
          valueListenable: Hive.box<SocialStory>(SDSCacheService.storiesBoxName).listenable(),
          builder: (context, Box<SocialStory> box, _) {
            return SocialStoriesBar(
              mainColor: mainColor,
              userPhotoUrl: widget.userData['fotoUrl'],
              onAddStory: _pickAndUploadStory,
              stories: const [],
            );
          },
        ),
        const SizedBox(height: 15),
        ValueListenableBuilder(
          valueListenable: Hive.box<SocialPost>(SDSCacheService.postsBoxName).listenable(),
          builder: (context, Box<SocialPost> box, _) {
            final myPosts = box.values.where((p) => p.uid == widget.currentUserId && p.categoria == 'generale').toList();
            myPosts.sort((a, b) => (b.timestamp ?? DateTime(2000)).compareTo(a.timestamp ?? DateTime(2000)));

            if (myPosts.isEmpty) {
              return Padding(
                padding: const EdgeInsets.only(top: 40, bottom: 40),
                child: Center(child: Text('profile_no_posts'.tr(), style: const TextStyle(color: Colors.grey))),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: myPosts.length,
              itemBuilder: (context, index) {
                final post = myPosts[index];
                return _buildRealPostCard(post);
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
              userId: widget.currentUserId,
              currentUserId: widget.currentUserId,
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

  Widget _buildRealPostCard(SocialPost post) {
    final String postId = post.id;
    final String autore = post.autore;
    final String testo = post.testo;
    final String? immagineUrl = post.immagineUrl;
    final String? fotoProfilo = post.fotoProfilo;
    final String postOwnerId = post.uid;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: mainColor.withOpacity(0.15), width: 2),
        boxShadow: [
          BoxShadow(
            color: mainColor.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [mainColor, mainColor.withOpacity(0.4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: CircleAvatar(
                  radius: 20, 
                  backgroundColor: Colors.white,
                  backgroundImage: (fotoProfilo != null && fotoProfilo.isNotEmpty) ? NetworkImage(fotoProfilo) : null,
                  child: (fotoProfilo == null) ? Icon(Icons.person, size: 20, color: mainColor) : null,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      autore, 
                      style: TextStyle(color: mainColor, fontWeight: FontWeight.w900, fontSize: 15),
                    ),
                    Text(
                      'social_post_published_now'.tr(), 
                      style: TextStyle(color: Colors.grey[400], fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showPostOptions(post), 
                icon: Icon(Icons.more_vert_rounded, color: mainColor.withOpacity(0.4)),
              ),
            ],
          ),
          if (testo.isNotEmpty) ...[
            const SizedBox(height: 15),
            Text(
              testo, 
              style: TextStyle(color: textColor.withOpacity(0.8), height: 1.5, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
          if (immagineUrl != null && immagineUrl.isNotEmpty) ...[
            const SizedBox(height: 15),
            ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image.network(
                immagineUrl, 
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 200,
                    color: mainColor.withOpacity(0.05),
                    child: Center(child: CircularProgressIndicator(color: mainColor, strokeWidth: 2)),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('post').doc(postId).collection('likes').snapshots(),
                builder: (context, snapshot) {
                  final count = snapshot.data?.docs.length ?? 0;
                  return _buildPostAction(Icons.favorite_rounded, '$count', Colors.redAccent);
                }
              ),
              const SizedBox(width: 20),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('post').doc(postId).collection('commenti').snapshots(),
                builder: (context, snapshot) {
                  final count = snapshot.data?.docs.length ?? 0;
                  return _buildPostAction(Icons.chat_bubble_rounded, '$count', mainColor);
                }
              ),
              const Spacer(),
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('post').doc(postId).collection('likes').doc(widget.currentUserId).snapshots(),
                builder: (context, snapshot) {
                  final hasLiked = snapshot.data?.exists ?? false;
                  return IconButton(
                    onPressed: () => _toggleLike(postId, postOwnerId),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      hasLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: hasLiked ? Colors.redAccent : mainColor.withOpacity(0.3),
                      size: 24,
                    ),
                  );
                }
              ),
              const SizedBox(width: 15),
              IconButton(
                onPressed: () => _showCommentsModal(postId, postOwnerId),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(Icons.chat_bubble_outline_rounded, color: mainColor.withOpacity(0.3), size: 22),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPostOptions(SocialPost post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: Colors.blue),
              title: Text('btn_edit_post'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
              onTap: () async {
                Navigator.pop(context);
                await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => SocialEditPostModal(post: post, userData: widget.userData),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: Text('btn_delete_post'.tr(), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                _confirmDeletePost(post);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _confirmDeletePost(SocialPost post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Text('dialog_delete_post_title'.tr(), style: const TextStyle(fontWeight: FontWeight.w900)),
        content: Text('dialog_delete_post_msg'.tr()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('btn_cancel'.tr().toUpperCase())),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _socialService.eliminaPost(post.id, post.immagineUrl);
            },
            child: Text('btn_confirm_delete_upper'.tr(), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleLike(String postId, String postOwnerId) async {
    final likeRef = FirebaseFirestore.instance.collection('post').doc(postId).collection('likes').doc(widget.currentUserId);
    final doc = await likeRef.get();

    if (doc.exists) {
      await likeRef.delete();
    } else {
      await likeRef.set({'timestamp': FieldValue.serverTimestamp()});
      if (postOwnerId != widget.currentUserId) {
        SocialNotificationService().sendNotification(
          toUserId: postOwnerId,
          type: 'like',
          text: 'ha messo mi piace al tuo post',
          postId: postId,
        );
      }
    }
  }

  void _showCommentsModal(String postId, String postOwnerId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SocialCommentsSheet(
        postId: postId,
        postOwnerId: postOwnerId,
        currentUserId: widget.currentUserId,
        userData: widget.userData,
      ),
    );
  }

  Widget _buildPostAction(IconData icon, String count, Color color) {
    return Row(
      children: [
        Icon(icon, color: color.withOpacity(0.7), size: 20),
        const SizedBox(width: 6),
        Text(count, style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
