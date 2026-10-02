import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  bool _isDeleting = false;

  Future<void> _deleteAccountData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isDeleting = true);

    try {
      final String uid = user.uid;
      final firestore = FirebaseFirestore.instance;

      // 1. ELIMINAZIONE DOCUMENTI FIRESTORE
      await firestore.collection('utenti').doc(uid).delete();
      await firestore.collection('sitters').doc(uid).delete();

      final animaliQuery = await firestore.collection('animali').where('ownerId', isEqualTo: uid).get();
      for (var doc in animaliQuery.docs) {
        await doc.reference.delete();
      }

      final postsQuery = await firestore.collection('posts').where('uid', isEqualTo: uid).get();
      for (var doc in postsQuery.docs) {
        await doc.reference.delete();
      }

      final storiesQuery = await firestore.collection('stories').where('uid', isEqualTo: uid).get();
      for (var doc in storiesQuery.docs) {
        await doc.reference.delete();
      }

      final blocked1 = await firestore.collection('blocked_users').where('blockerId', isEqualTo: uid).get();
      for (var doc in blocked1.docs) await doc.reference.delete();
      final blocked2 = await firestore.collection('blocked_users').where('blockedId', isEqualTo: uid).get();
      for (var doc in blocked2.docs) await doc.reference.delete();

      // 2. ELIMINAZIONE FILE STORAGE
      try {
        final storage = FirebaseStorage.instance;
        await storage.ref('users/$uid').listAll().then((res) async {
          for (var item in res.items) await item.delete();
        });
        await storage.ref('pets/$uid').listAll().then((res) async {
          for (var item in res.items) await item.delete();
        });
      } catch (e) {
        debugPrint("Storage delete error: $e");
      }

      // 3. PULIZIA HIVE
      await Hive.deleteFromDisk();

      // 4. ELIMINAZIONE AUTH
      await user.delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("delete_account_success".tr()))
        );
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }

    } catch (e) {
      debugPrint("DELETE_ERROR: $e");
      if (mounted) {
        setState(() => _isDeleting = false);
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text("delete_error_security_title".tr()),
            content: Text("delete_error_security_msg".tr()),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text("btn_ok".tr()))
            ],
          )
        );
      }
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 30),
            const SizedBox(width: 10),
            Expanded(child: Text('delete_account_title'.tr(), style: const TextStyle(fontWeight: FontWeight.bold))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "delete_account_warning_title".tr(),
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 16),
            ),
            const SizedBox(height: 15),
            Text(
              "delete_account_warning_desc".tr(),
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('btn_cancel'.tr(), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAccountData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text('btn_delete'.tr().toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('delete_account_title'.tr()),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: _isDeleting 
        ? Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.red),
              const SizedBox(height: 20),
              Text("delete_account_deleting_msg".tr(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
            ],
          ))
        : Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.delete_forever_rounded, size: 120, color: Colors.redAccent),
                const SizedBox(height: 30),
                Text(
                  "delete_account_attention".tr().toUpperCase(),
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  "delete_account_final_warning".tr(),
                  style: TextStyle(fontSize: 16, color: Colors.grey[800], height: 1.5, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.delete_forever, color: Colors.white),
                    label: Text('delete_account_btn_permanent'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 4,
                    ),
                    onPressed: () => _confirmDelete(context),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
