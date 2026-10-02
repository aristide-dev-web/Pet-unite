import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SegnalaUtenteScreen extends StatefulWidget {
  final String reportedUserId;
  final String reportedUsername;

  const SegnalaUtenteScreen({
    super.key,
    required this.reportedUserId,
    required this.reportedUsername,
  });

  @override
  State<SegnalaUtenteScreen> createState() => _SegnalaUtenteScreenState();
}

class _SegnalaUtenteScreenState extends State<SegnalaUtenteScreen> {
  String _currentUsername = "";
  final TextEditingController _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCurrentUsername();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _fetchCurrentUsername() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final doc = await FirebaseFirestore.instance.collection('utenti').doc(uid).get();
        if (doc.exists && mounted) {
          setState(() {
            _currentUsername = doc.data()?['username'] ?? "";
          });
        }
      }
    } catch (e) {
      debugPrint("Errore recupero username: $e");
    }
  }

  void _inviaEmail(BuildContext context) async {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('snack_report_reason_empty'.tr())),
      );
      return;
    }

    final subject = Uri.encodeComponent(
      'profile_report_email_subject'.tr(args: [widget.reportedUsername]),
    );
    
    // Costruiamo il corpo includendo anche chi segnala se disponibile
    final bodyText = 'profile_report_email_body'.tr(args: [
      widget.reportedUsername,
      widget.reportedUserId,
      reason,
      _currentUsername.isNotEmpty ? _currentUsername : (FirebaseAuth.instance.currentUser?.email ?? 'Utente')
    ]);

    final body = Uri.encodeComponent(bodyText);
    
    final uri = Uri.parse(
      'mailto:support.petunite@gmail.com?subject=$subject&body=$body',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      if (context.mounted) Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('snack_email_app_error'.tr())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.4),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, spreadRadius: 5)
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.report_problem_rounded, color: Colors.orange, size: 40),
                ),
                const SizedBox(height: 20),
                Text(
                  'profile_report_user_title'.tr(args: [widget.reportedUsername]),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 15),
                Text(
                  'profile_report_popup_desc'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.5),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _reasonController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'profile_report_reason_hint'.tr(),
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(15),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('btn_close'.tr(), style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _inviaEmail(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: Text('profile_report_contact_btn'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
