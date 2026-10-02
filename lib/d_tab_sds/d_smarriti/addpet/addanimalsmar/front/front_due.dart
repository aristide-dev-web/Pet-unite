import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class AddDueFront extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController microchipController;
  final TextEditingController coloreDominanteController;
  final TextEditingController coloreSecondarioController;
  final TextEditingController occhiColoreController;
  final TextEditingController orecchieGrandezzaController;
  final TextEditingController codaGrandezzaController;
  final TextEditingController scarNoteController;
  final bool haCicatrici;
  final ValueChanged<bool> onCicatriceChanged;
  final VoidCallback onNextStep;

  static const Color vintageGold = Color(0xFFC5A059);
  static const Color darkBrown = Color(0xFF4E342E);
  static const Color parchment = Color(0xFFFEFAE0);

  const AddDueFront({
    super.key,
    required this.formKey,
    required this.microchipController,
    required this.coloreDominanteController,
    required this.coloreSecondarioController,
    required this.occhiColoreController,
    required this.orecchieGrandezzaController,
    required this.codaGrandezzaController,
    required this.scarNoteController,
    required this.haCicatrici,
    required this.onCicatriceChanged,
    required this.onNextStep,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('custodia_filter_identity'.tr(), Icons.fingerprint_rounded),
          const SizedBox(height: 12),
          _fieldLabel('microchip_upper'.tr()),
          _buildTextField(
            controller: microchipController,
            hint: 'custodia_filter_microchip_hint'.tr(),
            icon: Icons.qr_code_scanner_rounded,
          ),
          const SizedBox(height: 30),

          _buildSectionHeader('section_colors_coat'.tr().toUpperCase(), Icons.palette_rounded),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('color_primary_upper'.tr()),
                    _buildColorDropdown(hint: 'profile_select_placeholder'.tr(), controller: coloreDominanteController, icon: Icons.format_paint_rounded),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 11,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('color_secondary_upper'.tr()),
                    _buildColorDropdown(hint: 'profile_select_placeholder'.tr(), controller: coloreSecondarioController, icon: Icons.brush_rounded),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          _buildSectionHeader('section_physical_details'.tr().toUpperCase(), Icons.visibility_rounded),
          const SizedBox(height: 12),
          _fieldLabel('eyes_color_upper'.tr()),
          _buildDropdown('profile_select_placeholder'.tr(), occhiColoreController, _occhiColoriOptions, Icons.remove_red_eye_rounded),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                flex: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('ears_size_upper'.tr()),
                    _buildDropdown('profile_select_placeholder'.tr(), orecchieGrandezzaController, _orecchieGrandezzaOptions, Icons.hearing_rounded),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 11,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('tail_length_upper'.tr()),
                    _buildDropdown('profile_select_placeholder'.tr(), codaGrandezzaController, _codaGrandezzaOptions, Icons.pets_rounded),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          _buildSectionHeader('custodia_filter_marks'.tr().toUpperCase(), Icons.healing_rounded),
          const SizedBox(height: 12),
          _fieldLabel('custodia_filter_scars'.tr()),
          Row(
            children: [
              _buildSelectionButton(label: 'yes'.tr().toUpperCase(), isSelected: haCicatrici, onTap: () => onCicatriceChanged(true)),
              const SizedBox(width: 10),
              _buildSelectionButton(label: 'no'.tr().toUpperCase(), isSelected: !haCicatrici, onTap: () => onCicatriceChanged(false)),
            ],
          ),
          const SizedBox(height: 15),
          _fieldLabel('label_description_upper'.tr()),
          _buildTextField(
            controller: scarNoteController,
            hint: 'social_hint_desc_default'.tr(),
            maxLines: 2,
            icon: Icons.edit_note_rounded,
          ),

          const SizedBox(height: 40),
          _buildNextButton(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: vintageGold, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(color: darkBrown, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.1),
          ),
        ),
      ],
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(
        text,
        style: TextStyle(color: darkBrown.withOpacity(0.7), fontWeight: FontWeight.w800, fontSize: 9, letterSpacing: 0.5),
      ),
    );
  }

  // Mappa delle opzioni per supportare la traduzione
  static final Map<String, String> _mantelloColoriOptions = {
    'color_black': 'Nero',
    'color_white': 'Bianco',
    'color_brown': 'Marrone',
    'color_gray': 'Grigio',
    'color_dark_gray': 'Grigio scuro',
    'color_beige': 'Beige',
    'color_orange': 'Arancione',
    'color_fawn': 'Fulvo',
    'color_cream': 'Crema',
    'color_red': 'Rosso',
    'color_brindle': 'Tigrato',
    'color_spotted': 'A macchie (Pezzato)',
  };

  static final Map<String, String> _occhiColoriOptions = {
    'eyes_brown': 'Marrone',
    'eyes_black': 'Nero',
    'eyes_amber': 'Ambra',
    'eyes_blue': 'Azzurro',
    'eyes_green': 'Verde',
    'eyes_yellow': 'Giallo',
    'eyes_heterochromia': 'Heterocromia',
    'eyes_gray': 'Grigio',
  };

  static final Map<String, String> _orecchieGrandezzaOptions = {
    'size_small': 'Piccole',
    'size_medium': 'Medie',
    'size_large': 'Grandi',
    'size_very_large': 'Molto grandi',
    'size_absent': 'Assenti',
  };

  static final Map<String, String> _codaGrandezzaOptions = {
    'tail_small': 'Piccola',
    'tail_medium': 'Media',
    'tail_large': 'Grande',
    'tail_very_large': 'Molto grande',
    'tail_absent': 'Assente',
  };

  Widget _buildColorDropdown({required String hint, required TextEditingController controller, required IconData icon}) {
    return _buildDropdown(hint, controller, _mantelloColoriOptions, icon);
  }

  Widget _buildDropdown(String hint, TextEditingController controller, Map<String, String> options, IconData icon) {
    return DropdownButtonFormField<String>(
      value: options.containsKey(controller.text) ? controller.text : (options.containsValue(controller.text) ? options.keys.firstWhere((k) => options[k] == controller.text) : null),
      isExpanded: true,
      style: const TextStyle(fontSize: 13, color: darkBrown, fontWeight: FontWeight.w600),
      decoration: _inputDecoration(hint, icon),
      items: options.entries.map((e) {
        return DropdownMenuItem<String>(
          value: e.key,
          child: Text(e.key.tr(), overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: (val) => controller.text = val ?? '',
    );
  }

  Widget _buildSelectionButton({required String label, required bool isSelected, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? darkBrown : Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? darkBrown : darkBrown.withOpacity(0.1), width: 1.5),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(color: isSelected ? Colors.white : darkBrown.withOpacity(0.6), fontWeight: FontWeight.w900, fontSize: 10),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: vintageGold, size: 16),
      hintStyle: TextStyle(color: darkBrown.withOpacity(0.3), fontSize: 11),
      filled: true,
      fillColor: Colors.white.withOpacity(0.6),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: darkBrown.withOpacity(0.05))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: vintageGold, width: 1.5)),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, int maxLines = 1, required IconData icon}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: darkBrown, fontWeight: FontWeight.w600, fontSize: 13),
      decoration: _inputDecoration(hint, icon),
    );
  }

  Widget _buildNextButton() {
    return ElevatedButton(
      onPressed: onNextStep,
      style: ElevatedButton.styleFrom(
        backgroundColor: darkBrown,
        foregroundColor: parchment,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('ps_reg_btn_continue'.tr().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13)),
          const SizedBox(width: 10),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14),
        ],
      ),
    );
  }
}
