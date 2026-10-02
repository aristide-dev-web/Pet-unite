import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:easy_localization/easy_localization.dart';
import 'package:petping/utils/image_picker_helper.dart';
import 'a/esame_model.dart';
import 'a/esami_local_service.dart';

class AggiungiEsame extends StatefulWidget {
  final String animaleId;
  final List<String> filePaths;
  final bool isFromShare;

  const AggiungiEsame({
    super.key,
    required this.animaleId,
    required this.filePaths,
    this.isFromShare = false,
  });

  @override
  State<AggiungiEsame> createState() => _AggiungiEsameState();
}

class _AggiungiEsameState extends State<AggiungiEsame> {
  final titoloController = TextEditingController();
  final descrizioneController = TextEditingController();
  final valoreController = TextEditingController();
  final unitaController = TextEditingController();
  final rangeController = TextEditingController();

  String categoria = "Esami del sangue";
  List<File> fileSelezionati = [];
  bool staSalvando = false;

  @override
  void initState() {
    super.initState();
    if (widget.filePaths.isNotEmpty) {
      fileSelezionati = widget.filePaths.where((path) => path.isNotEmpty).map((path) => File(path)).toList();
    }
  }

  final categorie = [
    "Esami del sangue", "Esami urine", "Esami feci", "Radiografie",
    "Ecografie", "TAC / RMN", "Test allergie", "Test genetici",
    "Vaccinazioni", "Interventi", "Referti vari", "Documenti generici",
  ];

  String _getCategoryTranslationKey(String cat) {
    switch (cat) {
      case "Esami del sangue": return "vet_cat_blood";
      case "Esami urine": return "vet_cat_urine";
      case "Esami feci": return "vet_cat_feces";
      case "Radiografie": return "vet_cat_radiography";
      case "Ecografie": return "vet_cat_ultrasound";
      case "TAC / RMN": return "vet_cat_tac_mri";
      case "Test allergie": return "vet_cat_allergy";
      case "Test genetici": return "vet_cat_genetic";
      case "Vaccinazioni": return "vet_cat_vaccination";
      case "Interventi": return "vet_cat_surgery";
      case "Referti vari": return "vet_cat_reports";
      case "Documenti generici": return "vet_cat_generic";
      default: return "vet_cat_generic";
    }
  }

