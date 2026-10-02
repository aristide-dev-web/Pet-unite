import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'modello_memoria.dart';
import 'momenti_service.dart';
import 'package:easy_localization/easy_localization.dart';

class AggiungiMemoria extends StatefulWidget {
  final String animaleId;

  const AggiungiMemoria({super.key, required this.animaleId});

  @override
  _AggiungiMemoriaState createState() => _AggiungiMemoriaState();
}

class _AggiungiMemoriaState extends State<AggiungiMemoria> {
  final _formKey = GlobalKey<FormState>();
  final _titoloController = TextEditingController();
  final _descrizioneController = TextEditingController();
  String _categoria = 'Parco';
  File? _immagine;
  final picker = ImagePicker();
  final momentiService = MomentiService();

  Future<void> _scegliImmagine() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _immagine = File(picked.path);
      });
    }
  }

  Future<void> _salvaMemoria() async {
    if (_formKey.currentState!.validate() && _immagine != null) {
      final memoria = Memoria(
        titolo: _titoloController.text,
        descrizione: _descrizioneController.text,
        pathImmagine: '',
        categoria: _categoria,
        data: DateTime.now(),
        animaleId: widget.animaleId,
      );

      final bytes = await _immagine!.readAsBytes();
      await momentiService.salvaMemoria(memoria, bytes);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('pet_diary_add_memory_title'.tr())),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titoloController,
                decoration: InputDecoration(labelText: 'pet_diary_memory_title_label'.tr()),
                validator: (value) =>
                    value!.isEmpty ? 'pet_diary_memory_title_error'.tr() : null,
              ),
              TextFormField(
                controller: _descrizioneController,
                decoration: InputDecoration(labelText: 'pet_diary_memory_desc_label'.tr()),
                maxLines: 3,
              ),
              DropdownButtonFormField<String>(
                value: _categoria,
                items: [
                  DropdownMenuItem(value: 'Parco', child: Text('pet_diary_memory_cat_park'.tr())),
                  DropdownMenuItem(value: 'Spiaggia', child: Text('pet_diary_memory_cat_beach'.tr())),
                  DropdownMenuItem(value: 'Montagna', child: Text('pet_diary_memory_cat_mountain'.tr())),
                ],
                onChanged: (val) => setState(() => _categoria = val!),
                decoration: InputDecoration(labelText: 'pet_diary_memory_cat_label'.tr()),
              ),
              const SizedBox(height: 16),
              _immagine != null
                  ? Image.file(_immagine!, height: 200)
                  : TextButton.icon(
                      onPressed: _scegliImmagine,
                      icon: const Icon(Icons.photo),
                      label: Text('pet_diary_memory_choose_img'.tr()),
                    ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _salvaMemoria,
                icon: const Icon(Icons.save),
                label: Text('pet_diary_memory_save_btn'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
