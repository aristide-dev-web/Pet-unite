import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';

class FollowPrivacySettings extends StatefulWidget {
  final String currentUserId;

  const FollowPrivacySettings({super.key, required this.currentUserId});

  @override
  State<FollowPrivacySettings> createState() => _FollowPrivacySettingsState();
}

class _FollowPrivacySettingsState extends State<FollowPrivacySettings> {
  String _selectedPrivacy = 'public';

  void _updatePrivacySetting(String? value) async {
    if (value == null) return;
    // ✅ CORRETTO: cambiato 'users' in 'utenti'
    await FirebaseFirestore.instance.collection('utenti').doc(widget.currentUserId).update({
      'followPrivacy': value,
    });
    setState(() {
      _selectedPrivacy = value;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadPrivacySetting();
  }

  Future<void> _loadPrivacySetting() async {
    // ✅ CORRETTO: cambiato 'users' in 'utenti'
    final doc = await FirebaseFirestore.instance.collection('utenti').doc(widget.currentUserId).get();
    if (doc.exists) {
      setState(() {
        _selectedPrivacy = doc.data()?['followPrivacy'] ?? 'public';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('b_homes_follow_privacy_title'.tr())),
      body: Column(
        children: [
          RadioListTile(
            title: Text('b_homes_follow_privacy_public'.tr()),
            value: 'public',
            groupValue: _selectedPrivacy,
            onChanged: _updatePrivacySetting,
          ),
          RadioListTile(
            title: Text('b_homes_follow_privacy_request'.tr()),
            value: 'request',
            groupValue: _selectedPrivacy,
            onChanged: _updatePrivacySetting,
          ),
          RadioListTile(
            title: Text('b_homes_follow_privacy_private'.tr()),
            value: 'private',
            groupValue: _selectedPrivacy,
            onChanged: _updatePrivacySetting,
          ),
        ],
      ),
    );
  }
}