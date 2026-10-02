import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:petping/social/notific/social_notification_model.dart';
import 'package:petping/social/notific/social_notifications_screen.dart';
import 'package:petping/b_homes/b_user/user_search.dart';
import 'package:petping/b_homes/d_message/chat_list_screen.dart';
import 'package:petping/b_homes/d_message/chat_preview.dart';
import 'package:petping/settings/a_home/settings.dart';
import 'package:petping/petsitting/screens/profile/sitter_profile_shortcut.dart';
import 'package:petping/b_homes/b_registrazioneutente/profile_bios.dart';
import '../subscription_button.dart';
import 'package:easy_localization/easy_localization.dart';

class HomeHeader extends StatelessWidget {
  final String name;
  final String? photo;
  final Color mainColor;
  final Map<String, dynamic> userData;
  final String currentUserId;
  final PageController pageController;

  const HomeHeader({
    super.key,
    required this.name,
    required this.photo,
    required this.mainColor,
    required this.userData,
    required this.currentUserId,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230, 
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 195,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [mainColor, mainColor.withBlue(160)],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(45),
                bottomRight: Radius.circular(45),
              ),
              boxShadow: [
                BoxShadow(
                  color: mainColor.withOpacity(0.35),
                  blurRadius: 25,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            padding: const EdgeInsets.only(top: 35, left: 22, right: 15),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Colors.white, Color(0xFFFFD54F)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ).createShader(bounds),
                          child: const Text(
                            'PetUnite',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Transform.rotate(
                          angle: 0.2,
                          child: const Icon(Icons.pets_rounded, color: Color(0xFFFFD54F), size: 18),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () => pageController.animateToPage(
                            1,
                            duration: const Duration(milliseconds: 450),
                            curve: Curves.easeOutCubic,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.public_rounded, color: Colors.white, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  'home_btn_social_profile'.tr().toUpperCase(),
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const SitterProfileShortcut(),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 114,
            left: 140,
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 160),
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.white, Color(0xFFFFD54F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                    letterSpacing: -1.0,
                    height: 1.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0, 
            left: 10,
            right: 10,
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 25,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 110),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildHeaderIconButton(
                          context: context,
                          icon: Icons.search_rounded,
                          gradientColors: [const Color(0xFF81D4FA), const Color(0xFF29B6F6)],
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UserSearch(currentUserId: currentUserId))),
                        ),
                        ValueListenableBuilder(
                          valueListenable: Hive.box<ChatPreview>('chatPreviews').listenable(),
                          builder: (context, Box<ChatPreview> box, _) {
                            final unreadCount = box.values.where((p) => p.isRead == false).length;
                            return _buildHeaderIconButton(
                              context: context,
                              icon: Icons.chat_bubble_rounded,
                              badgeCount: unreadCount,
                              gradientColors: [const Color(0xFFA5D6A7), const Color(0xFF66BB6A)],
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatListScreen(currentUserId: currentUserId))),
                            );
                          },
                        ),
                        ValueListenableBuilder(
                          valueListenable: Hive.box<SocialNotification>('social_notifications_box').listenable(),
                          builder: (context, Box<SocialNotification> box, _) {
                            final unreadCount = box.values.where((n) => !n.isRead).length;
                            return _buildHeaderIconButton(
                              context: context,
                              icon: Icons.notifications_active_rounded,
                              badgeCount: unreadCount,
                              gradientColors: [const Color(0xFFFF8A80), const Color(0xFFFF5252)],
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SocialNotificationsScreen())),
                            );
                          },
                        ),
                        _buildHeaderIconButton(
                          context: context,
                          icon: Icons.settings_suggest_rounded,
                          gradientColors: [const Color(0xFFB39DDB), const Color(0xFF7E57C2)],
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                ],
              ),
            ),
          ),
          Positioned(
            top: 82,
            left: 20,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: mainColor.withOpacity(0.1),
                    backgroundImage: photo != null ? NetworkImage(photo!) : null,
                    child: photo == null ? const Icon(Icons.person, size: 40, color: Colors.white) : null,
                  ),
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.grey[50]!, Colors.white],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 5,
                            offset: const Offset(1, 2),
                          )
                        ],
                      ),
                      child: Icon(Icons.edit_rounded, size: 18, color: mainColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 186,
            left: 22, 
            child: SubscriptionButton(
              userData: userData,
              currentUserId: currentUserId,
              isSmall: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIconButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onTap,
    required List<Color> gradientColors,
    int badgeCount = 0,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        splashColor: Colors.white.withOpacity(0.3),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: gradientColors.last.withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            if (badgeCount > 0)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text(
                      badgeCount > 9 ? '9+' : '$badgeCount',
                      style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
