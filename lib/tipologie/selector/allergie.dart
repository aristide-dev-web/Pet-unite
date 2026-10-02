import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class AllergieSelector extends StatefulWidget {
  final TextEditingController statoController;   // Sì / No
  final TextEditingController allergieController; // Lista allergie scritte

  const AllergieSelector({
    super.key,
    required this.statoController,
    required this.allergieController,
  });

  @override
  State<AllergieSelector> createState() => _AllergieSelectorState();
}

class _AllergieSelectorState extends State<AllergieSelector> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// Dropdown Allergico Sì/No
        DropdownButtonFormField<String>(
          value: widget.statoController.text.isEmpty
              ? null
              : widget.statoController.text,
          decoration: InputDecoration(
            hintText: "profile_select_placeholder".tr(),
            hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: [
            DropdownMenuItem(value: "Sì", child: Text("yes".tr())),
            DropdownMenuItem(value: "No", child: Text("no".tr())),
          ],
          onChanged: (value) {
            widget.statoController.text = value ?? '';

            if (value == "No") {
              widget.allergieController.clear();
            }

            setState(() {});
          },
        ),

        const SizedBox(height: 12),

        /// Campo "A cosa è allergico?" se Sì
        if (widget.statoController.text == "Sì")
          TextFormField(
            controller: widget.allergieController,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "pet_label_allergic_question".tr(),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
      ],
    );
  }
}