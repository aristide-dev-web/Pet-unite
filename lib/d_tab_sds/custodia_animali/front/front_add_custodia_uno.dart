import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:petping/d_tab_sds/d_smarriti/a_home/category_selector.dart';
import 'package:petping/tipologie/tipologia.dart';
import 'package:petping/keyboard_cover.dart';

class FrontAddCustodiaUno extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController razzaController;
  final String? selectedSpecie;
  final Function(String?) onSpecieChanged;
  final String? selectedSesso;
  final Function(String?) onSessoChanged;
  final List<File> selectedImages;
  final VoidCallback onPickImages;
  final Function(int) onRemoveImage;
  final VoidCallback onNextStep;

  const FrontAddCustodiaUno({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.razzaController,
    this.selectedSpecie,
    required this.onSpecieChanged,
    this.selectedSesso,
    required this.onSessoChanged,
    required this.selectedImages,
    required this.onPickImages,
    required this.onRemoveImage,
    required this.onNextStep,
  });

  @override
  State<FrontAddCustodiaUno> createState() => _FrontAddCustodiaUnoState();
}

class _FrontAddCustodiaUnoState extends State<FrontAddCustodiaUno> {
  static const Color blueSecurity = Color(0xFF2980B9);
  static const Color darkText = Color(0xFF2C3E50);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showFoundInfoPopup(context));
  }

  void _showFoundInfoPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: Column(
          children: [
            const Icon(Icons.volunteer_activism_rounded, color: blueSecurity, size: 50),
            const SizedBox(height: 15),
            Text("custodia_thanks_help".tr(), style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2C3E50), fontSize: 18)),
          ],
        ),
        content: Text(
          "custodia_thanks_help_msg".tr(),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.grey),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: blueSecurity,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: Text("custodia_btn_got_it".tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeFormPage(
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("custodia_label_found_pet".tr(), Icons.pets_rounded),
            CategorySelector(
              selectedSpecies: widget.selectedSpecie,
              showAll: false,
              activeColor: blueSecurity,
              onSelected: (val) {
                if (val != widget.selectedSpecie) {
                  widget.onSpecieChanged(val);
                  widget.razzaController.clear();
                }
              },
              isSOS: true,
            ),
            
            const SizedBox(height: 30),
            _buildSectionTitle("custodia_label_found_photos".tr(), Icons.add_a_photo_rounded),
            const SizedBox(height: 15),
            _buildPhotoGrid(),

            const SizedBox(height: 30),
            _buildSectionTitle("custodia_label_gender".tr(), Icons.wc_rounded),
            const SizedBox(height: 10),
            Row(
              children: [
                _genderBtn("pet_label_male".tr().toUpperCase(), Icons.male, widget.selectedSesso == "Maschio", Colors.blue, () => widget.onSessoChanged("Maschio")),
                const SizedBox(width: 15),
                _genderBtn("pet_label_female".tr().toUpperCase(), Icons.female, widget.selectedSesso == "Femmina", Colors.pink, () => widget.onSessoChanged("Femmina")),
              ],
            ),

            const SizedBox(height: 30),
            _buildSectionTitle("custodia_label_name_tag".tr(), Icons.badge_outlined),
            const SizedBox(height: 12),
            _buildInput(widget.nameController, "custodia_hint_collar_name".tr(), Icons.drive_file_rename_outline_rounded, isRequired: false),
            
            const SizedBox(height: 25),
            _buildSectionTitle("custodia_label_breed_guess".tr(), Icons.category_rounded),
            _buildRazzaAutocomplete(),
            
            const SizedBox(height: 50),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: widget.onNextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: blueSecurity,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  elevation: 6,
                ),
                child: Text("custodia_btn_continue_saving".tr(), style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.2)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) => Padding(
    padding: const EdgeInsets.only(bottom: 10, left: 5),
    child: Row(
      children: [
        Icon(icon, size: 18, color: blueSecurity),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: blueSecurity, letterSpacing: 1)),
      ],
    ),
  );

  Widget _buildInput(TextEditingController controller, String hint, IconData icon, {bool isRequired = true}) => Container(
    decoration: BoxDecoration(
      color: Colors.white, 
      borderRadius: BorderRadius.circular(20), 
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: TextFormField(
      controller: controller,
      style: const TextStyle(fontWeight: FontWeight.bold, color: darkText, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.normal),
        prefixIcon: Icon(icon, color: blueSecurity, size: 20),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
      ),
      validator: isRequired ? (v) => v == null || v.isEmpty ? "error_required".tr() : null : null,
    ),
  );

  Widget _buildRazzaAutocomplete() {
    final List<String> options = razzePerSpecie[widget.selectedSpecie] ?? [];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20), 
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Autocomplete<String>(
        optionsBuilder: (textValue) {
          if (textValue.text.isEmpty || widget.selectedSpecie == null) return const Iterable<String>.empty();
          return options.where((o) => o.toLowerCase().contains(textValue.text.toLowerCase()));
        },
        onSelected: (selection) {
          widget.razzaController.text = selection;
          FocusScope.of(context).unfocus();
        },
        fieldViewBuilder: (context, ctrl, focus, onSubmitted) {
          if (widget.razzaController.text.isNotEmpty && ctrl.text.isEmpty) ctrl.text = widget.razzaController.text;
          return TextField(
            controller: ctrl,
            focusNode: focus,
            enabled: widget.selectedSpecie != null,
            style: const TextStyle(fontWeight: FontWeight.bold, color: darkText, fontSize: 14),
            decoration: InputDecoration(
              hintText: widget.selectedSpecie == null ? "ps_reg_hint_select_species".tr() : "sos_add_breed_hint".tr(),
              hintStyle: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.normal),
              prefixIcon: const Icon(Icons.search_rounded, color: blueSecurity, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
            ),
          );
        },
      ),
    );
  }

  Widget _genderBtn(String label, IconData icon, bool isSel, Color color, VoidCallback onTap) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSel ? blueSecurity : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSel ? blueSecurity : Colors.grey.shade200, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSel ? Colors.white : Colors.grey, size: 20),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(color: isSel ? Colors.white : Colors.grey, fontWeight: FontWeight.w900, fontSize: 12)),
          ],
        ),
      ),
    ),
  );

  Widget _buildPhotoGrid() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ...widget.selectedImages.asMap().entries.map((e) => Stack(
          children: [
            Container(
              width: 85, height: 85,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(image: FileImage(e.value), fit: BoxFit.cover),
              ),
            ),
            Positioned(
              right: 0, top: 0,
              child: GestureDetector(
                onTap: () => widget.onRemoveImage(e.key), 
                child: const CircleAvatar(radius: 12, backgroundColor: Colors.red, child: Icon(Icons.close, color: Colors.white, size: 14))
              )
            ),
          ],
        )),
        if (widget.selectedImages.length < 5)
          GestureDetector(
            onTap: widget.onPickImages,
            child: Container(
              width: 85, height: 85,
              decoration: BoxDecoration(
                color: Colors.white, 
                borderRadius: BorderRadius.circular(20), 
                border: Border.all(color: blueSecurity.withOpacity(0.3), width: 2),
              ),
              child: const Icon(Icons.add_a_photo_outlined, color: blueSecurity, size: 30),
            ),
          ),
      ],
    );
  }
}
