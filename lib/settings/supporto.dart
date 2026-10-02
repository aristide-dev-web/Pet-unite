import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';

class SupportoScreen extends StatelessWidget {
  const SupportoScreen({super.key});

  Future<void> _inviaEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support.petunite@gmail.com',
      query: Uri.encodeFull('subject=${'support_email_subject_default'.tr()}&body=${'support_email_body_default'.tr()}'),
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      // fallback
      debugPrint('support_err_email'.tr());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('support_title'.tr())),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'support_need_help'.tr(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'support_contact_desc'.tr(),
            ),
            const SizedBox(height: 8),
            // Email cliccabile come testo
            GestureDetector(
              onTap: _inviaEmail,
              child: const Text(
                'support.petunite@gmail.com',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                onPressed: _inviaEmail,
                icon: const Icon(Icons.email),
                label: Text('support_btn_write'.tr()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}