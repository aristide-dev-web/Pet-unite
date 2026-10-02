import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:easy_localization/easy_localization.dart';
import 'a/esame_model.dart';
import 'a/esami_local_service.dart';

class AggiungiPassaporto extends StatefulWidget {
  final String animaleId;
  final Esame? esameEsistente;

  const AggiungiPassaporto({super.key, required this.animaleId, this.esameEsistente});

  @override
  State<AggiungiPassaporto> createState() => _AggiungiPassaportoState();
}

class _AggiungiPassaportoState extends State<AggiungiPassaporto> {
  final titoloController = TextEditingController();
  final numeroController = TextEditingController();
  final noteController = TextEditingController();
  
  List<File> fileSelezionati = [];
  bool staSalvando = false;

  @override
  void initState() {
    super.initState();
    if (widget.esameEsistente != null) {
      titoloController.text = widget.esameEsistente!.titolo;
      numeroController.text = widget.esameEsistente!.valore ?? "";
      noteController.text = widget.esameEsistente!.descrizione;
      fileSelezionati = widget.esameEsistente!.fileUrls.map((path) => File(path)).toList();
    } else {
      titoloController.text = "vet_default_passport_title".tr();
    }
  }

  Future<void> scegliFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        fileSelezionati.addAll(result.paths.where((path) => path != null).map((path) => File(path!)).toList());
      });
    }
  }

  Future<String> _copiaFileLocale(File fileOrigine) async {
    if (fileOrigine.path.contains('app_docs/esami_allegati') || fileOrigine.path.contains('app_flutter/esami_allegati')) {
      return fileOrigine.path;
    }

    final directory = await getApplicationDocumentsDirectory();
    final pathEsami = Directory('${directory.path}/esami_allegati');
    if (!await pathEsami.exists()) await pathEsami.create(recursive: true);

    final estensione = p.extension(fileOrigine.path);
    final nuovoNome = "pass_${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(1000)}$estensione";
    final nuovoFile = await fileOrigine.copy('${pathEsami.path}/$nuovoNome');
    return nuovoFile.path;
  }

  Future<void> salva() async {
    setState(() => staSalvando = true);

    try {
      List<String> pathsLocali = [];
      for (var file in fileSelezionati) {
        if (await file.exists()) {
          final path = await _copiaFileLocale(file);
          pathsLocali.add(path);
        }
      }

      final now = DateTime.now();
      final esame = Esame(
        id: widget.esameEsistente?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        categoria: "Passaporto",
        titolo: titoloController.text.trim().isEmpty ? "vet_default_passport_title".tr() : titoloController.text.trim(),
        descrizione: noteController.text.trim(),
        data: "${now.year}-${now.month}-${now.day}",
        ora: "${now.hour}:${now.minute.toString().padLeft(2, '0')}",
        fileUrls: pathsLocali,
        tipiFile: pathsLocali.map((e) => p.extension(e).replaceAll('.', '')).toList(),
        dimensioniFile: List.filled(pathsLocali.length, 0),
        valore: numeroController.text.trim(),
        autore: "Proprietario",
      );

      await EsamiLocalService().salvaEsame(widget.animaleId, esame);

      if (mounted) {
        Navigator.pop(context, true);
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
        title: Text("vet_passport_management_title".tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo.shade400,
        foregroundColor: Colors.white,
      ),
      body: staSalvando 
        ? Center(child: CircularProgressIndicator(color: Colors.indigo.shade400))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TextField(
                  controller: titoloController, 
                  decoration: InputDecoration(
                    labelText: "vet_label_doc_title".tr(),
                    labelStyle: TextStyle(color: Colors.indigo.shade700),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.indigo.shade400)),
                  )
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: numeroController, 
                  decoration: InputDecoration(
                    labelText: "vet_label_passport_num".tr(),
                    labelStyle: TextStyle(color: Colors.indigo.shade700),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.indigo.shade400)),
                  )
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: noteController, 
                  maxLines: 3, 
                  decoration: InputDecoration(
                    labelText: "vet_label_passport_notes".tr(),
                    labelStyle: TextStyle(color: Colors.indigo.shade700),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.indigo.shade400)),
                  )
                ),
                const SizedBox(height: 25),
                
                if (fileSelezionati.isNotEmpty) ...[
                  Align(alignment: Alignment.centerLeft, child: Text("vet_label_photos_uploaded".tr(), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo.shade700))),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: fileSelezionati.length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 120,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.indigo.shade100),
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(11),
                                child: Image.file(fileSelezionati[index], fit: BoxFit.cover, width: 120, height: 120)
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () => setState(() => fileSelezionati.removeAt(index)),
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                    child: const Icon(Icons.cancel, size: 24, color: Colors.red),
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
                  onPressed: scegliFile,
                  icon: const Icon(Icons.add_a_photo),
                  label: Text("vet_btn_add_update_photos".tr()),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.indigo.shade700,
                    backgroundColor: Colors.indigo.shade50,
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo.shade600,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: salva,
                    child: Text("vet_btn_save_passport".tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
