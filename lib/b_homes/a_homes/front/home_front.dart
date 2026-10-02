import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:petping/settings/a_home/settings.dart';
import 'package:petping/b_homes/d_message/chat_preview.dart';
import 'package:petping/b_homes/follow/a_follow/notifica_follow.dart';
import 'package:petping/b_homes/follow/a_follow/follow_show.dart';
import 'package:petping/b_homes/b_registrazioneutente/profile_bios.dart';
import 'package:petping/maps/map_launcher_service.dart';
import 'package:petping/b_homes/a_homes/home.dart';
import 'package:petping/b_homes/c_datianimale/tab_pet.dart';
import 'package:petping/b_homes/c_datianimale/a/pet_card.dart';
import 'package:petping/utils/navigator_helpers.dart';
import 'package:petping/b_homes/screens/profilo_qr_code_screen.dart';
import 'package:petping/b_homes/c_datianimale/addati/aggiungi_animale.dart';
import 'package:petping/ai/pet_ai_button.dart';
import 'package:petping/b_homes/d_message/chat_list_screen.dart';
import 'package:petping/d_tab_sds/a_tab/tab_sds.dart';
import 'package:petping/b_homes/b_user/user_search.dart';
import 'package:petping/social/notific/social_notification_model.dart';
import 'package:petping/social/notific/social_notifications_screen.dart';
import 'package:petping/petsitting/screens/profile/sitter_profile_shortcut.dart';
import 'package:petping/models/user_profile_model.dart';
import '../comunity.dart';
import '../social/social_home.dart';
import 'subscription_button.dart';
import 'package:easy_localization/easy_localization.dart';

// Import dei nuovi widget separati
import 'widgets/home_header.dart';
import 'widgets/pet_list.dart';
import 'widgets/services_section.dart';
import 'widgets/premium_action_card.dart';
import 'widgets/welcome_dialog.dart';

class HomeScreenUI extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String currentUserId;
  final PageController pageController;

  const HomeScreenUI({
    super.key,
    required this.userData,
    required this.currentUserId,
    required this.pageController,
  });

  @override
  State<HomeScreenUI> createState() => _HomeScreenUIState();
}

class _HomeScreenUIState extends State<HomeScreenUI> {
  @override
  void initState() {
    super.initState();
    _checkWelcomePopup();
  }

  Future<void> _checkWelcomePopup() async {
    final prefs = await SharedPreferences.getInstance();
    final bool shown = prefs.getBool('general_welcome_shown_${widget.currentUserId}') ?? false;
    
    if (!shown) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const WelcomeDialog(),
        );
        await prefs.setBool('general_welcome_shown_${widget.currentUserId}', true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color mainColor = Color(0xFF64B5B4);
    const Color bgColor = Color(0xFFF2F5F8);

    final String displayName = widget.userData['username'] ?? 'home_user_default'.tr();
    final String? photoUrl = (widget.userData['fotoUrl'] != null && widget.userData['fotoUrl'] != '') ? widget.userData['fotoUrl'] : null;

    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeHeader(
              name: displayName,
              photo: photoUrl,
              mainColor: mainColor,
              userData: widget.userData,
              currentUserId: widget.currentUserId,
              pageController: widget.pageController,
            ),
            const SizedBox(height: 50),
            const ServicesSection(),
            const SizedBox(height: 40),
            _buildSectionHeader(
              title: 'home_section_pets'.tr(),
              trailing: _buildAddPetButton(context),
            ),
            const SizedBox(height: 12),
            PetList(currentUserId: widget.currentUserId),
            const SizedBox(height: 35),
            _buildSectionHeader(
              title: 'home_section_extra'.tr(),
              icon: Icons.auto_awesome_rounded,
              iconColors: [Colors.yellowAccent, Colors.orangeAccent],
            ),
            const SizedBox(height: 12),
            _buildQuickActions(context),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required String title, Widget? trailing, IconData? icon, List<Color>? iconColors}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1A1A),
              letterSpacing: -0.5,
            ),
          ),
          if (icon != null) ...[
            const SizedBox(width: 8),
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: iconColors ?? [Colors.white, Colors.white],
              ).createShader(bounds),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
          ],
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing,
          ],
        ],
      ),
    );
  }

  Widget _buildAddPetButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AggiungiAnimale())),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF64B5B4), Color(0xFF4DB6AC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF64B5B4).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_circle_outline_rounded, size: 16, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              'home_btn_add'.tr(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          Expanded(
            child: PremiumActionCard(
              icon: Icons.qr_code_2_rounded,
              label: 'home_btn_qr'.tr(),
              color: Colors.blue,
              effectColor: const Color(0xFFFFD8B1),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QRCodeScreen())),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: PremiumActionCard(
              icon: Icons.groups_rounded,
              label: 'home_btn_community'.tr(),
              color: Colors.indigoAccent,
              effectColor: const Color(0xFFB9F6CA),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CommunityScreen())),
            ),
          ),
        ],
      ),
    );
  }
}
