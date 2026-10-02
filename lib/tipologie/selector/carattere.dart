import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

final List<String> caratteriAnimale = [
  'pet_char_docile',
  'pet_char_timid',
  'pet_char_aggressive',
  'pet_char_playful',
  'pet_char_curious',
  'pet_char_energetic',
  'pet_char_lazy',
  'pet_char_protective',
  'pet_char_independent',
  'pet_char_sociable',
  'pet_char_anxious',
  'pet_char_balanced',
  'pet_char_diffident',
  'pet_char_affectionate',
  'pet_char_territorial',
];

class CarattereSelector extends StatefulWidget {
  final TextEditingController controller;

  const CarattereSelector({
    super.key,
    required this.controller,
  });

  @override
  State<CarattereSelector> createState() => _CarattereSelectorState();
}

class _CarattereSelectorState extends State<CarattereSelector> {
  List<String> selezionati = [];

  @override
  void initState() {
    super.initState();
    if (widget.controller.text.isNotEmpty) {
      selezionati = widget.controller.text.split(', ');
    }
  }

  void _aggiornaController() {
    widget.controller.text = selezionati.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Campo scrivibile
        TextFormField(
          controller: widget.controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "pet_character_label".tr(),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            suffixIcon: const Icon(Icons.arrow_drop_down),
          ),
          onChanged: (value) {
            selezionati = value.split(', ').where((e) => e.trim().isNotEmpty).toList();
          },
          readOnly: true,
          onTap: () => _apriPopup(context),
        ),
      ],
    );
  }

  void _apriPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("pet_character_select_title".tr()),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              children: caratteriAnimale.map((c) {
                final isSelected = selezionati.contains(c.tr());
                return StatefulBuilder(builder: (context, setDialogState) {
                  return CheckboxListTile(
                    title: Text(c.tr()),
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          selezionati.add(c.tr());
                        } else {
                          selezionati.remove(c.tr());
                        }
                        _aggiornaController();
                      });
                      setDialogState(() {});
                    },
                  );
                });
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("btn_close".tr()),
            ),
          ],
        );
      },
    );
  }
}