import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';

class PassaportoSelector extends StatefulWidget {
  final TextEditingController statoController;   // Sì / No
  final TextEditingController numeroController;  // Numero passaporto
  final TextEditingController noteController;    // Note veterinarie
  final List<File> fotoSelezionate;              // Lista di foto passata dall'esterno
  final Function(List<File>) onFotoAggiunte;     // Callback per aggiungere più foto
  final Function(File) onFotoRimossa;            // Callback per rimuovere una foto

  const PassaportoSelector({
    super.key,
    required this.statoController,
    required this.numeroController,
    required this.noteController,
    required this.fotoSelezionate,
    required this.onFotoAggiunte,
    required this.onFotoRimossa,
  });

  @override
  State<PassaportoSelector> createState() => _PassaportoSelectorState();
}

class _PassaportoSelectorState extends State<PassaportoSelector> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
    bool continua = true;

    while (continua && widget.fotoSelezionate.length < 5) {
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('passport_upload_title'.tr()),
          content: Text('passport_upload_content'.tr(args: [widget.fotoSelezionate.length.toString()])),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.camera),
              child: Text('passport_camera'.tr()),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.gallery),
              child: Text('passport_gallery'.tr()),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text('btn_cancel'.tr(), style: const TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      );

      if (source == null) break;

      List<File> nuoveFoto = [];

      if (source == ImageSource.camera) {
        final XFile? img = await _picker.pickImage(source: ImageSource.camera);
        if (img != null) nuoveFoto.add(File(img.path));
      } else {
        final List<XFile> imgs = await _picker.pickMultiImage();
        if (imgs.isNotEmpty) {
          nuoveFoto = imgs.map((x) => File(x.path)).toList();
        }
      }

      if (nuoveFoto.isEmpty) break;

      // Calcola spazio residuo
      int spazioResiduo = 5 - widget.fotoSelezionate.length;
      if (nuoveFoto.length > spazioResiduo) {
        nuoveFoto = nuoveFoto.sublist(0, spazioResiduo);
      }

      // Notifica il padre
      widget.onFotoAggiunte(nuoveFoto);
      
      // Forza aggiornamento locale per mostrare le anteprime nel wrap
      setState(() {});

      // Chiedi se vuole continuare (solo se c'è ancora spazio)
      if (widget.fotoSelezionate.length < 5) {
        continua = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('passport_added_title'.tr()),
            content: Text('passport_added_msg'.tr()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('passport_added_no'.tr()),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('passport_added_yes'.tr()),
              ),
            ],
          ),
        ) ?? false;
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('passport_limit_reached'.tr()))
          );
        }
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'passport_emergency_desc'.tr(),
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.white70),
            ),
          ),
        ),

        DropdownButtonFormField<String>(
          value: widget.statoController.text.isEmpty ? null : widget.statoController.text,
          decoration: InputDecoration(
            hintText: 'profile_select_placeholder'.tr(),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: [
            DropdownMenuItem(value: "Sì", child: Text('yes'.tr())),
            DropdownMenuItem(value: "No", child: Text('no'.tr())),
          ],
          onChanged: (value) {
            widget.statoController.text = value ?? '';
            if (value == "No") {
              widget.numeroController.clear();
              widget.noteController.clear();
              // Rimuoviamo tutte le foto se seleziona No
              for (var f in List.from(widget.fotoSelezionate)) {
                widget.onFotoRimossa(f);
              }
            }
            setState(() {});
          },
        ),

        const SizedBox(height: 12),

        if (widget.statoController.text == "Sì") ...[
          TextFormField(
            controller: widget.numeroController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'passport_number_hint'.tr(),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'passport_photos_label'.tr(),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          const SizedBox(height: 6),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white30),
                    color: Colors.white.withOpacity(0.05),
                  ),
                  child: const Icon(Icons.add_a_photo, size: 25, color: Colors.white70),
                ),
              ),

              ...widget.fotoSelezionate.map((file) {
                return Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(image: FileImage(file), fit: BoxFit.cover),
                      ),
                    ),
                    Positioned(
                      right: -5,
                      top: -5,
                      child: GestureDetector(
                        onTap: () {
                          widget.onFotoRimossa(file);
                          setState(() {});
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          child: const Icon(Icons.close, color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ],
          ),

          const SizedBox(height: 12),

          TextFormField(
            controller: widget.noteController,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'passport_vet_notes_hint'.tr(),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ],
    );
  }
}