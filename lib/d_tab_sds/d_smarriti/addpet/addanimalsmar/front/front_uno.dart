import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:petping/tipologie/tipologia.dart';
import 'package:petping/d_tab_sds/d_smarriti/a_home/category_selector.dart';

class AddUnoFront extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController razzaController;
  final String? selectedSpecie;
  final ValueChanged<String?> onSpecieChanged;
  final String? selectedSesso;
  final ValueChanged<String?> onSessoChanged;
  final List<File> selectedImages;
  final VoidCallback onPickImages;
  final Function(int) onRemoveImage;
  final VoidCallback onNextStep;
  final VoidCallback onFixImages;

  static const Color vintageGold = Color(0xFFC5A059);
  static const Color darkBrown = Color(0xFF4E342E);
  static const Color parchment = Color(0xFFFEFAE0);

  const AddUnoFront({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.razzaController,
    required this.selectedSpecie,
    required this.onSpecieChanged,
    required this.selectedSesso,
    required this.onSessoChanged,
    required this.selectedImages,
    required this.onPickImages,
    required this.onRemoveImage,
    required this.onNextStep,
    required this.onFixImages,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('sos_add_pet_type'.tr(), Icons.pets_rounded),
          CategorySelector(
            selectedSpecies: selectedSpecie,
            onSelected: onSpecieChanged,
            showAll: true,
            activeColor: vintageGold,
            isSOS: true, // Attivato filtro SOS
          ),
          const SizedBox(height: 25),

          // GALLERIA MULTI-FOTO
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLabel('sos_add_gallery'.tr(), Icons.photo_library_rounded),
              if (selectedImages.isNotEmpty)
                GestureDetector(
                  onTap: onFixImages,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8, right: 10),
                    child: Text(
                      "sos_add_btn_manage_photos".tr(),
                      style: const TextStyle(color: vintageGold, fontWeight: FontWeight.w900, fontSize: 10),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              "sos_add_gallery_sub".tr(),
              style: const TextStyle(color: darkBrown, fontSize: 11, fontStyle: FontStyle.italic, fontWeight: FontWeight.w500),
            ),
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
          _buildLabel('sos_add_gender'.tr(), Icons.wc_rounded),
          Row(
            children: [
              _buildSessoButton(
                label: 'pet_label_male'.tr().toUpperCase(),
                icon: Icons.male_rounded,
                isSelected: selectedSesso == 'Maschio',
                activeColor: Colors.blue.shade400,
                onTap: () => onSessoChanged('Maschio'),
              ),
              const SizedBox(width: 12),
              _buildSessoButton(
                label: 'pet_label_female'.tr().toUpperCase(),
                icon: Icons.female_rounded,
                isSelected: selectedSesso == 'Femmina',
                activeColor: Colors.pink.shade300,
                onTap: () => onSessoChanged('Femmina'),
              ),
            ],
          ),
          const SizedBox(height: 25),

          // NOME
          _buildLabel('sos_add_pet_name'.tr(), Icons.badge_rounded),
          _buildTextField(
            controller: nameController,
            hint: 'sos_add_pet_name_hint'.tr(),
            validator: (value) => value!.isEmpty ? 'error_required'.tr() : null,
          ),
          const SizedBox(height: 20),

          // RAZZA
          _buildLabel('pet_label_breed'.tr().toUpperCase(), Icons.category_rounded),
          _buildAutocompleteField(
            hint: 'sos_add_breed_hint'.tr(),
            options: razzePerSpecie[selectedSpecie] ?? [],
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
              onPressed: onNextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: darkBrown,
                foregroundColor: parchment,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 5,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('sos_add_btn_next'.tr(), style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                  const SizedBox(width: 10),
                  const Icon(Icons.arrow_forward_rounded),
                ],
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
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
        if (text.isEmpty) {
          return const Iterable<String>.empty();
        }
        if (options.any((opt) => opt.toLowerCase() == text.toLowerCase())) {
          return const Iterable<String>.empty();
        }
        return options.where((String option) {
          return option.toLowerCase().contains(text.toLowerCase());
        });
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
          scrollPadding: const EdgeInsets.only(bottom: 120),
          style: const TextStyle(color: darkBrown, fontWeight: FontWeight.w600),
          decoration: _inputDecoration(hint),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 10,
            borderRadius: BorderRadius.circular(15),
            child: Container(
              width: MediaQuery.of(context).size.width - 80,
              margin: const EdgeInsets.only(top: 5), 
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: vintageGold.withOpacity(0.3)),
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
                    title: Text(option, style: const TextStyle(color: darkBrown, fontSize: 14, fontWeight: FontWeight.w500)),
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
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: vintageGold.withOpacity(0.5), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_a_photo_rounded, color: vintageGold, size: 30),
            const SizedBox(height: 4),
            Text('home_btn_add'.tr().toUpperCase(), style: const TextStyle(color: vintageGold, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(int index) {
    return Stack(
      children: [
        GestureDetector(
          onTap: onFixImages, // Cliccando sulla foto si apre il FixPhoto
          child: Container(
            width: 100,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: vintageGold.withOpacity(0.2)),
              image: DecorationImage(image: FileImage(selectedImages[index]), fit: BoxFit.cover),
            ),
          ),
        ),
        Positioned(
          top: 5,
          right: 17,
          child: GestureDetector(
            onTap: () => onRemoveImage(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
              child: const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: vintageGold),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: darkBrown, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.0)),
        ],
      ),
    );
  }

  Widget _buildSessoButton({required String label, required IconData icon, required bool isSelected, required Color activeColor, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withOpacity(0.15) : Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? activeColor : darkBrown.withOpacity(0.1), width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isSelected ? activeColor : darkBrown.withOpacity(0.4)),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: isSelected ? activeColor : darkBrown.withOpacity(0.6), fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: darkBrown.withOpacity(0.3), fontSize: 14),
      filled: true,
      fillColor: Colors.white.withOpacity(0.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: darkBrown.withOpacity(0.1))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: vintageGold, width: 2)),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, String? Function(String?)? validator, double bottomPadding = 12}) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: TextFormField(
        controller: controller, 
        validator: validator, 
        scrollPadding: const EdgeInsets.only(bottom: 80),
        style: const TextStyle(color: darkBrown, fontWeight: FontWeight.w600), 
        decoration: _inputDecoration(hint)
      ),
    );
  }
}
