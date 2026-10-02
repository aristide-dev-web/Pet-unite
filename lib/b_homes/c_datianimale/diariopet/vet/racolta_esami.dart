import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'a/esame_model.dart';
import 'a/esami_local_service.dart';
import 'a/trash_service.dart';
import '../vet/aggiungi_esame.dart';
import '../vet/dettaglio_esame.dart';

class RaccoltaEsami extends StatefulWidget {
  final String animaleId;

  const RaccoltaEsami({super.key, required this.animaleId});

  @override
  State<RaccoltaEsami> createState() => _RaccoltaEsamiState();
}

class _RaccoltaEsamiState extends State<RaccoltaEsami> {
  List<Esame> esami = [];
  String ricerca = "";
  String filtroCategoria = "Tutte";

  final categorie = [
    "Tutte",
    "Esami del sangue",
    "Esami urine",
    "Esami feci",
    "Radiografie",
    "Ecografie",
    "TAC / RMN",
    "Test allergie",
    "Test genetici",
    "Vaccinazioni",
    "Interventi",
    "Referti vari",
    "Documenti generici",
  ];

  String _getCategoryTranslationKey(String cat) {
    switch (cat) {
      case "Tutte": return "vet_cat_all";
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

  Map<String, dynamic> _getStyleForCategoria(String cat) {
    switch (cat) {
      case "Esami del sangue":
        return {"color": Colors.red.shade400, "icon": Icons.bloodtype, "label": "vet_style_blood".tr()};
      case "Esami urine":
        return {"color": Colors.yellow.shade700, "icon": Icons.water_drop, "label": "vet_style_urine".tr()};
      case "Esami feci":
        return {"color": Colors.brown.shade400, "icon": Icons.eco, "label": "vet_style_feces".tr()};
      case "Radiografie":
        return {"color": Colors.blueGrey, "icon": Icons.vignette, "label": "vet_style_rx".tr()};
      case "Ecografie":
        return {"color": Colors.blue.shade300, "icon": Icons.settings_input_antenna, "label": "vet_style_eco".tr()};
      case "TAC / RMN":
        return {"color": Colors.deepPurple.shade300, "icon": Icons.settings_overscan, "label": "vet_style_tac_mri".tr()};
      case "Test allergie":
        return {"color": Colors.orange.shade300, "icon": Icons.warning_amber, "label": "vet_style_allergy".tr()};
      case "Test genetici":
        return {"color": Colors.teal.shade300, "icon": Icons.biotech, "label": "vet_style_dna".tr()};
      case "Vaccinazioni":
        return {"color": Colors.green.shade400, "icon": Icons.vaccines, "label": "vet_style_vaccines".tr()};
      case "Interventi":
        return {"color": Colors.red.shade900, "icon": Icons.medical_services, "label": "vet_style_surgeries".tr()};
      default:
        return {"color": Colors.teal.shade400, "icon": Icons.description, "label": "vet_style_other".tr()};
    }
  }

  @override
  void initState() {
    super.initState();
    _caricaEsami();
  }

  Future<void> _caricaEsami() async {
    final lista = await EsamiLocalService().leggiEsami(widget.animaleId);
    setState(() => esami = lista);
  }

  List<Esame> _filtraEsami() {
    return esami.where((e) {
      final matchCategoria = filtroCategoria == "Tutte" || e.categoria == filtroCategoria;
      final matchRicerca = e.titolo.toLowerCase().contains(ricerca.toLowerCase());
      return matchCategoria && matchRicerca;
    }).toList()
      ..sort((a, b) => b.data.compareTo(a.data));
  }

  @override
  Widget build(BuildContext context) {
    final listaFiltrata = _filtraEsami();

    return Scaffold(
      backgroundColor: const Color(0xFFFDFCFB),
      appBar: AppBar(
        title: Text(
          "vet_medical_folder_title".tr(),
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.1,
            color: Color(0xFF004D40),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF004D40)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _caricaEsami,
          )
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal.shade400,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AggiungiEsame(
                animaleId: widget.animaleId,
                filePaths: const [],
              ),
            ),
          );

          if (result == true) _caricaEsami();
        },
      ),

      body: Column(
        children: [
          _buildFilters(),
          const SizedBox(height: 10),
          Expanded(
            child: listaFiltrata.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: listaFiltrata.length,
              itemBuilder: (context, index) {
                final e = listaFiltrata[index];
                final style = _getStyleForCategoria(e.categoria);
                return _buildEsameCard(e, style);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: "vet_search_placeholder".tr(),
              prefixIcon: Icon(Icons.search, color: Colors.teal.shade400),
              filled: true,
              fillColor: Colors.teal.shade50.withOpacity(0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (v) => setState(() => ricerca = v),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categorie.length,
              itemBuilder: (context, i) {
                final cat = categorie[i];
                final isSelected = filtroCategoria == cat;
                return GestureDetector(
                  onTap: () => setState(() => filtroCategoria = cat),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.teal.shade400 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _getCategoryTranslationKey(cat).tr(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEsameCard(Esame e, Map<String, dynamic> style) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.delete_outline_rounded, color: Colors.red.withOpacity(0.4), size: 22),
              onPressed: () async {
                final conferma = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: Text("dialog_confirm_delete_title".tr()),
                    content: Text("diary_delete_confirm_msg".tr()),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text("btn_cancel".tr())),
                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text("btn_delete".tr(), style: const TextStyle(color: Colors.red))),
                    ],
                  ),
                );
                if (conferma == true) {
                  await TrashService.eliminaEsameCompleto(
                    animaleId: widget.animaleId,
                    esameId: e.id,
                  );
                  _caricaEsami();
                }
              },
            ),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: (style["color"] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                style["icon"] as IconData,
                color: style["color"] as Color,
                size: 26,
              ),
            ),
          ],
        ),
        title: Text(
          e.titolo,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF004D40),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              _getCategoryTranslationKey(e.categoria).tr(),
              style: TextStyle(
                color: style["color"] as Color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  e.data,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DettaglioEsame(esame: e, animaleId: widget.animaleId),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 80, color: Colors.teal.shade50),
          const SizedBox(height: 16),
          Text(
            "vet_empty_state".tr(),
            style: const TextStyle(
              color: Colors.teal,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
