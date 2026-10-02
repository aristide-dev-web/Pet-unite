import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petping/a_main/memory/main_login.dart';
import 'package:petping/a_registrazione/c/utente_register.dart';
import 'package:petping/a_main/tab/main_screen.dart';
import 'package:petping/a_registrazione/a_alenguage/language_settings.dart';
import 'package:petping/a_registrazione/a/age_confirmation.dart';
import 'package:petping/a_registrazione/a/consent_p_t.dart';
import 'package:petping/utils/notific_principal.dart';
import 'package:petping/b_homes/c_datianimale/diariopet/back_diario.dart';
import 'package:petping/utils/ban_service.dart';
import 'package:petping/a_main/banned_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<Widget> decidiSchermata() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 0. Controllo BAN (Sia per UID che per Token Dispositivo)
      if (await BanService.isBanned()) {
        return const BannedScreen();
      }

      // 1. Lingua
      final linguaSelezionata = prefs.getString('lingua_scelta');
      if (linguaSelezionata == null) return const LanguageSettings();

      // 1.5 Verifica Età
      final ageConfirmed = prefs.getBool('conferma_eta_14') ?? false;
      if (!ageConfirmed) return const AgeConfirmationScreen();

      // 2. Consensi
      final accettatoTermini = prefs.getBool('termini_accettati') ?? false;
      final accettatoPrivacy = prefs.getBool('privacy_accettata') ?? false;
      if (!accettatoTermini || !accettatoPrivacy) return const ConsentScreen();

      // 3. Login
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return const LoginScreen();

      // ✅ APP SBLOCCATA: Ripristino sincronizzazione e servizi
      sincronizzaAnimaliConHive(); 
      SocialNotificationService().startListening();

      // 4. Controllo Profilo Utente
      final doc = await FirebaseFirestore.instance.collection('utenti').doc(user.uid).get();
      final profiloCreato = doc.data()?['profiloCreato'] ?? false;
      if (!profiloCreato) return const UtenteRegisterScreen();

      await prefs.setString('user_email', user.email ?? '');

      // 5. Schermata Principale
      return const MainScreen();

    } catch (e) {
      return Scaffold(body: Center(child: Text('auth_init_error'.tr())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: decidiSchermata(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasData) {
          return snapshot.data!;
        } else {
          return Scaffold(body: Center(child: Text('auth_loading_error'.tr())));
        }
      },
    );
  }
}
