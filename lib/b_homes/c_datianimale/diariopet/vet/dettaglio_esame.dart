import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:easy_localization/easy_localization.dart';
import 'a/esame_model.dart';
import 'a/esami_local_service.dart';
import 'aggiungi_passaporto.dart';

class DettaglioEsame extends StatefulWidget {
  final Esame esame;
  final String? animaleId;

  const DettaglioEsame({super.key, required this.esame, this.animaleId});

  @override
  State<DettaglioEsame> createState() => _DettaglioEsameState();
}

class _DettaglioEsameState extends State<DettaglioEsame> {
  final commentoController = TextEditingController();
  List<String> commenti = [];

  @override
  void initState() {
    super.initState();
    _caricaCommenti();
  }

  Future<void> _caricaCommenti() async {
    final lista = await EsamiLocalService().leggiCommenti(widget.esame.id);
    setState(() => commenti = lista);
  }

  Future<void> _aggiungiCommento() async {
    final testo = commentoController.text.trim();
    if (testo.isEmpty) return;

    await EsamiLocalService().salvaCommento(widget.esame.id, testo);
    commentoController.clear();
    await _caricaCommenti();
  }

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
      case "Passaporto": return "passport_upper";
      default: return "vet_cat_generic";
    }
  }

  Widget _buildGalleriaFile() {
    if (widget.esame.fileUrls.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text("vet_no_files_attached".tr()),
        ),
      );
    }

    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.esame.fileUrls.length,
        itemBuilder: (context, index) {
          final path = widget.esame.fileUrls[index];
          final ext = p.extension(path).toLowerCase();
          final isImage = [".jpg", ".jpeg", ".png", ".gif"].contains(ext);

          return Container(
            width: 200,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: isImage
                  ? GestureDetector(
                      onTap: () => _mostraImmagineFull(path),
                      child: Image.file(File(path), fit: BoxFit.cover),
                    )
                  : Container(
                      color: Colors.red.shade50,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.picture_as_pdf, size: 60, color: Colors.red),
                          SizedBox(height: 8),
                          Text("PDF", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                        ],
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  void _mostraImmagineFull(String path) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(child: Image.file(File(path))),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.esame;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(e.titolo, style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          if (e.categoria == "Passaporto" && widget.animaleId != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final aggiornato = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AggiungiPassaporto(
                    animaleId: widget.animaleId!,
                    esameEsistente: e,
                  )),
                );
                if (aggiornato == true) {
                  Navigator.pop(context); // Torna indietro per ricaricare i dati aggiornati
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGalleriaFile(),
            const SizedBox(height: 25),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: e.categoria == "Passaporto" ? Colors.indigo.shade50 : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _row("vet_label_category".tr(), _getCategoryTranslationKey(e.categoria).tr()),
                  _row("vet_label_date".tr(), e.data),
                  _row("vet_label_time".tr(), e.ora),
                  if (e.categoria == "Passaporto") _row("vet_label_passport_num".tr(), e.valore ?? "N.D."),
                  if (e.categoria != "Passaporto" && e.valore != null) _row("vet_label_value".tr(), e.valore!),
                  if (e.unita != null) _row("vet_label_unit".tr(), e.unita!),
                  if (e.range != null) _row("vet_label_range".tr(), e.range!),
                ],
              ),
            ),

            const SizedBox(height: 25),
            Text(e.categoria == "Passaporto" ? "vet_label_passport_notes".tr() : "vet_label_description".tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              e.descrizione.isEmpty ? "vet_no_description".tr() : e.descrizione,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
            ),

            const SizedBox(height: 40),
            Text("vet_label_comments_notes".tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),

            if (commenti.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text("vet_no_comments".tr()),
              ),
            
            ...commenti.map((c) => Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(c, style: const TextStyle(fontSize: 15)),
            )),

            const SizedBox(height: 20),
            TextField(
              controller: commentoController,
              maxLines: null,
              decoration: InputDecoration(
                hintText: "vet_hint_write_note".tr(),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: _aggiungiCommento,
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
