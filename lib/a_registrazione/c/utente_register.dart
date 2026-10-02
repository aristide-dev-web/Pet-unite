import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:petping/a_main/tab/main_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';
import 'package:easy_localization/easy_localization.dart';
import 'package:petping/utils/image_optimizer.dart';

class UtenteRegisterScreen extends StatefulWidget {
  const UtenteRegisterScreen({super.key});

  @override
  State<UtenteRegisterScreen> createState() => _UtenteRegisterScreenState();
}

class _UtenteRegisterScreenState extends State<UtenteRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();

  File? _immagineProfilo;
  Uint8List? _immagineWeb;
  String? _urlImmagine;
  bool _isLoading = false;

  Future<void> _scegliImmagine() async {
    if (kIsWeb) {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _immagineProfilo = null;
          _immagineWeb = result.files.single.bytes;
        });
      }
    } else {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 90,
      );
      
      if (pickedFile != null) {
        File optimizedFile = await ImageOptimizer.optimize(
          file: File(pickedFile.path),
          maxWidth: 512,
          quality: 85,
        );

        setState(() {
          _immagineProfilo = optimizedFile;
          _immagineWeb = null;
        });
      }
    }
  }

  Future<void> _caricaImmagine(String userId) async {
    if (_immagineProfilo == null && _immagineWeb == null) return;

    final ref = FirebaseStorage.instance
        .ref()
        .child('immagini_profili')
        .child('$userId.jpg');

    if (kIsWeb && _immagineWeb != null) {
      await ref.putData(_immagineWeb!);
    } else if (_immagineProfilo != null) {
      await ref.putFile(_immagineProfilo!);
    }

    _urlImmagine = await ref.getDownloadURL();
  }

  Future<void> salvaProfilo() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    final username = usernameController.text.trim();

    try {
      final existing = await FirebaseFirestore.instance
          .collection('utenti')
          .where('username', isEqualTo: username)
          .get();

      final isTakenByAnother = existing.docs.any((doc) => doc.id != user.uid);

      if (isTakenByAnother) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('register_error_nickname_taken'.tr())),
        );
        setState(() => _isLoading = false);
        return;
      }

      await _caricaImmagine(user.uid);

      final prefs = await SharedPreferences.getInstance();
      bool isOver14 = prefs.getBool('conferma_eta_14') ?? false;

      await FirebaseFirestore.instance
          .collection('utenti')
          .doc(user.uid)
          .set({
        'username': username,
        'username_search': username.toLowerCase(),
        'fotoUrl': _urlImmagine ?? '',
        'profiloCreato': true,
        'isOver14': isOver14,
        'dataAccettazioneTermini': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainScreen()),
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('error_save_failed'.tr(args: [e.toString()]))),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryAzure = Colors.cyanAccent[400]!;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // 1. SFONDO IN ASSET
            Positioned.fill(
              child: Image.asset(
                'assets/sfondi/iscrizione.jpeg',
                fit: BoxFit.cover,
                alignment: const Alignment( 0.15, 1.3),
                errorBuilder: (context, error, stackTrace) => Container(color: Colors.black),
              ),
            ),

            // 2. CONTENUTO SCORREVOLE
            Positioned.fill(
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: screenHeight - MediaQuery.of(context).padding.top),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 35),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            SizedBox(height: screenHeight * 0.30),

                            // GLOW PANEL - COMPLETAMENTE TRASPARENTE CON SOLO BAGLIORE
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                              decoration: BoxDecoration(
                                color: Colors.transparent, // TRASPARENZA TOTALE
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: primaryAzure.withOpacity(0.4), // Bordo azzurro luminoso
                                  width: 1.2
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryAzure.withOpacity(0.3), // Aura Glow
                                    blurRadius: 60,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Titolo Gold
                                  ShaderMask(
                                    shaderCallback: (bounds) => const LinearGradient(
                                      colors: [Color(0xFFFFD700), Color(0xFFFFFACD), Color(0xFFDAA520)],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ).createShader(bounds),
                                    child: Text(
                                      'register_profile_title'.tr(),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.1,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 25),

                                  // FOTO PROFILO
                                  GestureDetector(
                                    onTap: _scegliImmagine,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white.withOpacity(0.8), width: 2),
                                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20)],
                                          ),
                                          child: CircleAvatar(
                                            radius: 60,
                                            backgroundColor: Colors.white.withOpacity(0.02),
                                            backgroundImage: _immagineProfilo != null
                                                ? FileImage(_immagineProfilo!)
                                                : (kIsWeb && _immagineWeb != null ? MemoryImage(_immagineWeb!) : null) as ImageProvider?,
                                            child: (_immagineProfilo == null && _immagineWeb == null)
                                                ? Icon(Icons.add_a_photo_rounded, size: 40, color: Colors.white.withOpacity(0.5))
                                                : null,
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
                                            child: Icon(Icons.edit, size: 16, color: primaryAzure.withBlue(150)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 30),

                                  // NICKNAME - STRONG STYLE (MASSIMA VISIBILITÀ)
                                  TextFormField(
                                    controller: usernameController,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.person_pin_rounded, color: primaryAzure.withBlue(150), size: 24),
                                      hintText: 'register_nickname_hint'.tr(),
                                      hintStyle: const TextStyle(color: Colors.black54, fontSize: 14),
                                      filled: true,
                                      fillColor: Colors.white.withOpacity(0.95), // QUASI SOLIDO PER FARLO RISALTARE
                                      contentPadding: const EdgeInsets.symmetric(vertical: 18),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: BorderSide(color: primaryAzure, width: 1.5),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: BorderSide(color: primaryAzure.withBlue(200), width: 2.0),
                                      ),
                                      errorStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                                    ),
                                    validator: (value) =>
                                        value == null || value.isEmpty ? 'register_error_nickname_empty'.tr() : null,
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 40),

                            // PULSANTE COMPLETA
                            Container(
                              width: 200,
                              height: 52,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                gradient: LinearGradient(colors: [primaryAzure, primaryAzure.withBlue(255)]),
                                boxShadow: [BoxShadow(color: primaryAzure.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
                              ),
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : salvaProfilo,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                ),
                                child: _isLoading 
                                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                                  : Text(
                                      'register_btn_complete'.tr().toUpperCase(), 
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.black)
                                    ),
                              ),
                            ),
                            SizedBox(height: keyboardHeight > 0 ? keyboardHeight + 20 : 60),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
