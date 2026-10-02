import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petping/d_tab_sds/d_smarriti/addpet/lost_animal_data.dart';
import 'package:petping/d_tab_sds/d_smarriti/addpet/addanimalsmar/add_due.dart';
import 'package:petping/d_tab_sds/d_smarriti/addpet/addanimalsmar/front/front_uno.dart';
import 'package:petping/d_tab_sds/a_tab/fix_photo.dart';
import 'package:petping/utils/image_optimizer.dart'; 
import 'package:easy_localization/easy_localization.dart';

class AddUno extends StatefulWidget {
  final LostAnimalData? prefilledData;

  const AddUno({super.key, this.prefilledData});

  @override
  State<AddUno> createState() => _AddUnoState();
}

class _AddUnoState extends State<AddUno> {
  final _formKey = GlobalKey<FormState>();
  late LostAnimalData _data;
  final ScrollController _scrollController = ScrollController();

  final nameController = TextEditingController();
  final razzaController = TextEditingController();
  String? selectedSpecie;
  String? selectedSesso;
  List<File> _selectedImages = [];
  bool _isCompressing = false; 

  static const Color darkBrown = Color(0xFF4E342E);

  @override
  void initState() {
    super.initState();
    _data = widget.prefilledData ?? LostAnimalData();
    
    nameController.text = _data.nome ?? '';
    razzaController.text = _data.razza ?? '';
    selectedSpecie = _data.tipo; 
    selectedSesso = _data.sesso;
    _selectedImages = _data.immagini ?? [];
  }

  Future<void> _pickImages() async {
    if (_selectedImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("sos_add_gallery_sub".tr())));
      return;
    }
    final List<XFile> pickedList = await ImagePicker().pickMultiImage();
    if (pickedList.isNotEmpty) {
      setState(() => _isCompressing = true);
      
      List<File> newFiles = [];
      try {
        for (var picked in pickedList) {
          if (_selectedImages.length + newFiles.length < 5) {
            File optimized = await ImageOptimizer.optimize(
              file: File(picked.path),
              quality: 75,
              maxWidth: 1080,
            );
            newFiles.add(optimized);
          }
        }
        
        if (newFiles.isNotEmpty) {
          setState(() {
            _selectedImages.addAll(newFiles);
          });
          _openFixPhoto();
        }
      } catch (e) {
        debugPrint("Errore compressione: $e");
      } finally {
        setState(() => _isCompressing = false);
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

  void _removeImage(int index) => setState(() => _selectedImages.removeAt(index));

  void _goToNextStep() {
    if (_formKey.currentState!.validate()) {
      _data.nome = nameController.text;
      _data.tipo = selectedSpecie; 
      _data.razza = razzaController.text;
      _data.sesso = selectedSesso;
      _data.immagini = _selectedImages;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddDue(data: _data)),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    razzaController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          extendBodyBehindAppBar: true,
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: darkBrown),
            centerTitle: true,
            title: Text('ps_reg_step_1_of_3'.tr(), style: const TextStyle(fontWeight: FontWeight.w900, color: darkBrown, letterSpacing: 1.5, fontSize: 18)),
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFFDF7), Color(0xFFFFF4E1), Color(0xFFF5E6CC)],
              ),
            ),
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.only(top: kToolbarHeight + 40, left: 20, right: 20, bottom: 400),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), borderRadius: BorderRadius.circular(30)),
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
        ),
        if (_isCompressing)
          Container(
            color: Colors.black26,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: Color(0xFFE67E22)),
                  const SizedBox(height: 16),
                  Text("snack_locating".tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
