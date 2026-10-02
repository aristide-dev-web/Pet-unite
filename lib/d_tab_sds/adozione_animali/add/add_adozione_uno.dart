import 'dart:io';
import 'package:flutter/material.dart';
import 'package:petping/utils/image_picker_helper.dart';
import 'package:petping/d_tab_sds/adozione_animali/adozione_animal_data.dart';
import 'package:petping/d_tab_sds/adozione_animali/add/add_adozione_due.dart';
import 'package:petping/d_tab_sds/adozione_animali/front/front_add_adozione_uno.dart';
import 'package:petping/d_tab_sds/a_tab/fix_photo.dart';
import 'package:easy_localization/easy_localization.dart';

class AddAdozioneUno extends StatefulWidget {
  const AddAdozioneUno({super.key});

  @override
  State<AddAdozioneUno> createState() => _AddAdozioneUnoState();
}

class _AddAdozioneUnoState extends State<AddAdozioneUno> {
  final _formKey = GlobalKey<FormState>();
  final AdozioneAnimalData _data = AdozioneAnimalData();
  
  final nameController = TextEditingController();
  final razzaController = TextEditingController();
  
  int? selectedDay;
  int? selectedMonth;
  int? selectedYear;

  String? selectedSpecie;
  String? selectedSesso;
  List<File> _selectedImages = [];

  static const Color greenHope = Color(0xFF27AE60);

  Future<void> _pickImages() async {
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
    final List<File>? fixed = await Navigator.push(
      context, 
      MaterialPageRoute(builder: (_) => FixPhotoScreen(images: _selectedImages, isCustodia: false))
    );
    if (fixed != null) setState(() => _selectedImages = fixed);
  }

  void _goToNext() {
    if (_formKey.currentState!.validate()) {
      _data.nome = nameController.text;
      _data.tipo = selectedSpecie;
      _data.razza = razzaController.text;
      
      if (selectedDay != null && selectedMonth != null && selectedYear != null) {
        _data.eta = '$selectedDay/$selectedMonth/$selectedYear';
      }
      
      _data.sesso = selectedSesso;
      _data.immagini = _selectedImages;

      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => AddAdozioneDue(data: _data),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeOutQuart;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(position: animation.drive(tween), child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
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
        title: Text('adozione_step_1'.tr(), style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2C3E50), fontSize: 16)),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity, height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, 
            end: Alignment.bottomCenter, 
            colors: [Color(0xFFE8F5E9), Color(0xFFF1F8E9)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 100, left: 20, right: 20),
          child: FrontAddAdozioneUno(
            formKey: _formKey,
            nameController: nameController,
            razzaController: razzaController,
            selectedDay: selectedDay,
            selectedMonth: selectedMonth,
            selectedYear: selectedYear,
            onDayChanged: (v) => setState(() => selectedDay = v),
            onMonthChanged: (v) => setState(() => selectedMonth = v),
            onYearChanged: (v) => setState(() => selectedYear = v),
            selectedSpecie: selectedSpecie,
            onSpecieChanged: (v) => setState(() => selectedSpecie = v),
            selectedSesso: selectedSesso,
            onSessoChanged: (v) => setState(() => selectedSesso = v),
            selectedImages: _selectedImages,
            onPickImages: _pickImages,
            onRemoveImage: (i) => setState(() => _selectedImages.removeAt(i)),
            onNext: _goToNext,
            onFixImages: _openFixPhoto,
          ),
        ),
      ),
    );
  }
}
