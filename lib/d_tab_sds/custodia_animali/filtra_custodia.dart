import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:petping/tipologie/selector/colore.dart';
import 'package:petping/tipologie/selector/occhi.dart';
import 'package:petping/tipologie/selector/coda_orecchie.dart';
import 'package:petping/tipologie/tipologia.dart';
import 'package:petping/d_tab_sds/d_smarriti/a_home/category_selector.dart';

class FiltraCustodia extends StatefulWidget {
  final TextEditingController nomeController;
  final TextEditingController razzaController;
  final TextEditingController microchipController;
  final TextEditingController coloreDominanteController;
  final TextEditingController coloreSecondarioController;
  final TextEditingController occhiColoreController;
  final TextEditingController orecchieGrandezzaController;
  final TextEditingController codaGrandezzaController;
  
  final String? selectedSesso;
  final bool? selectedCicatrici;
  final String? selectedTipo;
  
  final Function(String?) onSessoChanged;
  final Function(bool?) onCicatriciChanged;
  final Function(String?) onTipoChanged;
  
  final VoidCallback onFiltra;

  const FiltraCustodia({
    super.key,
    required this.nomeController,
    required this.razzaController,
    required this.microchipController,
    required this.coloreDominanteController,
    required this.coloreSecondarioController,
    required this.occhiColoreController,
    required this.orecchieGrandezzaController,
    required this.codaGrandezzaController,
    required this.onSessoChanged,
    required this.onCicatriciChanged,
    required this.onTipoChanged,
    required this.onFiltra,
    this.selectedSesso,
    this.selectedCicatrici,
    this.selectedTipo,
  });

  @override
  State<FiltraCustodia> createState() => _FiltraCustodiaState();
}

