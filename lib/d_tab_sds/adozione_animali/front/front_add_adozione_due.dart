import 'package:flutter/material.dart';
import 'package:petping/keyboard_cover.dart';
import 'package:easy_localization/easy_localization.dart';

class FrontAddAdozioneDue extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController microchipController;
  final TextEditingController coloreDominanteController;
  final TextEditingController coloreSecondarioController;
  final TextEditingController occhiColoreController;
  final TextEditingController orecchieGrandezzaController;
  final TextEditingController codaGrandezzaController;

  final bool vaccinato;
  final ValueChanged<bool> onVaccinatoChanged;
  final TextEditingController vaccinatoNoteController;

  final bool sverminato;
  final ValueChanged<bool> onSverminatoChanged;
  final TextEditingController sverminatoNoteController;

  final bool sterilizzato;
  final ValueChanged<bool> onSterilizzatoChanged;
  final TextEditingController sterilizzatoNoteController;

  final bool haCicatrici;
  final ValueChanged<bool> onCicatriciChanged;
  final TextEditingController cicatriciNoteController;

  final bool haAllergie;
  final ValueChanged<bool> onAllergieChanged;
  final TextEditingController allergieNoteController;

  final VoidCallback onNext;

  static const Color greenHope = Color(0xFF27AE60);
  static const Color darkBlue = Color(0xFF2C3E50);

  const FrontAddAdozioneDue({
    super.key,
    required this.formKey,
    required this.microchipController,
    required this.coloreDominanteController,
    required this.coloreSecondarioController,
    required this.occhiColoreController,
    required this.orecchieGrandezzaController,
    required this.codaGrandezzaController,
    required this.vaccinato,
    required this.onVaccinatoChanged,
    required this.vaccinatoNoteController,
    required this.sverminato,
    required this.onSverminatoChanged,
    required this.sverminatoNoteController,
    required this.sterilizzato,
    required this.onSterilizzatoChanged,
    required this.sterilizzatoNoteController,
    required this.haCicatrici,
    required this.onCicatriciChanged,
    required this.cicatriciNoteController,
    required this.haAllergie,
    required this.onAllergieChanged,
    required this.allergieNoteController,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return SafeFormPage(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('adozione_label_microchip_opt'.tr()),
            _buildTextField(controller: microchipController, hint: 'adozione_hint_microchip'.tr(), icon: Icons.qr_code),
            
            _buildLabel('adozione_label_coat_colors'.tr()),
            Row(
              children: [
                Expanded(child: _buildDropdown('adozione_label_dominant'.tr(), coloreDominanteController, _coloriOptions, Icons.palette)),
                const SizedBox(width: 10),
                Expanded(child: _buildDropdown('adozione_label_secondary'.tr(), coloreSecondarioController, _coloriOptions, Icons.brush)),
              ],
            ),
            const SizedBox(height: 20),

            _buildLabel('adozione_label_physical_details'.tr()),
            _buildDropdown('adozione_label_eyes_color'.tr(), occhiColoreController, _occhiOptions, Icons.visibility),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(child: _buildDropdown('adozione_label_ears'.tr(), orecchieGrandezzaController, _grandezzaOptions, Icons.hearing)),
                const SizedBox(width: 10),
                Expanded(child: _buildDropdown('adozione_label_tail'.tr(), codaGrandezzaController, _grandezzaOptions, Icons.pets)),
              ],
            ),

            const SizedBox(height: 30),
            _buildSectionHeader('adozione_section_health'.tr(), Icons.health_and_safety),
            
            _buildSwitchWithNote('adozione_label_vaccinated'.tr(), vaccinato, onVaccinatoChanged, vaccinatoNoteController, 'adozione_hint_vaccines'.tr()),
            _buildSwitchWithNote('adozione_label_dewormed'.tr(), sverminato, onSverminatoChanged, sverminatoNoteController, 'adozione_hint_dewormed'.tr()),
            _buildSwitchWithNote('adozione_label_sterilized'.tr(), sterilizzato, onSterilizzatoChanged, sterilizzatoNoteController, 'adozione_hint_sterilized'.tr()),
            _buildSwitchWithNote('adozione_label_scars_ops'.tr(), haCicatrici, onCicatriciChanged, cicatriciNoteController, 'adozione_hint_scars'.tr()),
            _buildSwitchWithNote('adozione_label_allergies_illness'.tr(), haAllergie, onAllergieChanged, allergieNoteController, 'adozione_hint_allergies'.tr()),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: greenHope,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 4,
                ),
                child: Text('btn_continue'.tr().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: greenHope, size: 20),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(color: darkBlue, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.1)),
        ],
      ),
    );
  }

  Widget _buildSwitchWithNote(String title, bool value, ValueChanged<bool> onChanged, TextEditingController controller, String hint) {
    return Column(
      children: [
        SwitchListTile(
          title: Text(title, style: const TextStyle(color: darkBlue, fontWeight: FontWeight.bold, fontSize: 14)),
          value: value,
          activeColor: greenHope,
          contentPadding: EdgeInsets.zero,
          onChanged: onChanged,
        ),
        if (value)
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: TextFormField(
              controller: controller,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: hint,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),
      ],
    );
  }

  static final List<String> _coloriOptions = [
    'color_black'.tr(), 'color_white'.tr(), 'color_brown'.tr(), 'color_gray'.tr(), 'color_beige'.tr(), 
    'color_orange'.tr(), 'color_fawn'.tr(), 'color_cream'.tr(), 'color_red'.tr(), 'color_brindle'.tr(), 'color_spotted'.tr()
  ];
  static final List<String> _occhiOptions = [
    'eyes_brown'.tr(), 'eyes_black'.tr(), 'eyes_amber'.tr(), 'eyes_blue'.tr(), 'eyes_green'.tr(), 'eyes_yellow'.tr(), 'eyes_gray'.tr()
  ];
  static final List<String> _grandezzaOptions = [
    'size_small'.tr(), 'size_medium'.tr(), 'size_large'.tr(), 'size_absent'.tr()
  ];

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 15),
      child: Text(text, style: const TextStyle(color: darkBlue, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, required IconData icon}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: darkBlue, fontWeight: FontWeight.w600, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: greenHope, size: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildDropdown(String hint, TextEditingController controller, List<String> options, IconData icon) {
    return DropdownButtonFormField<String>(
      value: options.contains(controller.text) ? controller.text : null,
      style: const TextStyle(color: darkBlue, fontWeight: FontWeight.w600, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: greenHope, size: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      items: options.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
      onChanged: (val) => controller.text = val ?? '',
    );
  }
}
