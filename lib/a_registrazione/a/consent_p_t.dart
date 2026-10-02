import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:petping/a_registrazione/a/terms_conditions.dart';
import 'package:petping/a_registrazione/a/privacy_policy.dart';
import 'package:petping/a_main/memory/main_login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> with SingleTickerProviderStateMixin {
  bool acceptedTerms = false;
  bool acceptedPrivacy = false;
  bool hasViewedTerms = false;
  bool hasViewedPrivacy = false;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _checkAndProceed() {
    if (acceptedTerms && acceptedPrivacy) {
      _proceedToLogin();
    }
  }

  void _navigateToTerms() async {
    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TermsConditionsScreen()),
    );
    setState(() {
      hasViewedTerms = true;
      if (result == true) acceptedTerms = true;
    });
    _checkAndProceed();
  }

  void _navigateToPrivacy() async {
    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
    );
    setState(() {
      hasViewedPrivacy = true;
      if (result == true) acceptedPrivacy = true;
    });
    _checkAndProceed();
  }

  void _proceedToLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('termini_accettati', true);
    await prefs.setBool('privacy_accettata', true);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.lightBlue[400]!;
    final bool isReady = acceptedTerms && acceptedPrivacy;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Sfondo con sfocatura dinamica (Glassmorphism)
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/sfondi/temini e privacy.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
              child: Container(color: Colors.black.withOpacity(0.2)),
            ),
          ),
          
          // 2. Pannello Premium in basso
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25, 35, 25, 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.8),
                    Colors.black,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'consent_title'.tr(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'consent_msg'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 35),
                  
                  // Bottone Termini
                  _buildConsentButton(
                    label: 'consent_label_terms'.tr(),
                    isAccepted: acceptedTerms,
                    hasViewed: hasViewedTerms,
                    onTap: _navigateToTerms,
                    primaryColor: primaryColor,
                  ),
                  const SizedBox(height: 15),
                  
                  // Bottone Privacy
                  _buildConsentButton(
                    label: 'consent_label_privacy'.tr(),
                    isAccepted: acceptedPrivacy,
                    hasViewed: hasViewedPrivacy,
                    onTap: _navigateToPrivacy,
                    primaryColor: primaryColor,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Bottone di Proseguimento Animato
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: isReady ? 1.0 : 0.3,
                    child: GestureDetector(
                      onTap: isReady ? _proceedToLogin : null,
                      child: Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: isReady 
                            ? LinearGradient(colors: [primaryColor, Colors.blue[700]!])
                            : const LinearGradient(colors: [Colors.grey, Colors.blueGrey]),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: isReady ? [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            )
                          ] : [],
                        ),
                        child: Center(
                          child: Text(
                            'btn_start_upper'.tr(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsentButton({
    required String label,
    required bool isAccepted,
    required bool hasViewed,
    required VoidCallback onTap,
    required Color primaryColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(isAccepted ? 0.15 : 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isAccepted ? primaryColor : Colors.white24,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isAccepted ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: isAccepted ? primaryColor : Colors.white38,
              size: 24,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isAccepted ? Colors.white : Colors.white70,
                  fontSize: 15,
                  fontWeight: isAccepted ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 14),
          ],
        ),
      ),
    );
  }
}
