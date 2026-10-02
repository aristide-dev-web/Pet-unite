import 'dart:io';
import 'package:flutter/material.dart';
import 'package:petping/utils/image_picker_helper.dart'; // ✅ Importato Helper
import 'package:petping/d_tab_sds/custodia_animali/custodia_animal_data.dart';
import 'package:petping/d_tab_sds/custodia_animali/add_custodia_due.dart';
import 'package:petping/d_tab_sds/custodia_animali/front/front_add_custodia_uno.dart';
import 'package:petping/d_tab_sds/a_tab/fix_photo.dart';

class AddCustodiaUno extends StatefulWidget {
  final CustodiaAnimalData? prefilledData;
  const AddCustodiaUno({super.key, this.prefilledData});

  @override
  State<AddCustodiaUno> createState() => _AddCustodiaUnoState();
}

class _AddCustodiaUnoState extends State<AddCustodiaUno> {
  final _formKey = GlobalKey<FormState>();
  late CustodiaAnimalData _data;
  
  final nameController = TextEditingController();
  final razzaController = TextEditingController();
  String? selectedSpecie;
  String? selectedSesso;
  List<File> _selectedImages = [];

  static const Color blueSecurity = Color(0xFF2980B9);

  @override
  void initState() {
    super.initState();
    _data = widget.prefilledData ?? CustodiaAnimalData();
    nameController.text = _data.nome ?? '';
    razzaController.text = _data.razza ?? '';
    selectedSpecie = _data.tipo;
    selectedSesso = _data.sesso;
    _selectedImages = _data.immagini ?? [];
  }

  Future<void> _pickImages() async {
    if (_selectedImages.length >= 5) return;
    
    // ✅ Usiamo l'Helper con compressione integrata
    final List<File> pickedList = await ImagePickerHelper.pickMultiImagesFromGallery();
    
    if (pickedList.isNotEmpty) {
      setState(() {
        for (var file in pickedList) {
          if (_selectedImages.length < 5) _selectedImages.add(file);
        }
      });
      _openFixPhoto();
    }
  }

  Future<void> _openFixPhoto() async {
    if (_selectedImages.isEmpty) return;
    // PASSIAMO isCustodia: true per avere lo stile blu e i testi corretti
    final List<File>? fixed = await Navigator.push(
      context, 
      MaterialPageRoute(builder: (_) => FixPhotoScreen(images: _selectedImages, isCustodia: true))
    );
    if (fixed != null) setState(() => _selectedImages = fixed);
  }

  void _removeImage(int index) => setState(() => _selectedImages.removeAt(index));

  void _goToNextStep() {
    if (_formKey.currentState!.validate()) {
      _data.nome = nameController.text;
      _data.tipo = selectedSpecie;
      _data.razza = razzaController.text;
      _data.sesso = selectedSesso;
      _data.immagini = _selectedImages;
      _data.isAnimalFound = true; 

      Navigator.push(context, MaterialPageRoute(builder: (context) => AddCustodiaDue(data: _data)));
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
        title: const Text('STEP 1/3 - TROVATO', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2C3E50), fontSize: 16)),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE3F2FD), Color(0xFFF5F9FF)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: kToolbarHeight + 40, left: 20, right: 20, bottom: 40),
          child: FrontAddCustodiaUno(
            formKey: _formKey,
            nameController: nameController,
            razzaController: razzaController,
            selectedSpecie: selectedSpecie,
            onSpecieChanged: (v) => setState(() => selectedSpecie = v),
            selectedSesso: selectedSesso,
            onSessoChanged: (v) => setState(() => selectedSesso = v),
            selectedImages: _selectedImages,
            onPickImages: _pickImages,
            onRemoveImage: _removeImage,
            onNextStep: _goToNextStep,
          ),
        ),
      ),
    );
  }
}
