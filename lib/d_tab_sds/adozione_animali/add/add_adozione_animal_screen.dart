import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:easy_localization/easy_localization.dart';

class AddAdozioneAnimalScreen extends StatefulWidget {
  const AddAdozioneAnimalScreen({super.key});

  @override
  State<AddAdozioneAnimalScreen> createState() =>
      _AddAdozioneAnimalScreenState();
}

class _AddAdozioneAnimalScreenState extends State<AddAdozioneAnimalScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final breedController = TextEditingController();
  final ageController = TextEditingController();
  final locationController = TextEditingController();
  final notesController = TextEditingController();
  final primaryColorController = TextEditingController();
  final secondaryColorController = TextEditingController();
  final tertiaryColorController = TextEditingController();

  String? species;
  bool vaccinated = false;
  bool sterilized = false;
  bool hasMicrochip = false;
  File? _selectedImage;
  bool _uploading = false;

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
      debugPrint('Errore durante la geocodifica: $e');
    }
    return null;
  }

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
      'adozione_animali/$fileName.jpg',
    );
    final uploadTask = await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _uploading = true);

      final user = FirebaseAuth.instance.currentUser; 

      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _uploadImage(_selectedImage!);
      }

      final coords = await _getCoordinatesFromAddress(locationController.text);

      final data = {
        'nome': nameController.text,
        'specie': species,
        'razza': breedController.text,
        'età': ageController.text,
        'vaccinato': vaccinated,
        'sterilizzato': sterilized,
        'microchip': hasMicrochip,
        'colore_dominante': primaryColorController.text,
        'colore_secondario': secondaryColorController.text,
        'colore_terziario': tertiaryColorController.text,
        'zona': locationController.text,
        'note': notesController.text,
        'immagine': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': user?.uid, 
        if (coords != null) 'lat': coords['lat'],
        if (coords != null) 'lng': coords['lng'],
      };

      await FirebaseFirestore.instance.collection('animali_adozione').add(data);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('snack_adozione_added'.tr()),
          ),
        );
        Navigator.pop(context);
      }

      setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('adozione_add_title'.tr())),
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
                                child: Text(
                                  'adozione_add_photo_hint'.tr(),
                                ),
                              )
                            : null,
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
                      controller: locationController,
                      decoration: InputDecoration(labelText: 'profile_label_neighborhood'.tr()),
                      validator: (value) =>
                          value!.isEmpty ? 'error_required'.tr() : null,
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: Text('pet_label_vaccinated'.tr()),
                      value: vaccinated,
                      onChanged: (val) => setState(() => vaccinated = val),
                    ),
                    SwitchListTile(
                      title: Text('pet_label_sterilized'.tr()),
                      value: sterilized,
                      onChanged: (val) => setState(() => sterilized = val),
                    ),
                    SwitchListTile(
                      title: Text('pet_label_microchip'.tr()),
                      value: hasMicrochip,
                      onChanged: (val) => setState(() => hasMicrochip = val),
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
                        label: Text('adozione_add_btn'.tr()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
