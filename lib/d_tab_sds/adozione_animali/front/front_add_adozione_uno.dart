import 'dart:io';
import 'package:flutter/material.dart';
import 'package:petping/tipologie/tipologia.dart';
import 'package:petping/d_tab_sds/d_smarriti/a_home/category_selector.dart';
import 'package:petping/keyboard_cover.dart';
import 'package:easy_localization/easy_localization.dart';

class FrontAddAdozioneUno extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController razzaController;
  
  final int? selectedDay;
  final int? selectedMonth;
  final int? selectedYear;
  final ValueChanged<int?> onDayChanged;
  final ValueChanged<int?> onMonthChanged;
  final ValueChanged<int?> onYearChanged;

  final String? selectedSpecie;
  final ValueChanged<String?> onSpecieChanged;
  final String? selectedSesso;
  final ValueChanged<String?> onSessoChanged;
  final List<File> selectedImages;
  final VoidCallback onPickImages;
  final Function(int) onRemoveImage;
  final VoidCallback onNext;
  final VoidCallback? onFixImages;

  static const Color greenHope = Color(0xFF27AE60);
  static const Color darkBlue = Color(0xFF2C3E50);

  const FrontAddAdozioneUno({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.razzaController,
    required this.selectedDay,
    required this.selectedMonth,
    required this.selectedYear,
    required this.onDayChanged,
    required this.onMonthChanged,
    required this.onYearChanged,
    required this.selectedSpecie,
    required this.onSpecieChanged,
    required this.selectedSesso,
    required this.onSessoChanged,
    required this.selectedImages,
    required this.onPickImages,
    required this.onRemoveImage,
    required this.onNext,
    this.onFixImages,
  });

  @override
  Widget build(BuildContext context) {
    return SafeFormPage(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SELETTORE SPECIE (I GETTONI) - UNICO OBBLIGATORIO
            _buildLabel('adozione_q_animal_type'.tr()),
            CategorySelector(
              selectedSpecies: selectedSpecie,
              onSelected: onSpecieChanged,
              showAll: false,
              activeColor: greenHope,
            ),
            const SizedBox(height: 20),

            // GALLERIA FOTO
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLabel('adozione_label_photos'.tr()),
                if (selectedImages.isNotEmpty && onFixImages != null)
                  GestureDetector(
                    onTap: onFixImages,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8, right: 10),
                      child: Text(
                        "adozione_label_manage_photos".tr(),
                        style: const TextStyle(color: greenHope, fontWeight: FontWeight.w900, fontSize: 10),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: selectedImages.length + 1,
                itemBuilder: (context, index) {
                  if (index == selectedImages.length) {
                    return index < 5 ? _buildAddImageButton() : const SizedBox.shrink();
                  }
                  return _buildImagePreview(index);
                },
              ),
            ),
            const SizedBox(height: 30),

            // SESSO
            _buildLabel('adozione_label_sesso'.tr()),
            Row(
              children: [
                _buildSessoButton(
                  label: 'gender_male'.tr().toUpperCase(),
                  icon: Icons.male,
                  isSelected: selectedSesso == 'Maschio',
                  activeColor: Colors.blue,
                  onTap: () => onSessoChanged('Maschio'),
                ),
                const SizedBox(width: 12),
                _buildSessoButton(
                  label: 'gender_female'.tr().toUpperCase(),
                  icon: Icons.female,
                  isSelected: selectedSesso == 'Femmina',
                  activeColor: Colors.pink,
                  onTap: () => onSessoChanged('Femmina'),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // DATA DI NASCITA (Spostato sotto Sesso)
            _buildLabel('adozione_label_birthdate_indicative'.tr()),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                children: [
                  _buildDateDropdown(flex: 2, label: 'pets_date_day'.tr(), value: selectedDay, items: 31, offset: 1, onChanged: onDayChanged),
                  const SizedBox(width: 8),
                  _buildDateDropdown(flex: 2, label: 'pets_date_month'.tr(), value: selectedMonth, items: 12, offset: 1, onChanged: onMonthChanged),
                  const SizedBox(width: 8),
                  _buildDateDropdown(flex: 3, label: 'pets_date_year'.tr(), value: selectedYear, items: 25, isYear: true, onChanged: onYearChanged),
                ],
              ),
            ),

            // NOME
            _buildLabel('pet_label_name_upper'.tr()),
            _buildTextField(
              controller: nameController,
              hint: 'adozione_hint_name'.tr(),
              validator: null, // Tolto obbligo
            ),

            // RAZZA (Autocomplete intelligente con lista a comparsa)
            _buildLabel('adozione_label_razza'.tr()),
            _buildAutocompleteField(
              hint: selectedSpecie == null ? 'adozione_hint_select_species_first'.tr() : 'sos_add_breed_hint'.tr(),
              options: selectedSpecie == null ? [] : (razzePerSpecie[selectedSpecie] ?? []),
              initialValue: razzaController.text,
              onSelected: (val) {
                razzaController.text = val ?? '';
              },
              controller: razzaController,
            ),

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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(text, style: const TextStyle(color: darkBlue, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        validator: validator,
        style: const TextStyle(color: darkBlue, fontWeight: FontWeight.w600, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildDateDropdown({required int flex, required String label, required int? value, required int items, int offset = 0, bool isYear = false, required ValueChanged<int?> onChanged}) {
    return Expanded(
      flex: flex,
      child: DropdownButtonFormField<int>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 10, color: darkBlue),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        ),
        items: List.generate(items, (index) {
          final val = isYear ? DateTime.now().year - index : index + offset;
          return DropdownMenuItem(value: val, child: Text(val.toString(), style: const TextStyle(fontSize: 13, color: darkBlue)));
        }),
        onChanged: onChanged,
        validator: null, // Tolto obbligo
      ),
    );
  }

  Widget _buildAutocompleteField({
    required String hint,
    required List<String> options,
    String? initialValue,
    required ValueChanged<String?> onSelected,
    TextEditingController? controller,
  }) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        final text = textEditingValue.text.trim();
        if (text.isEmpty) return const Iterable<String>.empty();
        if (options.any((opt) => opt.toLowerCase() == text.toLowerCase())) {
          return const Iterable<String>.empty();
        }
        return options.where((String option) => option.toLowerCase().contains(text.toLowerCase()));
      },
      onSelected: (String selection) {
        onSelected(selection);
        FocusManager.instance.primaryFocus?.unfocus();
      },
      initialValue: TextEditingValue(text: initialValue ?? ''),
      fieldViewBuilder: (context, fieldController, focusNode, onFieldSubmitted) {
        if (controller != null && fieldController.text.isEmpty && controller.text.isNotEmpty) {
          fieldController.text = controller.text;
        }
        return TextFormField(
          controller: fieldController,
          focusNode: focusNode,
          onChanged: (val) => onSelected(val),
          style: const TextStyle(color: darkBlue, fontWeight: FontWeight.w600, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 10,
            borderRadius: BorderRadius.circular(15),
            child: Container(
              width: MediaQuery.of(context).size.width - 40,
              margin: const EdgeInsets.only(top: 5),
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: greenHope.withOpacity(0.3)),
              ),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade100),
                itemBuilder: (context, index) {
                  final String option = options.elementAt(index);
                  return ListTile(
                    visualDensity: VisualDensity.compact,
                    title: Text(option, style: const TextStyle(color: darkBlue, fontSize: 14, fontWeight: FontWeight.w500)),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: onPickImages,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: greenHope.withOpacity(0.5), width: 2),
        ),
        child: const Icon(Icons.add_a_photo, color: greenHope),
      ),
    );
  }

  Widget _buildImagePreview(int index) {
    return Stack(
      children: [
        GestureDetector(
          onTap: onFixImages,
          child: Container(
            width: 100,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(image: FileImage(selectedImages[index]), fit: BoxFit.cover),
            ),
          ),
        ),
        Positioned(
          top: 5,
          right: 17,
          child: GestureDetector(
            onTap: () => onRemoveImage(index),
            child: const CircleAvatar(radius: 10, backgroundColor: Colors.red, child: Icon(Icons.close, size: 12, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildSessoButton({required String label, required IconData icon, required bool isSelected, required Color activeColor, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? activeColor : Colors.transparent, width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? activeColor : Colors.grey),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: isSelected ? activeColor : Colors.grey, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
