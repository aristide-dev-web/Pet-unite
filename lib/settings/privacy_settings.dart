import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petping/a_registrazione/a/privacy_policy.dart';
import 'package:petping/a_registrazione/a/terms_conditions.dart';
import 'package:petping/a_registrazione/a/consent_p_t.dart';
 import 'package:easy_localization/easy_localization.dart';

class PrivacySettings extends StatelessWidget {
  const PrivacySettings({super.key});

  Future<void> _accettaPrivacy(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('utenti')
          .doc(user.uid)
          .set({'privacyAccettata': true}, SetOptions(merge: true));
      if (context.mounted) Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('qr_user_not_authenticated'.tr())),
      );
    }
  }

  void _mostraPermessiApp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('settings_privacy_app_permissions_title'.tr()),
        content: SingleChildScrollView(
          child: Text('settings_privacy_app_permissions_desc'.tr()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('btn_close'.tr()),
          ),
        ],
      ),
    );
  }

  void _mostraGestioneDati(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('settings_privacy_data_management_title'.tr()),
        content: SingleChildScrollView(
          child: Text('settings_privacy_data_management_desc'.tr()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('btn_close'.tr()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('settings_label_privacy'.tr())),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: Text('settings_privacy_data_management_title'.tr()),
                  subtitle: Text('settings_privacy_data_management_sub'.tr()),
                  onTap: () => _mostraGestioneDati(context),
                ),
                ListTile(
                  leading: const Icon(Icons.security),
                  title: Text('settings_privacy_app_permissions_title'.tr()),
                  subtitle: Text('settings_privacy_app_permissions_sub'.tr()),
                  onTap: () => _mostraPermessiApp(context),
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: Text('privacy_title'.tr()),
                  subtitle: Text('settings_privacy_policy_sub'.tr()),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
                    );
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.article),
                  title: Text('terms_title'.tr()),
                  subtitle: Text('settings_terms_sub'.tr()),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TermsConditionsScreen()),
                    );
                  },
                ),

            ])
          ),

        ],
      ),
    );
  }
}