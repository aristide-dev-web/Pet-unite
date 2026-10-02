import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petping/maps/build_maps.dart';
import 'package:easy_localization/easy_localization.dart';

class AddLostAnimalScreen extends StatefulWidget {
  const AddLostAnimalScreen({super.key});

  @override
  State<AddLostAnimalScreen> createState() => _AddLostAnimalScreenState();
}

class _AddLostAnimalScreenState extends State<AddLostAnimalScreen> {
  final _formKey = GlobalKey<FormState>();
  double? _latitudine;
  double? _longitudine;

  final nameController = TextEditingController();
  final breedController = TextEditingController();
  final primaryColorController = TextEditingController();
  final secondaryColorController = TextEditingController();
  final tertiaryColorController = TextEditingController();
  final ageController = TextEditingController();
  final tailController = TextEditingController();
  final microchipController = TextEditingController();
  final locationController = TextEditingController();
  final dateController = TextEditingController();
  final viaController = TextEditingController();
  final cittaController = TextEditingController();
  final regioneController = TextEditingController();
  final rewardController = TextEditingController();
  final notesController = TextEditingController();

  Map<String, double>? coords;

  String? species;
  File? _selectedImage;
  bool _uploading = false;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final ref = FirebaseStorage.instance.ref().child(
      'lost_animals/$fileName.jpg',
    );
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  Future<Map<String, double>?> _getCoordinatesFromAddress(
    String address,
  ) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        return {'lat': loc.latitude, 'lng': loc.longitude};
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
    }
    return null;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _uploading = true);

      final user = FirebaseAuth.instance.currentUser;

      final userDoc = await FirebaseFirestore.instance
          .collection('utenti')
          .doc(user!.uid)
          .get();
      final userData = userDoc.data();

      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _uploadImage(_selectedImage!);
      }

      final coords = await _getCoordinatesFromAddress(locationController.text);

      final data = {
        'nome': nameController.text,
        'specie': species,
        'razza': breedController.text,
        'colore_dominante': primaryColorController.text,
        'colore_secondario': secondaryColorController.text,
        'colore_terziario': tertiaryColorController.text,
        'età': ageController.text,
        'coda': tailController.text,
        'microchip': microchipController.text,
        'zona': locationController.text,
        'via': viaController.text,
        'città': cittaController.text,
        'regione': regioneController.text,
        'data_smarrimento': dateController.text,
        'ricompensa': rewardController.text,
        'note': notesController.text,
        'immagine': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': user.uid,
        if (coords != null) 'lat': coords['lat'],
        if (coords != null) 'lng': coords['lng'],
        'proprietario_id': user.uid,
        'proprietario_username': userData?['username'] ?? '',
        'proprietario_posts': List<String>.from(userData?['publicPosts'] ?? []),
        'proprietario_data': userData?['publicData'] ?? {},
      };
      if (_latitudine != null && _longitudine != null) {
        data['latitude'] = _latitudine;
        data['longitude'] = _longitudine;
      }

      await FirebaseFirestore.instance.collection('animali_smarriti').add(data);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('sos_report_success'.tr())),
        );
        Navigator.pop(context);
      }

      setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('sos_report_title'.tr())),
      body: _uploading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'adozione_add_photo_label'.tr(),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 180,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                          image: _selectedImage != null
                              ? DecorationImage(
                                  image: FileImage(_selectedImage!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _selectedImage == null
                            ? Center(
                                child: Text('adozione_add_photo_hint'.tr()),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),

                    const SizedBox(height: 16),
                    MappaAnimale(
                      latitudine: _latitudine ?? 45.0,
                      longitudine: _longitudine ?? 9.0,
                      onCoordinateChanged: (lat, lng) {
                        setState(() {
                          _latitudine = lat;
                          _longitudine = lng;
                        });
                      },
                      onIndirizzoSelezionato: (via, citta, regione) {
                        viaController.text = via;
                        cittaController.text = citta;
                        regioneController.text = regione;
                        locationController.text = '$via, $citta, $regione';
                      },
                    ),

                    if (_latitudine != null && _longitudine != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'sos_pos_detected'.tr(args: [_latitudine.toString(), _longitudine.toString()]),
                          style: const TextStyle(color: Colors.green),
                        ),
                      ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'pet_label_name'.tr()),
                      validator: (value) =>
                          value!.isEmpty ? 'error_required'.tr() : null,
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: species,
                      items: [
                        DropdownMenuItem(value: 'Cane', child: Text('pet_type_dog'.tr())),
                        DropdownMenuItem(value: 'Gatto', child: Text('pet_type_cat'.tr())),
                        DropdownMenuItem(value: 'Altro', child: Text('pet_type_other'.tr())),
                      ],
                      onChanged: (value) => setState(() => species = value),
                      decoration: InputDecoration(labelText: 'pet_label_type'.tr()),
                      validator: (value) =>
                          value == null ? 'adozione_add_species_error'.tr() : null,
                    ),
                    TextFormField(
                      controller: breedController,
                      decoration: InputDecoration(labelText: 'pet_label_breed'.tr()),
                    ),
                    TextFormField(
                      controller: primaryColorController,
                      decoration: InputDecoration(
                        labelText: 'pet_label_color_primary'.tr(),
                      ),
                    ),
                    TextFormField(
                      controller: secondaryColorController,
                      decoration: InputDecoration(
                        labelText: 'pet_label_color_secondary'.tr(),
                      ),
                    ),
                    TextFormField(
                      controller: tertiaryColorController,
                      decoration: InputDecoration(
                        labelText: 'pet_label_color_tertiary'.tr(),
                      ),
                    ),
                    TextFormField(
                      controller: ageController,
                      decoration: InputDecoration(labelText: 'pet_label_current_age'.tr()),
                    ),
                    TextFormField(
                      controller: tailController,
                      decoration: InputDecoration(labelText: 'sos_detail_tail'.tr()),
                    ),
                    TextFormField(
                      controller: microchipController,
                      decoration: InputDecoration(labelText: 'pet_label_microchip'.tr()),
                    ),
                    TextFormField(
                      controller: viaController,
                      decoration: InputDecoration(labelText: 'profile_label_address'.tr()),
                    ),
                    TextFormField(
                      controller: cittaController,
                      decoration: InputDecoration(labelText: 'profile_label_city'.tr()),
                    ),
                    TextFormField(
                      controller: regioneController,
                      decoration: InputDecoration(labelText: 'profile_label_region'.tr()),
                    ),
                    TextFormField(
                      controller: dateController,
                      decoration: InputDecoration(labelText: 'sos_detail_event_date'.tr()),
                      validator: (value) =>
                          value!.isEmpty ? 'error_required'.tr() : null,
                    ),
                    TextFormField(
                      controller: rewardController,
                      decoration: InputDecoration(
                        labelText: 'sos_add_label_reward'.tr(),
                      ),
                    ),
                    TextFormField(
                      controller: notesController,
                      decoration: InputDecoration(
                        labelText: 'pet_label_notes'.tr(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _submitForm,
                        icon: const Icon(Icons.check),
                        label: Text('btn_save'.tr()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
