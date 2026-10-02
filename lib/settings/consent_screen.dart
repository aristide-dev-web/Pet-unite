import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _acceptedTerms = false;
  bool _acceptedPrivacy = false;

  void _prosegui() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('accepted_terms', true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home'); // o la tua schermata iniziale
  }

  @override
  Widget build(BuildContext context) {
    final tuttoAccettato = _acceptedTerms && _acceptedPrivacy;

    return Scaffold(
      appBar: AppBar(title: Text('welcome'.tr())),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'consent_msg'.tr(),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            CheckboxListTile(
              value: _acceptedTerms,
              onChanged: (val) => setState(() => _acceptedTerms = val ?? false),
              title: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/terms'),
                child: Text.rich(
                  TextSpan(
                    text: 'consent_label_terms'.tr(),
                    style: const TextStyle(decoration: TextDecoration.underline),
                  ),
                ),
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            CheckboxListTile(
              value: _acceptedPrivacy,
              onChanged: (val) => setState(() => _acceptedPrivacy = val ?? false),
              title: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/privacy'),
                child: Text.rich(
                  TextSpan(
                    text: 'consent_label_privacy'.tr(),
                    style: const TextStyle(decoration: TextDecoration.underline),
                  ),
                ),
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: tuttoAccettato ? _prosegui : null,
              child: Text('btn_continue'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}