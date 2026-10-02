import 'package:flutter/material.dart';
import 'package:petping/strip/stripe_api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';

class PremiumPaywallDialog extends StatefulWidget {
  const PremiumPaywallDialog({super.key});

  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const PremiumPaywallDialog(),
    );
    return result ?? false;
  }

  @override
  State<PremiumPaywallDialog> createState() => _PremiumPaywallDialogState();
}

class _PremiumPaywallDialogState extends State<PremiumPaywallDialog> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showComingSoon() {
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
                  color: const Color(0xFF64B5B4).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.stars_rounded, color: Color(0xFF64B5B4), size: 40),
              ),
              const SizedBox(height: 20),
              const Text(
                "Un passo verso il futuro... ❤️",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 15),
              const Text(
                "A presto saranno disponibili gli abbonamenti e tante altre novità che renderanno PetPing ancora più speciale! ✨\n\nStiamo mettendo tutto il nostro amore per creare la migliore esperienza per te e i tuoi piccoli amici. Grazie per far parte del nostro sogno! 🐾",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.5),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF64B5B4),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("Aspetterò con ansia! 😊", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
    const Color mainColor = Color(0xFF64B5B4);
    const Color accentColor = Color(0xFFFA709A);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
      backgroundColor: Colors.white,
      elevation: 25,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Page Indicator superiore
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(2, (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 6,
                  width: _currentPage == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? mainColor : mainColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                )),
              ),
            ),
            
            Flexible(
              child: SizedBox(
                height: 520,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  children: [
                    _buildVisionPage(mainColor),
                    _buildFeaturesPage(mainColor, accentColor),
                  ],
                ),
              ),
            ),

            // Pulsanti di navigazione/azione
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 0, 25, 30),
              child: Column(
                children: [
                  if (_currentPage == 0)
                    _buildButton(
                      text: "welcome_popup_next".tr().toUpperCase(),
                      onTap: () => _pageController.nextPage(
                        duration: const Duration(milliseconds: 500), 
                        curve: Curves.easeInOut
                      ),
                      color: mainColor,
                    )
                  else
                    _buildButton(
                      text: "premium_btn_subscribe".tr().toUpperCase(),
                      onTap: () => _showComingSoon(),
                      /*onTap: () async {
                        final url = await StripeApiService.instance.createSosSubscriptionSession();
                        if (url != null) {
                          final uri = Uri.parse(url);
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                          if (context.mounted) Navigator.pop(context, true);
                        }
                      },*/
                      color: mainColor,
                    ),
                  
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(
                      "premium_btn_back".tr(),
                      style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisionPage(Color mainColor) {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: mainColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.radar_rounded, color: mainColor, size: 45),
          ),
          const SizedBox(height: 20),
          Text(
            'premium_title'.tr(),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  Text(
                    'premium_subtitle'.tr(),
                    style: TextStyle(fontSize: 15, color: mainColor, fontWeight: FontWeight.w800, height: 1.4),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'premium_desc_1'.tr(),
                    style: TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.8), height: 1.6, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'premium_desc_2'.tr(),
                    style: TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.6), height: 1.6, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesPage(Color mainColor, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.auto_awesome_rounded, color: accentColor, size: 45),
          ),
          const SizedBox(height: 20),
          const Text(
            "COSA TI DIAMO",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFeatureItem(Icons.campaign_rounded, 'premium_feature_1'.tr(), Colors.redAccent),
                const SizedBox(height: 25),
                _buildFeatureItem(Icons.palette_rounded, 'premium_feature_2'.tr(), const Color(0xFFE67E22)),
                const SizedBox(height: 25),
                _buildFeatureItem(Icons.favorite_rounded, 'premium_feature_3'.tr(), mainColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({required String text, required VoidCallback onTap, required Color color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 55,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.2, fontSize: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A)),
          ),
        ),
      ],
    );
  }
}
