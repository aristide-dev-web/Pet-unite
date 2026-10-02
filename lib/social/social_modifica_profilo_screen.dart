import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petping/utils/firebase_storage_helper.dart';
import 'package:easy_localization/easy_localization.dart';

class SocialModificaProfiloScreen extends StatefulWidget {
  const SocialModificaProfiloScreen({super.key});

  @override
  State<SocialModificaProfiloScreen> createState() => _SocialModificaProfiloScreenState();
}

class _SocialModificaProfiloScreenState extends State<SocialModificaProfiloScreen> {
  final _bioController = TextEditingController();
  bool _isLoading = true;
  File? _immagineSelezionata;
  String? _immagineAttuale;

  @override
  void initState() {
    super.initState();
    _caricaDatiProfilo();
  }

  Future<void> _caricaDatiProfilo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection('utenti').doc(user.uid).get();
    if (doc.exists) {
      final dati = doc.data()!;
      _bioController.text = dati['bio'] ?? '';
      _immagineAttuale = dati['immagineProfilo'];
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _scegliImmagine() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (picked != null) {
      setState(() {
        _immagineSelezionata = File(picked.path);
      });
    }
  }

  Future<void> _salvaModifiche() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String? nuovaUrl = _immagineAttuale;

    if (_immagineSelezionata != null) {
      nuovaUrl = await FirebaseStorageHelper.uploadAnimalProfileImage(
        _immagineSelezionata!,
        user.uid,
      );
    }

    await FirebaseFirestore.instance.collection('utenti').doc(user.uid).update({
      'bio': _bioController.text.trim(),
      'immagineProfilo': nuovaUrl,
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('profile_edit_success'.tr())),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('profile_edit_title'.tr())),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _scegliImmagine,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _immagineSelezionata != null
                      ? FileImage(_immagineSelezionata!)
                      : (_immagineAttuale != null
                      ? NetworkImage(_immagineAttuale!)
                      : const AssetImage('assets/images/avatar_placeholder.png')) as ImageProvider,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black54,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'profile_edit_bio_label'.tr(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bioController,
              maxLines: 5,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: 'profile_edit_bio_hint'.tr(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _salvaModifiche,
              icon: const Icon(Icons.save),
              label: Text('profile_edit_save_btn'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}