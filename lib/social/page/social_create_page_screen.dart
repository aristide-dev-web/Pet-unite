import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petping/social/page/social_page_service.dart';
import 'package:petping/style/pet_style.dart';
import 'package:easy_localization/easy_localization.dart';

class SocialCreatePageScreen extends StatefulWidget {
  const SocialCreatePageScreen({super.key});

  @override
  State<SocialCreatePageScreen> createState() => _SocialCreatePageScreenState();
}

class _SocialCreatePageScreenState extends State<SocialCreatePageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _bioController = TextEditingController();
  String _categoriaSelezionata = 'VIP Pet';
  File? _fotoProfilo;
  File? _fotoCopertina;
  bool _isLoading = false;

  final List<String> _categorie = [
    'VIP Pet',
    'Clinica Veterinaria',
    'Associazione / Rescue',
    'Negozio per Animali',
    'Altro'
  ];

  String _getCategoryTranslationKey(String cat) {
    switch (cat) {
      case 'VIP Pet': return 'social_page_cat_vip';
      case 'Clinica Veterinaria': return 'social_page_cat_vet';
      case 'Associazione / Rescue': return 'social_page_cat_rescue';
      case 'Negozio per Animali': return 'social_page_cat_shop';
      case 'Altro': return 'social_page_cat_other';
      default: return 'social_page_cat_other';
    }
  }

  Future<void> _pickImage(bool isProfilo) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) {
      setState(() {
        if (isProfilo) _fotoProfilo = File(image.path);
        else _fotoCopertina = File(image.path);
      });
    }
  }

  Future<void> _creaPagina() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await SocialPageService().createPage(
        nome: _nomeController.text.trim(),
        categoria: _categoriaSelezionata,
        bio: _bioController.text.trim(),
        fotoProfilo: _fotoProfilo,
        fotoCopertina: _fotoCopertina,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('social_page_created_success'.tr())));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('snack_error_msg'.tr(args: [e.toString()]))));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: Text('social_page_create_title'.tr(), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('social_page_create_subtitle'.tr(), style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 30),
                  
                  // FOTO COPERTINA
                  GestureDetector(
                    onTap: () => _pickImage(false),
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: PetStyle.lightGrey,
                        borderRadius: BorderRadius.circular(15),
                        image: _fotoCopertina != null ? DecorationImage(image: FileImage(_fotoCopertina!), fit: BoxFit.cover) : null,
                      ),
                      child: _fotoCopertina == null ? const Icon(Icons.add_a_photo_outlined, color: Colors.grey) : null,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // NOME PAGINA
                  TextFormField(
                    controller: _nomeController,
                    decoration: InputDecoration(
                      labelText: 'social_page_name_label'.tr(),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      prefixIcon: const Icon(Icons.badge_outlined),
                    ),
                    validator: (v) => v!.isEmpty ? 'social_page_name_error'.tr() : null,
                  ),
                  const SizedBox(height: 20),

                  // CATEGORIA
                  DropdownButtonFormField<String>(
                    value: _categoriaSelezionata,
                    decoration: InputDecoration(
                      labelText: 'social_page_category_label'.tr(),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    items: _categorie.map((c) => DropdownMenuItem(value: c, child: Text(_getCategoryTranslationKey(c).tr()))).toList(),
                    onChanged: (v) => setState(() => _categoriaSelezionata = v!),
                  ),
                  const SizedBox(height: 20),

                  // BIO
                  TextFormField(
                    controller: _bioController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'social_page_bio_label'.tr(),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PetStyle.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: _creaPagina,
                      child: Text('social_page_create_btn'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
