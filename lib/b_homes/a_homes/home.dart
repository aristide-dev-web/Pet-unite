import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:petping/b_homes/b_user/user_search.dart';
import 'package:petping/b_homes/screens/profilo_qr_code_screen.dart';
import 'package:petping/b_homes/b_registrazioneutente/profile_bios.dart';
import 'package:petping/b_homes/c_datianimale/a/lista_animali.dart';
import 'package:petping/b_homes/d_message/chat_list_screen.dart';
import 'package:petping/settings/a_home/settings.dart';
import 'package:petping/utils/navigator_helpers.dart';
import 'package:petping/b_homes/d_message/message_listener.dart';
import 'package:petping/models/user_profile_model.dart';
import 'package:petping/b_homes/a_homes/front/home_front.dart';
import 'package:petping/b_homes/a_homes/social/social_home.dart';
import 'package:petping/ai/pet_ai_button.dart';
import 'package:petping/petdex/petdex_button.dart';

/// Carica i dati utente e avvia il sistema di sincronizzazione messaggi
Future<Map<String, dynamic>?> fetchUserData() async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return null;
  MessageListener().start(uid);
  final doc = await FirebaseFirestore.instance.collection('utenti').doc(uid).get();
  return doc.data();
}

/// Navigazione rapida
void navigateToUserSearch(BuildContext context, String currentUserId) {
  pushWithFade(context, UserSearch(currentUserId: currentUserId));
}

void navigateToMessages(BuildContext context, String currentUserId) {
  pushWithFade(context, ChatListScreen(currentUserId: currentUserId));
}

void navigateToProfile(BuildContext context) {
  pushWithFade(context, const ProfileScreen());
}

void navigateToQRCode(BuildContext context) {
  pushWithFade(context, const QRCodeScreen());
}

void navigateToListaAnimali(BuildContext context) {
  pushWithFade(context, const ListaAnimali());
}

void navigateToSettings(BuildContext context) {
  pushWithFade(context, const SettingsScreen());
}

Widget buildHomeCard(BuildContext context, IconData icon, String label, VoidCallback onTap, {String? image}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          image != null ? Image.asset(image, height: 40) : Icon(icon, size: 40, color: Theme.of(context).primaryColor),
          const SizedBox(height: 12),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

// --- CLASSE PRINCIPALE HOMESCREEN (CONTROLLER) ---

class HomeScreen extends StatefulWidget {
  final String currentUserId;
  const HomeScreen({super.key, required this.currentUserId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  final String _userBoxName = 'user_profile_box';

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    MessageListener().start(widget.currentUserId);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get isSocialMode => _currentPage == 1;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<UserProfile>(_userBoxName).listenable(keys: [widget.currentUserId]),
      builder: (context, Box<UserProfile> box, _) {
        final cachedUser = box.get(widget.currentUserId);

        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('utenti').doc(widget.currentUserId).snapshots(),
          builder: (context, snapshot) {
            Map<String, dynamic> userData;

            if (snapshot.hasData && snapshot.data!.exists) {
              userData = snapshot.data!.data() as Map<String, dynamic>;
              userData['id'] = snapshot.data!.id;
              final profile = UserProfile.fromMap(userData, snapshot.data!.id);
              box.put(widget.currentUserId, profile);
            } else if (cachedUser != null) {
              userData = cachedUser.toMap();
              userData['id'] = widget.currentUserId;
            } else {
              return const Scaffold(
                backgroundColor: Color(0xFFF2F5F8),
                body: Center(child: CircularProgressIndicator()),
              );
            }

            return Scaffold(
              backgroundColor: const Color(0xFFF2F5F8),
              body: Stack(
                children: [
                  PageView(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    onPageChanged: (index) {
                      if (_currentPage != index) {
                        setState(() => _currentPage = index);
                      }
                    },
                    children: [
                      _KeepAlivePage(
                        child: HomeScreenUI(
                          userData: userData,
                          currentUserId: widget.currentUserId,
                          pageController: _pageController,
                        ),
                      ),
                      _KeepAlivePage(
                        child: SocialHome(
                          key: const ValueKey('social'),
                          currentUserId: widget.currentUserId,
                          userData: userData,
                          onSwitchBack: () => _pageController.animateToPage(
                            0,
                            duration: const Duration(milliseconds: 450),
                            curve: Curves.easeOutCubic
                          ),
                        ),
                      ),
                    ],
                  ),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    bottom: isSocialMode ? -100 : 110,
                    left: 20,
                    child: const PetDexButton(),
                  ),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    bottom: isSocialMode ? -100 : 110,
                    right: 20,
                    child: const PetAIButton(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _KeepAlivePage extends StatefulWidget {
  final Widget child;
  const _KeepAlivePage({required this.child});

  @override
  State<_KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<_KeepAlivePage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
