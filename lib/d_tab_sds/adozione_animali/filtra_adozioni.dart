import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:petping/tipologie/tipologia.dart';
import 'package:petping/d_tab_sds/d_smarriti/a_home/category_selector.dart';

class FiltraAdozioni extends StatefulWidget {
  final TextEditingController razzaController;
  final Function(String?) onSessoChanged;
  final Function(String?) onTipoChanged;
  final Function(bool?) onVaccinatoChanged;
  final Function(bool?) onCastratoChanged;
  final VoidCallback onFiltra;
  final String? selectedSesso;
  final String? selectedTipo;
  final bool? selectedVaccinato;
  final bool? selectedCastrato;

  const FiltraAdozioni({
    super.key,
    required this.razzaController,
    required this.onSessoChanged,
    required this.onTipoChanged,
    required this.onVaccinatoChanged,
    required this.onCastratoChanged,
    required this.onFiltra,
    this.selectedSesso,
    this.selectedTipo,
    this.selectedVaccinato,
    this.selectedCastrato,
  });

  @override
  State<FiltraAdozioni> createState() => _FiltraAdozioniState();
}

class _FiltraAdozioniState extends State<FiltraAdozioni> {
  static const Color greenHope = Color(0xFF27AE60);
  static const Color darkText = Color(0xFF2C3E50);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      padding: const EdgeInsets.all(24),
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
          Text("adozione_filter_header".tr(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: greenHope, letterSpacing: 1.2)),
          const SizedBox(height: 25),

          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _miniLabel("adozione_label_category".tr()),
                  CategorySelector(
                    selectedSpecies: widget.selectedTipo,
                    onSelected: widget.onTipoChanged,
                    showAll: true,
                    activeColor: greenHope,
                  ),
                  const SizedBox(height: 20),
                  
                  _miniLabel("adozione_label_gender".tr()),
                  Row(
                    children: [
                      _btn("pet_label_male".tr(), widget.selectedSesso == "Maschio", Colors.blue, () => widget.onSessoChanged(widget.selectedSesso == "Maschio" ? null : "Maschio")),
                      const SizedBox(width: 10),
                      _btn("pet_label_female".tr(), widget.selectedSesso == "Femmina", Colors.pink, () => widget.onSessoChanged(widget.selectedSesso == "Femmina" ? null : "Femmina")),
                    ],
                  ),
                  const SizedBox(height: 25),

                  _miniLabel("adozione_label_sanitary".tr()),
                  _boolFilterRow("adozione_label_vaccinated".tr(), widget.selectedVaccinato, widget.onVaccinatoChanged),
                  const SizedBox(height: 12),
                  _boolFilterRow("adozione_label_castrated".tr(), widget.selectedCastrato, widget.onCastratoChanged),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    widget.razzaController.clear();
                    widget.onSessoChanged(null);
                    widget.onTipoChanged(null);
                    widget.onVaccinatoChanged(null);
                    widget.onCastratoChanged(null);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Text("custodia_btn_clean".tr(), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: widget.onFiltra,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: greenHope,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 4,
                  ),
                  child: Text("custodia_btn_filter".tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniLabel(String t) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(t, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)));

  Widget _btn(String label, bool isSel, Color color, VoidCallback onTap) => Expanded(child: GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: isSel ? color.withOpacity(0.1) : Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: isSel ? color : Colors.grey[200]!)), child: Center(child: Text(label, style: TextStyle(color: isSel ? color : Colors.grey, fontWeight: FontWeight.bold))))));

  Widget _boolFilterRow(String label, bool? currentValue, Function(bool?) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: darkText, fontSize: 13)),
        Row(
          children: [
            _smallChoiceBtn("yes".tr().toUpperCase(), currentValue == true, () => onChanged(currentValue == true ? null : true)),
            const SizedBox(width: 8),
            _smallChoiceBtn("no".tr().toUpperCase(), currentValue == false, () => onChanged(currentValue == false ? null : false)),
          ],
        ),
      ],
    );
  }

  Widget _smallChoiceBtn(String label, bool isSel, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSel ? greenHope : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSel ? greenHope : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSel ? Colors.white : darkText,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}
