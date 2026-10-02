import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:petping/b_homes/c_datianimale/diariopet/back_diario.dart';
import 'package:easy_localization/easy_localization.dart';

class LogoutScreen extends StatelessWidget {
  const LogoutScreen({super.key});

  Future<void> _clearAllHiveBoxes() async {
    try {
      await Hive.box('messages').clear();
      await Hive.box('chatPreviews').clear();
      await Hive.box('esami').clear();
      await Hive.box('calendar_events').clear();
      await Hive.box('notifiche_box').clear();
      await Hive.box(animaliBoxName).clear();
      await Hive.box('social_posts_box').clear();
      await Hive.box('social_notifications_box').clear();
      await Hive.box('social_pages_box').clear();
      debugPrint("🧹 All Hive boxes cleared successfully on logout.");
    } catch (e) {
      debugPrint("⚠️ Error clearing Hive boxes: $e");
    }
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('logout_confirm_title'.tr()),
        content: Text('logout_confirm_msg'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('btn_cancel'.tr()),
          ),
          TextButton(
            onPressed: () async {
              // 1. Svuota Hive per la privacy multi-account
              await _clearAllHiveBoxes();
              
              // 2. Logout da Firebase
              await FirebaseAuth.instance.signOut();
              
              if (context.mounted) {
                Navigator.pop(dialogContext);
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            },
            child: Text('logout'.tr(), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('logout_title'.tr())),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            Text(
              "logout_msg_leaving".tr(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout, color: Colors.white),
                label: Text('logout_btn_exit_now'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                ),
                onPressed: () => _confirmLogout(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
