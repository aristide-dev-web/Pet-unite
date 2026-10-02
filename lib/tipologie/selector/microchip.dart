import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class MicrochipSelector extends StatefulWidget {
  final TextEditingController statoController;
  final TextEditingController numeroController;

  const MicrochipSelector({
    super.key,
    required this.statoController,
    required this.numeroController,
  });

  @override
  State<MicrochipSelector> createState() => _MicrochipSelectorState();
}

class _MicrochipSelectorState extends State<MicrochipSelector> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 20), // leggero spostamento
          child: Align(
            alignment: Alignment.centerLeft, // resta a sinistra, ma con offset
            child: Text(
              "microchip_fundamental_desc".tr(),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),
          ),
        ),

        DropdownButtonFormField<String>(
          value: widget.statoController.text.isEmpty ? null : widget.statoController.text,
          decoration: InputDecoration(
            hintText: "profile_select_placeholder".tr(),
            hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
          ),
          items: [
            DropdownMenuItem(value: "Sì", child: Text("yes".tr())),
            DropdownMenuItem(value: "No", child: Text("no".tr())),
          ],
          onChanged: (value) {
            setState(() {
              widget.statoController.text = value ?? '';
              if (value == "No") widget.numeroController.clear();
            });
          },
        ),

        if (widget.statoController.text == "Sì") ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: widget.numeroController,
            decoration: InputDecoration(
              hintText: "pet_label_microchip_num".tr(),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
            ),
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ],
    );
  }
}
