import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petping/a_main/auth_gate.dart';
import 'package:easy_localization/easy_localization.dart';

class RegisterEmail extends StatefulWidget {
  const RegisterEmail({super.key});

  @override
  State<RegisterEmail> createState() => _RegisterEmailState();
}

class _RegisterEmailState extends State<RegisterEmail> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  String message = '';
  bool isLoading = false;
  bool _obscurePassword = true;

  // Controllo validità email
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> register() async {
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();
    final String confirmPassword = confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() => message = 'login_error_empty_fields'.tr());
      return;
    }

    if (!_isValidEmail(email)) {
      setState(() => message = 'ps_reg_error_email_invalid'.tr());
      return;
    }

    if (password != confirmPassword) {
      setState(() => message = 'register_error_passwords_dont_match'.tr());
      return;
    }

    if (password.length < 6) {
      setState(() => message = 'register_hint_password'.tr());
      return;
    }

    setState(() {
      isLoading = true;
      message = 'register_msg_creating'.tr();
    });

    try {
      final UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await FirebaseFirestore.instance.collection('utenti').doc(userCredential.user!.uid).set({
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'isPetSitter': false,
        'profiloCreato': false,
      });

      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AuthGate()));
    } on FirebaseAuthException catch (e) {
      setState(() {
        message = 'register_error_prefix'.tr() + (e.message ?? '');
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        message = 'register_error_prefix'.tr() + e.toString();
        isLoading = false;
      });
    }
  }

  Widget _buildInlineHeart(Color color, {double size = 18}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Icon(
        Icons.favorite,
        color: color,
        size: size,
        shadows: [Shadow(color: color.withOpacity(0.7), blurRadius: 12)],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryAzure = Colors.cyanAccent[400]!;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false, // BLOCCA LO SFONDO
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // 1. SFONDO FISSO
          Positioned.fill(
            child: Image.asset(
              'assets/sfondi/registrazione.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (context, error, stackTrace) => Container(color: Colors.black),
            ),
          ),

          // 2. TITOLO
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFFACD), Color(0xFFDAA520)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ).createShader(bounds),
                      child: Text(
                        'register_title'.tr(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    _buildInlineHeart(const Color(0xFFE0B0FF)),
                    _buildInlineHeart(const Color(0xFFFFD700), size: 22),
                    _buildInlineHeart(const Color(0xFFE0B0FF)),
                  ],
                ),
              ),
            ),
          ),

          // 3. CONTENUTO SCORREVOLE
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.23), 
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildCompactTextField(
                          controller: emailController,
                          hint: 'register_hint_email'.tr(),
                          icon: Icons.alternate_email_rounded,
                          primaryColor: primaryAzure,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 15),
                        _buildCompactTextField(
                          controller: passwordController,
                          hint: 'register_hint_password'.tr(),
                          icon: Icons.lock_outline_rounded,
                          obscure: _obscurePassword,
                          primaryColor: primaryAzure,
                          hasToggle: true,
                        ),
                        const SizedBox(height: 15),
                        _buildCompactTextField(
                          controller: confirmPasswordController,
                          hint: "register_confirm_password".tr(),
                          icon: Icons.lock_reset_rounded,
                          obscure: _obscurePassword,
                          primaryColor: primaryAzure,
                          hasToggle: true,
                        ),
                        
                        if (message.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              message,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: message.contains('Error') || message.contains('Errore') || message.contains('email') ? Colors.redAccent : Colors.black87,
                                fontSize: 10, 
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        
                        const SizedBox(height: 25),

                        // Bottone Sign Up
                        Container(
                          width: 190,
                          height: 46,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(colors: [primaryAzure, primaryAzure.withBlue(255)]),
                            boxShadow: [BoxShadow(color: primaryAzure.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))],
                          ),
                          child: ElevatedButton(
                            onPressed: isLoading ? null : register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: isLoading 
                              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                              : Text(
                                  'register_btn_signup'.tr().toUpperCase(),
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.black),
                                ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'register_already_account'.tr(),
                            style: TextStyle(color: primaryAzure.withBlue(120), fontSize: 11, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: keyboardHeight + 100),
                ],
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
    bool hasToggle = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return SizedBox(
      height: 44,
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black54, size: 18),
          prefixIconConstraints: const BoxConstraints(minWidth: 40),
          suffixIcon: hasToggle 
            ? IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.black38, size: 18),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              )
            : const SizedBox(width: 40),
          suffixIconConstraints: const BoxConstraints(minWidth: 40),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
          filled: true,
          fillColor: Colors.grey[300]!.withOpacity(0.4),
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black12)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryColor.withOpacity(0.5), width: 1.2)),
        ),
      ),
    );
  }
}