  // --- LOGICA DI SELEZIONE MIGLIORATA CON COMPRESSIONE ---
  Future<void> mostraOpzioniFile() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("vet_btn_add_files".tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.teal),
              title: Text("passport_camera".tr()),
              onTap: () async {
                Navigator.pop(context);
                final file = await ImagePickerHelper.pickImageFromCamera();
                if (file != null) setState(() => fileSelezionati.add(file));
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.teal),
              title: Text("passport_gallery".tr()),
              onTap: () async {
                Navigator.pop(context);
                final files = await ImagePickerHelper.pickMultiImagesFromGallery();
                if (files.isNotEmpty) setState(() => fileSelezionati.addAll(files));
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.teal),
              title: Text("vet_doc_pdf_etc".tr()),
              onTap: () async {
                Navigator.pop(context);
                final result = await FilePicker.platform.pickFiles(type: FileType.any, allowMultiple: true);
                if (result != null) {
                  setState(() {
                    fileSelezionati.addAll(result.paths.where((path) => path != null).map((path) => File(path!)).toList());
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _copiaFileLocale(File fileOrigine) async {
    final directory = await getApplicationDocumentsDirectory();
    final pathEsami = Directory('${directory.path}/esami_allegati');
    if (!await pathEsami.exists()) await pathEsami.create(recursive: true);

    final estensione = p.extension(fileOrigine.path);
    final nuovoNome = "esame_${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(1000)}$estensione";
    final nuovoFile = await fileOrigine.copy('${pathEsami.path}/$nuovoNome');
    return nuovoFile.path;
  }

  Future<void> salvaEsame() async {
    String titolo = titoloController.text.trim();
    if (titolo.isEmpty) {
      final now = DateTime.now();
      final dateStr = "${now.day}/${now.month}/${now.year}";
      titolo = "vet_default_exam_title".tr(args: [dateStr]);
    }

    if (fileSelezionati.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("vet_error_no_file".tr())));
      return;
    }

    setState(() => staSalvando = true);

    try {
      List<String> pathsLocali = [];
      List<String> tipi = [];
      List<int> dimensioni = [];

      for (var file in fileSelezionati) {
        if (await file.exists()) {
          final path = await _copiaFileLocale(file);
          pathsLocali.add(path);
          tipi.add(p.extension(path).replaceAll('.', ''));
          dimensioni.add(await file.length());
        }
      }

      final now = DateTime.now();
      final esame = Esame(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        categoria: categoria,
        titolo: titolo,
        descrizione: descrizioneController.text,
        data: "${now.year}-${now.month}-${now.day}",
        ora: "${now.hour}:${now.minute.toString().padLeft(2, '0')}",
        fileUrls: pathsLocali,
        tipiFile: tipi,
        dimensioniFile: dimensioni,
        valore: valoreController.text.isEmpty ? null : valoreController.text,
        unita: unitaController.text.isEmpty ? null : unitaController.text,
        range: rangeController.text.isEmpty ? null : rangeController.text,
        autore: "Proprietario",
        tags: [categoria.toLowerCase(), titolo.toLowerCase()],
        commentiCount: 0,
      );

      await EsamiLocalService().salvaEsame(widget.animaleId, esame);

      if (mounted) {
        if (widget.isFromShare) {
          await SystemNavigator.pop();
        } else {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      setState(() => staSalvando = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("snack_error_msg".tr(args: [e.toString()]))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("vet_add_exam_title".tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal.shade400,
        foregroundColor: Colors.white,
      ),
      body: staSalvando 
        ? Center(child: CircularProgressIndicator(color: Colors.teal.shade400))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: categoria,
                  items: categorie.map((c) => DropdownMenuItem(value: c, child: Text(_getCategoryTranslationKey(c).tr()))).toList(),
                  onChanged: (v) => setState(() => categoria = v!),
                  decoration: InputDecoration(
                    labelText: "vet_label_category".tr(),
                    labelStyle: TextStyle(color: Colors.teal.shade700),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.teal.shade400)),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: titoloController, 
                  decoration: InputDecoration(
                    labelText: "vet_label_exam_title".tr(),
                    hintText: "vet_hint_exam_title".tr(),
                    labelStyle: TextStyle(color: Colors.teal.shade700),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.teal.shade400)),
                  )
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: descrizioneController, 
                  maxLines: 3, 
                  decoration: InputDecoration(
                    labelText: "vet_label_description".tr(),
                    labelStyle: TextStyle(color: Colors.teal.shade700),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.teal.shade400)),
                  )
                ),
                const SizedBox(height: 20),
                
                if (fileSelezionati.isNotEmpty) ...[
                  Align(alignment: Alignment.centerLeft, child: Text("vet_label_files_ready".tr(), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal.shade700))),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: fileSelezionati.length,
                      itemBuilder: (context, index) {
                        final file = fileSelezionati[index];
                        final ext = p.extension(file.path).toLowerCase();
                        final isImage = [".jpg", ".jpeg", ".png"].contains(ext);

                        return Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade50.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.teal.shade100),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: isImage 
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(11),
                                      child: Image.file(file, fit: BoxFit.cover, width: 100, height: 100)
                                    )
                                  : Icon(Icons.picture_as_pdf, size: 40, color: Colors.teal.shade400),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => setState(() => fileSelezionati.removeAt(index)),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.9),
                                      shape: BoxShape.circle,
                                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)]
                                    ),
                                    child: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                ElevatedButton.icon(
                  onPressed: mostraOpzioniFile, // <--- CAMBIATO QUI
                  icon: const Icon(Icons.attach_file),
                  label: Text("vet_btn_add_files".tr()),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.teal.shade700,
                    backgroundColor: Colors.teal.shade50,
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade600,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: salvaEsame,
                    child: Text("vet_btn_save_all".tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
