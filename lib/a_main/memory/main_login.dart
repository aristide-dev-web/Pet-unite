import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petping/a_main/auth_gate.dart';
import 'package:petping/a_registrazione/a_alenguage/language_settings.dart';
import 'package:petping/a_main/memory/sign_google.dart';
import 'package:petping/a_main/memory/sign_apple.dart';
import 'package:petping/a_registrazione/b/register_email.dart';
import 'package:petping/notific.dart';
import 'package:easy_localization/easy_localization.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String message = '';

  Future<void> login() async {
    if (emailController.text.trim().isEmpty || passwordController.text.trim().isEmpty) {
      setState(() {
        message = 'login_error_empty_fields'.tr();
      });
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await NotificationService().updateToken();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthGate()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        message = 'snack_error_msg'.tr(args: [e.message ?? '']);
      });
    }
  }

  // Widget per i cuori con bagliore premium
  Widget _buildInlineHeart(Color color, {double size = 18}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Icon(
        Icons.favorite,
        color: color,
        size: size,
        shadows: [
          Shadow(
            color: color.withOpacity(0.8),
            blurRadius: 10,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryAzure = Colors.cyanAccent[400]!;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Sfondo
          Positioned.fill(
            child: Image.asset(
              'assets/sfondi/login.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: Colors.black);
              },
            ),
          ),

          // Glow sul fondo
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, 0.9),
                  radius: 1.2,
                  colors: [primaryAzure.withOpacity(0.35), Colors.transparent],
                ),
              ),
            ),
          ),

          // 2. Frase in ALTO - Versione PREMIUM
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Color(0xFFFFD700),
                            Color(0xFFFFFACD),
                            Color(0xFFDAA520),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ).createShader(bounds),
                        child: Text(
                          'login_welcome_family'.tr(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w900,
                            shadows: [
                              Shadow(
                                blurRadius: 15,
                                color: Colors.black,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildInlineHeart(const Color(0xFFE0B0FF)),
                      _buildInlineHeart(const Color(0xFFFFD700), size: 22),
                      _buildInlineHeart(const Color(0xFFE0B0FF)),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. Modulo di login - ABBASSATO AL MASSIMO
          Align(
            alignment: const Alignment(0, 1.0), // Spinto totalmente in basso
            child: Padding(
              padding: EdgeInsets.only(
                left: 25,
                right: 25,
                bottom: MediaQuery.of(context).padding.bottom + 5,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    constraints: const BoxConstraints(maxWidth: 320),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: primaryAzure.withOpacity(0.15),
                          blurRadius: 25,
                          spreadRadius: -5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildCompactTextField(
                          controller: emailController,
                          hint: 'login_email_hint'.tr(),
                          icon: Icons.alternate_email_rounded,
                          primaryColor: primaryAzure,
                        ),
                        const SizedBox(height: 10),
                        _buildCompactTextField(
                          controller: passwordController,
                          hint: 'login_password_hint'.tr(),
                          icon: Icons.lock_outline_rounded,
                          obscure: true,
                          primaryColor: primaryAzure,
                        ),

                        if (message.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              message,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),

                        const SizedBox(height: 15),

                        // Bottone Login
                        Container(
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            gradient: LinearGradient(
                              colors: [primaryAzure, primaryAzure.withBlue(255)],
                            ),
                          ),
                          child: ElevatedButton(
                            onPressed: login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                            child: Text(
                              'login_btn_login'.tr().toUpperCase(),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Social Buttons - GOOGLE E APPLE
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _compactSocialBtn(
                              onPressed: () => signInWithGoogle(context),
                              logo: Image.network(
                                'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1024px-Google_%22G%22_logo.svg.png',
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata, color: Colors.white, size: 24),
                              ),
                            ),
                            const SizedBox(width: 25),
                            _compactSocialBtn(
                              onPressed: () => signInWithApple(context),
                              logo: Image.network(
                                'https://upload.wikimedia.org/wikipedia/commons/thumb/8/84/Apple_Computer_Logo_1977.svg/1024px-Apple_Computer_Logo_1977.svg.png',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.apple, color: Colors.white, size: 24),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Link Registrazione - SOTTO A TUTTO
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 25),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterEmail()));
                          },
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              "login_no_account".tr(),
                              maxLines: 1,
                              style: TextStyle(
                                color: primaryAzure,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                decorationColor: primaryAzure,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color primaryColor,
    bool obscure = false,
  }) {
    return SizedBox(
      height: 46,
      child: TextField(
        controller: controller,
        obscureText: obscure,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white60, size: 18),
          prefixIconConstraints: const BoxConstraints(minWidth: 48),
          suffixIcon: Icon(icon, color: Colors.transparent, size: 18),
          suffixIconConstraints: const BoxConstraints(minWidth: 48),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
          filled: true,
          fillColor: Colors.black.withOpacity(0.4),
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
          ),
        ),
      ),
    );
  }

  Widget _compactSocialBtn({required Widget logo, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: SizedBox(
          width: 24,
          height: 24,
          child: Center(child: logo),
        ),
      ),
    );
  }
}