class _FiltraCustodiaState extends State<FiltraCustodia> {
  static const Color blueSecurity = Color(0xFF2980B9);
  static const Color darkText = Color(0xFF2C3E50);
  static const Color goldAccent = Color(0xFFFFC107);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.search_rounded, color: blueSecurity, size: 20),
              const SizedBox(width: 8),
              Text("custodia_filter_title".tr(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: blueSecurity, letterSpacing: 1.2)),
            ],
          ),
          const SizedBox(height: 15),

          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMicrochipHighlight(),
                  _buildTextDivider("custodia_filter_features".tr()),

                  _filterLabel("custodia_filter_category".tr(), Icons.pets_rounded),
                  const SizedBox(height: 5),
                  CategorySelector(
                    selectedSpecies: widget.selectedTipo,
                    showAll: false,
                    activeColor: blueSecurity,
                    onSelected: (val) {
                      widget.onTipoChanged(val);
                      setState(() {}); // Forza refresh locale per aggiornare la razza
                    },
                  ),

                  const SizedBox(height: 15),
                  _filterLabel("custodia_filter_gender".tr(), Icons.wc_rounded),
                  Row(
                    children: [
                      _sessoBtn("pet_label_male".tr().toUpperCase(), Icons.male_rounded, widget.selectedSesso == 'Maschio', Colors.blue, () {
                        widget.onSessoChanged(widget.selectedSesso == 'Maschio' ? null : 'Maschio');
                        setState(() {});
                      }),
                      const SizedBox(width: 12),
                      _sessoBtn("pet_label_female".tr().toUpperCase(), Icons.female_rounded, widget.selectedSesso == 'Femmina', Colors.pink, () {
                        widget.onSessoChanged(widget.selectedSesso == 'Femmina' ? null : 'Femmina');
                        setState(() {});
                      }),
                    ],
                  ),

                  const SizedBox(height: 10),
                  _filterLabel("custodia_filter_identity".tr(), Icons.badge_outlined),
                  _miniLabel("custodia_filter_pet_name".tr()),
                  _buildModernInput("custodia_filter_pet_name_hint".tr(), widget.nomeController, Icons.drive_file_rename_outline_rounded),
                  const SizedBox(height: 5),
                  _miniLabel("custodia_filter_breed".tr()),
                  _buildRazzaAutocomplete(),

                  const SizedBox(height: 10),
                  _filterLabel("custodia_filter_marks".tr(), Icons.auto_awesome_rounded),
                  _miniLabel("custodia_filter_scars".tr()),
                  Row(
                    children: [
                      _cicatriciBtn("yes".tr().toUpperCase(), widget.selectedCicatrici == true, () {
                        widget.onCicatriciChanged(widget.selectedCicatrici == true ? null : true);
                        setState(() {});
                      }),
                      const SizedBox(width: 12),
                      _cicatriciBtn("no".tr().toUpperCase(), widget.selectedCicatrici == false, () {
                        widget.onCicatriciChanged(widget.selectedCicatrici == false ? null : false);
                        setState(() {});
                      }),
                    ],
                  ),
                  
                  _miniLabel("custodia_filter_eye_color".tr()),
                  _buildSelectorWrapper(OcchiColoreSelector(controller: widget.occhiColoreController, label: "profile_select_placeholder".tr(), isDark: false), icon: Icons.remove_red_eye_outlined),
                  
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _miniLabel("custodia_filter_color_dom".tr()),
                            _buildSelectorWrapper(ColoreSelector(controller: widget.coloreDominanteController, label: "pet_color_primary".tr(), isDark: false)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _miniLabel("custodia_filter_color_sec".tr()),
                            _buildSelectorWrapper(ColoreSelector(controller: widget.coloreSecondarioController, label: "pet_color_reflections".tr(), isDark: false)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 10),
                  _filterLabel("custodia_filter_physical".tr(), Icons.straighten_rounded),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _miniLabel("custodia_filter_ears".tr()),
                            _buildSelectorWrapper(OrecchieGrandezzaSelector(controller: widget.orecchieGrandezzaController, isDark: false)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _miniLabel("custodia_filter_tail".tr()),
                            _buildSelectorWrapper(CodaGrandezzaSelector(controller: widget.codaGrandezzaController, isDark: false)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildMicrochipHighlight() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: blueSecurity.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: goldAccent.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [const Icon(Icons.qr_code_scanner_rounded, color: goldAccent, size: 20), const SizedBox(width: 8), Text("custodia_filter_microchip".tr(), style: const TextStyle(color: blueSecurity, fontWeight: FontWeight.w900, fontSize: 11))]),
          const SizedBox(height: 12),
          TextField(
            controller: widget.microchipController,
            keyboardType: TextInputType.number,
            maxLength: 15,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkText, letterSpacing: 2),
            decoration: InputDecoration(hintText: "custodia_filter_microchip_hint".tr(), counterText: "", filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.all(16), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
          ),
        ],
      ),
    );
  }

  Widget _buildRazzaAutocomplete() {
    final List<String> options = razzePerSpecie[widget.selectedTipo] ?? [];
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
      child: Autocomplete<String>(
        optionsBuilder: (text) => text.text.isEmpty ? const Iterable<String>.empty() : options.where((o) => o.toLowerCase().contains(text.text.toLowerCase())),
        onSelected: (selection) {
          widget.razzaController.text = selection;
          setState(() {});
        },
        fieldViewBuilder: (context, ctrl, focus, onSubmitted) {
          if (widget.razzaController.text.isNotEmpty && ctrl.text.isEmpty) ctrl.text = widget.razzaController.text;
          return TextField(controller: ctrl, focusNode: focus, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: darkText), decoration: InputDecoration(hintText: "custodia_filter_breed_hint".tr(), prefixIcon: const Icon(Icons.search_rounded, color: blueSecurity, size: 18), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 15)));
        },
      ),
    );
  }

  Widget _buildModernInput(String hint, TextEditingController controller, IconData icon) => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
    child: TextField(
      controller: controller, 
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: darkText), 
      decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon, color: blueSecurity, size: 18), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 15))
    ),
  );

  Widget _buildSelectorWrapper(Widget selector, {IconData? icon}) => Container(
    height: 55, 
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)), 
    padding: const EdgeInsets.symmetric(horizontal: 12), 
    child: Row(
      children: [
        if (icon != null) ...[Icon(icon, size: 18, color: blueSecurity.withOpacity(0.7)), const SizedBox(width: 8)],
        Expanded(child: DropdownButtonHideUnderline(child: selector)),
      ],
    )
  );

  Widget _miniLabel(String t) => Padding(padding: const EdgeInsets.only(left: 4, bottom: 8, top: 10), child: Text(t, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.grey)));

  Widget _filterLabel(String text, IconData icon) => Container(
    margin: const EdgeInsets.only(bottom: 12, top: 8),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(color: blueSecurity.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [Icon(icon, size: 14, color: blueSecurity), const SizedBox(width: 8), Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: blueSecurity, letterSpacing: 1.2))],
    ),
  );

  Widget _buildTextDivider(String text) => Padding(padding: const EdgeInsets.symmetric(vertical: 25), child: Row(children: [Expanded(child: Divider(color: Colors.grey[300])), Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text(text, style: TextStyle(color: Colors.grey[400], fontSize: 9, fontWeight: FontWeight.w900))), Expanded(child: Divider(color: Colors.grey[300]))]));

  Widget _sessoBtn(String label, IconData icon, bool isSel, Color color, VoidCallback onTap) => Expanded(child: GestureDetector(onTap: onTap, child: AnimatedContainer(duration: const Duration(milliseconds: 250), padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: isSel ? color : Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: isSel ? color : Colors.grey[200]!, width: 2)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 18, color: isSel ? Colors.white : color), const SizedBox(width: 8), Text(label, style: TextStyle(color: isSel ? Colors.white : color, fontWeight: FontWeight.bold, fontSize: 12))]))));

  Widget _cicatriciBtn(String label, bool isSel, VoidCallback onTap) => Expanded(child: GestureDetector(onTap: onTap, child: AnimatedContainer(duration: const Duration(milliseconds: 200), padding: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(color: isSel ? blueSecurity : Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: isSel ? blueSecurity : Colors.grey[200]!, width: 2)), child: Center(child: Text(label, style: TextStyle(color: isSel ? Colors.white : Colors.grey, fontWeight: FontWeight.bold, fontSize: 13))))));

  Widget _buildActionButtons() => Row(children: [Expanded(child: OutlinedButton(onPressed: () {
    widget.nomeController.clear(); widget.razzaController.clear(); widget.microchipController.clear();
    widget.coloreDominanteController.clear(); widget.coloreSecondarioController.clear();
    widget.occhiColoreController.clear(); widget.orecchieGrandezzaController.clear();
    widget.codaGrandezzaController.clear();
    widget.onSessoChanged(null); widget.onCicatriciChanged(null); widget.onTipoChanged(null);
    setState(() {});
  }, style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: Text("custodia_btn_clean".tr(), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)))), const SizedBox(width: 12), Expanded(flex: 2, child: ElevatedButton(onPressed: widget.onFiltra, style: ElevatedButton.styleFrom(backgroundColor: blueSecurity, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: Text("custodia_btn_filter".tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900))))]);
}
