import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';

class SuccessPremiumDialog extends StatelessWidget {
  const SuccessPremiumDialog({super.key});

  static Future<void> show(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const SuccessPremiumDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color mainColor = Color(0xFF64B5B4);
    const Color goldColor = Color(0xFFFFD700);
    const Color deepText = Color(0xFF2C3E50);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
      elevation: 15,
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icona celebrativa
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [goldColor.withOpacity(0.3), Colors.transparent],
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: mainColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: mainColor.withOpacity(0.4), blurRadius: 15, spreadRadius: 1)
                      ],
                    ),
                    child: const Icon(Icons.star_rounded, color: goldColor, size: 50),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              
              Text(
                'premium_thanks_title'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: deepText,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 15),
              
              Text(
                'premium_thanks_msg'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: mainColor.withOpacity(0.8), height: 1.4),
              ),
              const SizedBox(height: 20),
              
              Text(
                'premium_thanks_custom'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.6),
              ),
              
              const SizedBox(height: 30),

              // Pulsante Chiudi/Inizia
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 8,
                    shadowColor: mainColor.withOpacity(0.4),
                  ),
                  child: Text(
                    'premium_thanks_btn'.tr(),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                  ),
                ),
              ),
              
              const SizedBox(height: 15),
              
              // Tasto Contatti
              TextButton.icon(
                onPressed: () async {
                  final Uri emailUri = Uri(
                    scheme: 'mailto',
                    path: 'support.petunite@gmail.com',
                    queryParameters: {'subject': 'premium_thanks_email_subject'.tr()},
                  );
                  if (await canLaunchUrl(emailUri)) {
                    await launchUrl(emailUri);
                  }
                },
                icon: const Icon(Icons.mail_outline_rounded, color: mainColor, size: 18),
                label: Text(
                  'premium_thanks_contact'.tr(),
                  style: const TextStyle(color: mainColor, fontWeight: FontWeight.w800, decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
