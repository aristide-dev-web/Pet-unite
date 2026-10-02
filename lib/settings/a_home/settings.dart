import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petping/b_homes/b_user/blockuser/BlockedUsersScreen.dart';
import 'package:petping/a_registrazione/a_alenguage/language_settings.dart';
import 'package:petping/settings/account_settings.dart';
import 'package:petping/settings/supporto.dart';
import 'package:petping/settings/infolegali.dart';
import 'package:petping/settings/notifications_settings.dart';
import 'package:petping/settings/admin_dashboard_screen.dart';
import 'package:petping/models/user_profile_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  bool get isAdmin {
    final box = Hive.box<UserProfile>('user_profile_box');
    return box.get(currentUserId)?.isAdmin ?? false;
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserId == null) return Scaffold(body: Center(child: Text('settings_error_logged_out'.tr())));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Sfondo leggermente grigio per far risaltare le card bianche
      appBar: AppBar(
        title: Text(
          'settings'.tr(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _buildSectionHeader('settings_section_account'.tr()),
          _buildSettingsCard(
            icon: Icons.manage_accounts_rounded,
            iconColor: Colors.orange,
            title: 'settings_label_manage_account'.tr(),
            subtitle: 'settings_sub_manage_account'.tr(),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountSettingsScreen())),
          ),
          _buildSettingsCard(
            icon: Icons.block_flipped,
            iconColor: Colors.redAccent,
            title: 'settings_label_blocked_users'.tr(),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BlockedUsersScreen(currentUserId: currentUserId!))),
          ),
          _buildSettingsCard(
            icon: Icons.privacy_tip_rounded,
            iconColor: Colors.blueAccent,
            title: 'settings_label_privacy'.tr(),
            onTap: () => Navigator.pushNamed(context, '/settings/privacy'),
          ),

          if (isAdmin) ...[
            const SizedBox(height: 16),
            _buildSectionHeader('settings_section_admin'.tr()),
            _buildSettingsCard(
              icon: Icons.admin_panel_settings_rounded,
              iconColor: Colors.deepPurple,
              title: 'admin_dashboard_title'.tr(),
              subtitle: 'admin_dashboard_subtitle'.tr(),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen())),
            ),
          ],

          const SizedBox(height: 16),
          _buildSectionHeader('settings_section_app'.tr()),
          _buildSettingsCard(
            icon: Icons.language_rounded,
            iconColor: Colors.teal,
            title: 'language'.tr(),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LanguageSettings(isFromSettings: true))),
          ),
          _buildSettingsCard(
            icon: Icons.notifications_active_rounded,
            iconColor: Colors.amber[700]!,
            title: 'settings_label_push_notif'.tr(),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationSettingsScreen())),
          ),
          _buildSettingsCard(
            icon: Icons.delete_forever_rounded,
            iconColor: Colors.grey,
            title: 'settings_label_delete_account'.tr(),
            onTap: () => Navigator.pushNamed(context, '/settings/delete'),
          ),
          _buildSettingsCard(
            icon: Icons.logout_rounded,
            iconColor: Colors.red[400]!,
            title: 'logout'.tr(),
            onTap: () => Navigator.pushNamed(context, '/settings/logout'),
          ),

          const SizedBox(height: 16),
          _buildSectionHeader('settings_section_info'.tr()),
          _buildSettingsCard(
            icon: Icons.support_agent_rounded,
            iconColor: Colors.purpleAccent,
            title: 'settings_label_support'.tr(),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportoScreen())),
          ),
          _buildSettingsCard(
            icon: Icons.gavel_rounded,
            iconColor: Colors.blueGrey,
            title: 'settings_label_legal'.tr(),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InfoLegaliScreen())),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12, top: 16),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Colors.blueGrey[400],
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}