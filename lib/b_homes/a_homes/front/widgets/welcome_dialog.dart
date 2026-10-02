import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class WelcomeDialog extends StatefulWidget {
  const WelcomeDialog({super.key});

  @override
  State<WelcomeDialog> createState() => _WelcomeDialogState();
}

class _WelcomeDialogState extends State<WelcomeDialog> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color mainColor = Color(0xFF64B5B4);

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
            
            SizedBox(
              height: 520,
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [
                  _buildDreamPage(mainColor),
                  _buildFeaturesPage(mainColor),
                ],
              ),
            ),

            // Pulsanti di navigazione
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 0, 25, 30),
              child: _currentPage == 0
                ? _buildButton(
                    text: 'welcome_popup_next'.tr().isEmpty || 'welcome_popup_next'.tr() == 'welcome_popup_next' ? "SCOPRI DI PIÙ" : 'welcome_popup_next'.tr(),
                    onTap: () => _pageController.nextPage(
                      duration: const Duration(milliseconds: 500), 
                      curve: Curves.easeInOut
                    ),
                    color: mainColor,
                  )
                : _buildButton(
                    text: 'welcome_popup_btn'.tr(),
                    onTap: () => Navigator.pop(context),
                    color: mainColor,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDreamPage(Color mainColor) {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 45),
          ),
          const SizedBox(height: 20),
          Text(
            'welcome_popup_dream_title'.tr(),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  Text(
                    'welcome_popup_dream_part1'.tr(),
                    style: TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.8), height: 1.6, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'welcome_popup_dream_part2'.tr(),
                    style: TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.7), height: 1.6, fontStyle: FontStyle.italic),
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

  Widget _buildFeaturesPage(Color mainColor) {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: mainColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.auto_awesome_rounded, color: mainColor, size: 45),
          ),
          const SizedBox(height: 20),
          Text(
            'welcome_popup_title'.tr(),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildFeatureItem(Icons.badge_rounded, 'welcome_popup_petcard_title'.tr(), 'welcome_popup_petcard_desc'.tr(), const Color(0xFFE67E22)),
                  const SizedBox(height: 15),
                  _buildFeatureItem(Icons.calendar_month_rounded, 'welcome_popup_calendar_title'.tr(), 'welcome_popup_calendar_desc'.tr(), mainColor),
                  const SizedBox(height: 15),
                  _buildFeatureItem(Icons.stars_rounded, 'welcome_popup_social_title'.tr(), 'welcome_popup_social_desc'.tr(), const Color(0xFFFA709A)),
                  const SizedBox(height: 15),
                  _buildFeatureItem(Icons.privacy_tip_rounded, 'welcome_popup_privacy_title'.tr(), 'welcome_popup_privacy_desc'.tr(), mainColor),
                  const SizedBox(height: 15),
                  _buildFeatureItem(Icons.campaign_rounded, 'welcome_popup_sos_title'.tr(), 'welcome_popup_sos_desc'.tr(), Colors.redAccent),
                ],
              ),
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
            text.toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.2, fontSize: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
              const SizedBox(height: 2),
              Text(description, style: const TextStyle(fontSize: 12, color: Colors.black54, height: 1.3)),
            ],
          ),
        ),
      ],
    );
  }
}
