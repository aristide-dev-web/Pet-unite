import 'package:flutter/material.dart';
import 'package:petping/tipologie/selector/colore.dart';
import 'package:petping/tipologie/selector/occhi.dart';
import 'package:petping/tipologie/selector/coda_orecchie.dart';
import 'package:easy_localization/easy_localization.dart';

class FrontAddCustodiaDue extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController colorDomController;
  final TextEditingController colorSecController;
  final TextEditingController occhiColoreController;
  final TextEditingController occhiFormaController;
  final TextEditingController orecchieController;
  final TextEditingController codaController;
  final TextEditingController noteParticolariController;
  final TextEditingController microchipController;
  final bool haCicatrici;
  final Function(bool) onCicatriciChanged;
  final VoidCallback onNext;

  const FrontAddCustodiaDue({
    super.key,
    required this.formKey,
    required this.colorDomController,
    required this.colorSecController,
    required this.occhiColoreController,
    required this.occhiFormaController,
    required this.orecchieController,
    required this.codaController,
    required this.noteParticolariController,
    required this.microchipController,
    required this.haCicatrici,
    required this.onCicatriciChanged,
    required this.onNext,
  });

  static const Color blueSecurity = Color(0xFF2980B9);
  static const Color darkBrown = Color(0xFF4E342E);
  static const Color goldAccent = Color(0xFFFFC107);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMicrochipPanel(),
          const SizedBox(height: 35),

          _sectionTitle("custodia_section_coat_eyes".tr(), Icons.auto_awesome_rounded),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label("custodia_label_color_dom".tr()),
                    _buildSelector(ColoreSelector(controller: colorDomController, label: "custodia_hint_dominant".tr(), isDark: false)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label("custodia_label_color_sec".tr()),
                    _buildSelector(ColoreSelector(controller: colorSecController, label: "custodia_hint_secondary".tr(), isDark: false)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),
          _label("custodia_label_eyes_color".tr()),
          _buildSelector(OcchiColoreSelector(controller: occhiColoreController, label: "custodia_hint_choose_color".tr(), isDark: false), icon: Icons.remove_red_eye_outlined),

          const SizedBox(height: 35),
          _sectionTitle("custodia_section_traits".tr(), Icons.straighten_rounded),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label("custodia_label_ears".tr()),
                    _buildSelector(OrecchieGrandezzaSelector(controller: orecchieController, isDark: false)),
                  ],
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label("custodia_label_tail".tr()),
                    _buildSelector(CodaGrandezzaSelector(controller: codaController, isDark: false)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 35),
          _sectionTitle("custodia_section_marks".tr(), Icons.healing_rounded),
          const SizedBox(height: 20),
          _label("custodia_q_scars".tr()),
          Row(
            children: [
              _cicatriciBtn("yes_upper".tr(), haCicatrici == true, () => onCicatriciChanged(true)),
              const SizedBox(width: 12),
              _cicatriciBtn("no_upper".tr(), haCicatrici == false, () => onCicatriciChanged(false)),
            ],
          ),

          const SizedBox(height: 25),
          _label("custodia_label_notes_behavior".tr()),
          Container(
            decoration: BoxDecoration(
              color: Colors.white, 
              borderRadius: BorderRadius.circular(20), 
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: TextFormField(
              controller: noteParticolariController,
              maxLines: 3,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: darkBrown),
              decoration: InputDecoration(
                hintText: "custodia_hint_notes_behavior".tr(),
                hintStyle: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.normal),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(18),
              ),
            ),
          ),

          const SizedBox(height: 50),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: blueSecurity,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                elevation: 6,
                shadowColor: blueSecurity.withOpacity(0.4),
              ),
              child: Text("custodia_btn_continue_map".tr(), style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.2)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMicrochipPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: goldAccent.withOpacity(0.5), width: 2),
        boxShadow: [BoxShadow(color: goldAccent.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.qr_code_scanner_rounded, color: goldAccent, size: 24),
              const SizedBox(width: 12),
              Text("custodia_microchip_title".tr(), style: const TextStyle(fontWeight: FontWeight.w900, color: darkBrown, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "custodia_microchip_help".tr(),
            style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600, height: 1.4),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: microchipController,
            keyboardType: TextInputType.number,
            maxLength: 15,
            style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2, color: darkBrown),
            decoration: InputDecoration(
              hintText: "custodia_microchip_hint".tr(),
              counterText: "",
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t, IconData icon) => Row(
    children: [
      Icon(icon, size: 18, color: blueSecurity),
      const SizedBox(width: 8),
      Text(t, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: blueSecurity, letterSpacing: 1.2)),
    ],
  );

  Widget _label(String t) => Padding(padding: const EdgeInsets.only(left: 6, bottom: 8), child: Text(t, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 0.5)));

  Widget _buildSelector(Widget selector, {IconData? icon}) => Container(
    height: 58,
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.grey.shade200),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
    ),
    child: Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: blueSecurity.withOpacity(0.7)),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Theme(
            data: ThemeData(
              canvasColor: Colors.white,
              textTheme: const TextTheme(titleMedium: TextStyle(color: darkBrown, fontSize: 14, fontWeight: FontWeight.bold)),
            ),
            child: DropdownButtonHideUnderline(child: selector),
          ),
        ),
      ],
    ),
  );

  Widget _cicatriciBtn(String label, bool isSelected, VoidCallback onTap) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? blueSecurity : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? blueSecurity : Colors.grey.shade200, width: 2),
          boxShadow: isSelected ? [BoxShadow(color: blueSecurity.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
        ),
        child: Center(child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontWeight: FontWeight.w900, fontSize: 13))),
      ),
    ),
  );
}
