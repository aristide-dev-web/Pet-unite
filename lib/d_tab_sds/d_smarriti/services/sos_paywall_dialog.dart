import 'package:flutter/material.dart';
import 'package:petping/strip/stripe_api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';

class SosPaywallDialog extends StatelessWidget {
  const SosPaywallDialog({super.key});

  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const SosPaywallDialog(),
    );
    return result ?? false;
  }

  void _showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFE67E22).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFFE67E22), size: 40),
              ),
              const SizedBox(height: 20),
              const Text(
                "Il nostro sogno continua... ❤️",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 15),
              const Text(
                "A presto saranno disponibili gli abbonamenti e tante altre novità! ✨\n\nStiamo lavorando con tutto il cuore per rendere PetPing un posto magico per i nostri amici a quattro zampe. Grazie per il tuo supporto costante! 🐾",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.5),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE67E22),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("Ho capito, grazie! 😊", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color orangeRescue = Color(0xFFE67E22);
    const Color deepText = Color(0xFF2C3E50);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      elevation: 10,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icona Calda
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: orangeRescue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite_rounded, color: orangeRescue, size: 40),
            ),
            const SizedBox(height: 20),
            
            Text(
              'sos_paywall_heart_msg'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: deepText,
              ),
            ),
            const SizedBox(height: 16),
            
            Text(
              'sos_paywall_desc_1'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 12),
            
            Text(
              'sos_paywall_desc_2'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey, height: 1.5, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),

            // Badge Prezzo
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('sos_paywall_sub_label'.tr(), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  Text('sos_paywall_premium_badge'.tr(), style: const TextStyle(color: deepText, fontWeight: FontWeight.w900, fontSize: 18)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Pulsante Attiva Abbonamento
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => _showComingSoon(context),
                /*onPressed: () async {
                  // Collegato correttamente alla sezione ABBONAMENTO
                  final url = await StripeApiService.instance.createSosSubscriptionSession();
                  
                  if (url != null) {
                    final uri = Uri.parse(url);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                      if (context.mounted) Navigator.pop(context, true);
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('snack_subscription_error'.tr())),
                      );
                    }
                  }
                },*/
                style: ElevatedButton.styleFrom(
                  backgroundColor: orangeRescue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                ),
                child: Text(
                  'sos_paywall_activate_btn'.tr(),
                  style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
                ),
              ),
            ),
            
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'btn_back'.tr(),
                style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
