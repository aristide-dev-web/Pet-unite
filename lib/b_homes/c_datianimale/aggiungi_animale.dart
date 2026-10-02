import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:petping/utils/selector/sesso_selector.dart';
import 'package:petping/utils/selector/data_selector.dart';
import 'package:petping/utils/image_optimizer.dart';

class AggiungiAnimale extends StatefulWidget {
  const AggiungiAnimale({super.key});

  @override
  State<AggiungiAnimale> createState() => _AggiungiAnimaleState();
}

class _AggiungiAnimaleState extends State<AggiungiAnimale> {
  final _formKey = GlobalKey<FormState>();

  final tipoController = TextEditingController();
  final razzaController = TextEditingController();
  final nomeController = TextEditingController();
  final sessoController = TextEditingController();
  final coloreDominanteController = TextEditingController();
  final coloreSecondarioController = TextEditingController();
  final coloreTerziarioController = TextEditingController();
  final dataNascitaController = TextEditingController();
  final pesoController = TextEditingController();
  final microchipController = TextEditingController();
  final vaccinazioniController = TextEditingController();
  final sterilizzatoController = TextEditingController();
  final noteController = TextEditingController();

  File? _immagine;
  String? _urlImmagine;

  Future<void> _scegliImmagine() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 90,
    );
    
    if (pickedFile != null) {
      // 🔥 OTTIMIZZAZIONE PIXEL (Ridimensiona a 512x512 e comprime)
      File optimizedFile = await ImageOptimizer.optimize(
        file: File(pickedFile.path),
        maxWidth: 512,
        quality: 85,
      );

      setState(() {
        _immagine = optimizedFile;
      });
    }
  }

  Future<void> _caricaImmagine(String animaleId) async {
    if (_immagine == null) return;
    final ref = FirebaseStorage.instance
        .ref()
        .child('foto_animali')
        .child('$animaleId.jpg');
    await ref.putFile(_immagine!);
    _urlImmagine = await ref.getDownloadURL();
  }

  Future<void> _salvaAnimale() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || !_formKey.currentState!.validate()) return;

    try {
      final nome = nomeController.text.trim();
      
      final docRef = await FirebaseFirestore.instance.collection('animali').add({
        'tipo': tipoController.text.trim(),
        'razza': razzaController.text.trim(),
        'nome': nome,
        'sesso': sessoController.text.trim(),
        'coloreDominante': coloreDominanteController.text.trim(),
        'coloreSecondario': coloreSecondarioController.text.trim(),
        'coloreTerziario': coloreTerziarioController.text.trim(),
        'dataNascita': dataNascitaController.text.trim(),
        'peso': pesoController.text.trim(),
        'microchip': microchipController.text.trim(),
        'vaccinazioni': vaccinazioniController.text.trim(),
        'sterilizzato': sterilizzatoController.text.trim(),
        'note': noteController.text.trim(),
        'fotoUrl': '',
        'userId': user.uid,
        'createdAt': Timestamp.now(),
      });

      // SALVATAGGIO IN HIVE
      final box = await Hive.openBox('animali_cache');
      List<dynamic> lista = box.get('lista_animali', defaultValue: []);
      List<Map<String, String>> nuovaLista = List<Map<String, String>>.from(
        lista.map((e) => Map<String, String>.from(e))
      );
      
      nuovaLista.add({
        'id': docRef.id,
        'nome': nome,
      });
      
      await box.put('lista_animali', nuovaLista);

      await _caricaImmagine(docRef.id);
      if (_urlImmagine != null) {
        await docRef.update({'fotoUrl': _urlImmagine});
      }

      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('error_save_failed'.tr(args: [e.toString()]))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('add_pet_title'.tr())),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: GestureDetector(
                  onTap: _scegliImmagine,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: _immagine != null ? FileImage(_immagine!) : null,
                    child: _immagine == null
                        ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildField(tipoController, 'pet_label_type'.tr(), true),
              _buildField(razzaController, 'pet_label_breed'.tr(), true),
              _buildField(nomeController, 'pet_label_name'.tr(), true),

              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SessoSelector(
                  selected: sessoController.text,
                  onChanged: (val) {
                    setState(() {
                      sessoController.text = val;
                    });
                  },
                ),
              ),

              _buildField(coloreDominanteController, 'pet_label_color_primary'.tr(), true),
              _buildField(coloreSecondarioController, 'pet_label_color_secondary'.tr(), false),
              _buildField(coloreTerziarioController, 'pet_label_color_tertiary'.tr(), false),

              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DataSelector(
                  label: 'profile_label_birthdate_full'.tr(),
                  selectedDate: dataNascitaController.text,
                  onChanged: (val) {
                    setState(() {
                      dataNascitaController.text = val;
                    });
                  },
                ),
              ),

              _buildField(pesoController, 'pet_label_weight'.tr(), false),
              _buildField(microchipController, 'pet_label_microchip'.tr(), false),
              _buildField(vaccinazioniController, 'pet_label_vaccinations'.tr(), false),
              _buildField(sterilizzatoController, 'pet_label_sterilized'.tr(), false),
              _buildField(noteController, 'pet_label_notes'.tr(), false),

              const SizedBox(height: 30),
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _salvaAnimale,
                  child: Text('btn_save'.tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, bool obbligatorio) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        validator: obbligatorio
            ? (value) => value == null || value.isEmpty ? 'error_required'.tr() : null
            : null,
      ),
    );
  }
}
