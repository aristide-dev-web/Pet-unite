import 'dart:io';
import 'package:flutter/material.dart';
import 'package:petping/utils/image_picker_helper.dart'; // ✅ Importato Helper
import 'package:petping/d_tab_sds/d_smarriti/addpet/lost_animal_data.dart';
import 'package:petping/d_tab_sds/d_smarriti/addpet/addanimalsmar/add_due.dart'; 
import 'package:petping/d_tab_sds/d_smarriti/addpet/addanimalsmar/front/front_uno.dart'; 
import 'package:petping/d_tab_sds/a_tab/fix_photo.dart';
import 'package:easy_localization/easy_localization.dart';

class AddUno extends StatefulWidget {
  const AddUno({super.key});

  @override
  State<AddUno> createState() => _AddUnoState();
}

class _AddUnoState extends State<AddUno> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final razzaController = TextEditingController();

  String? selectedSpecie;
  String? selectedSesso;

  List<File> _selectedImages = [];

  static const Color creamLight = Color(0xFFFFFDF7);
  static const Color creamDeep = Color(0xFFFFF4E1);
  static const Color beigeWarm = Color(0xFFF5E6CC);
  static const Color darkBrown = Color(0xFF4E342E);

  Future<void> _pickImages() async {
    if (_selectedImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('passport_limit_reached'.tr())),
      );
      return;
    }
    
    // ✅ Usiamo l'Helper con compressione integrata invece di ImagePicker() diretto
    final List<File> pickedList = await ImagePickerHelper.pickMultiImagesFromGallery();
    
    if (pickedList.isNotEmpty) {
      List<File> newFiles = [];
      for (var file in pickedList) {
        if (_selectedImages.length + newFiles.length < 5) {
          newFiles.add(file);
        }
      }
      
      if (newFiles.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(newFiles);
        });
        _openFixPhoto();
      }
    }
  }

  Future<void> _openFixPhoto() async {
    if (_selectedImages.isEmpty) return;
    
    final List<File>? fixedImages = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FixPhotoScreen(images: _selectedImages),
      ),
    );

    if (fixedImages != null) {
      setState(() {
        _selectedImages = fixedImages;
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _goToNextStep() {
    if (_formKey.currentState!.validate()) {
      final data = LostAnimalData(
        nome: nameController.text,
        tipo: selectedSpecie,
        razza: razzaController.text,
        sesso: selectedSesso,
        immagini: _selectedImages,
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddDue(data: data)),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    razzaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: darkBrown),
        centerTitle: true,
        title: const Text(
          'STEP 1/3',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: darkBrown,
            letterSpacing: 1.5,
            fontSize: 18,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.3, 0.7, 1.0],
            colors: [creamLight, creamDeep, creamDeep, beigeWarm],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 40, left: 20, right: 20, bottom: 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.4)),
                ),
                child: AddUnoFront(
                  formKey: _formKey,
                  nameController: nameController,
                  razzaController: razzaController,
                  selectedSpecie: selectedSpecie,
                  onSpecieChanged: (value) => setState(() => selectedSpecie = value),
                  selectedSesso: selectedSesso,
                  onSessoChanged: (value) => setState(() => selectedSesso = value),
                  selectedImages: _selectedImages,
                  onPickImages: _pickImages,
                  onRemoveImage: _removeImage,
                  onNextStep: _goToNextStep,
                  onFixImages: _openFixPhoto,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
