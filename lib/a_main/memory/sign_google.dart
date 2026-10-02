import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:petping/a_main/auth_gate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';

Future<void> signInWithGoogle(BuildContext context) async {
  try {
    // Aggiungiamo il clientId esplicito (Web Client ID da Firebase) per evitare Error 10
    final GoogleSignIn googleSignIn = GoogleSignIn(
      serverClientId: '569543725876-vpd21ejcrfph8jesh6hpu093aio76cb5.apps.googleusercontent.com',
    );
    
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) return;

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    final user = userCredential.user;

    if (user != null) {
      debugPrint('google_login_success'.tr(args: [user.email ?? '']));

      final userDoc = FirebaseFirestore.instance.collection('utenti').doc(user.uid);
      final docSnapshot = await userDoc.get();

      if (!docSnapshot.exists) {
        await userDoc.set({
          'email': user.email,
          'nome': user.displayName ?? 'google_user_default'.tr(),
          'profiloCreato': false, // Importante per la logica in AuthGate
          'foto': user.photoURL,
          'creatoIl': FieldValue.serverTimestamp(),
        });
      }

      // Reindirizziamo a AuthGate che deciderà se mostrare MainScreen o UtenteRegisterScreen
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthGate()),
        );
      }
    }
  } catch (e) {
    debugPrint('google_login_error'.tr(args: [e.toString()]));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('snack_error_msg'.tr(args: [e.toString()]))),
      );
    }
  }
}
