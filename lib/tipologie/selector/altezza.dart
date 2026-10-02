import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

/// ------------------------------
/// TAGLIA VETERINARIA UFFICIALE
/// ------------------------------

final List<String> taglieVeterinarie = [
  'Toy',
  'Piccola',
  'Media',
  'Grande',
  'Gigante',
];

/// ------------------------------
/// STRUTTURA CORPOREA (opzionale)
/// ------------------------------

final List<String> strutturaCorporea = [
  'Snello',
  'Normale',
  'Robusto',
  'Sovrappeso',
  'Molto muscoloso',
];

/// ------------------------------
/// SELETTORE TAGLIA VETERINARIA
/// ------------------------------

class TagliaVeterinariaSelector extends StatelessWidget {
  final TextEditingController controller;

  const TagliaVeterinariaSelector({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: controller.text.isEmpty ? null : controller.text,
      decoration: InputDecoration(
        hintText: "profile_select_placeholder".tr(),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: taglieVeterinarie.map((t) {
        return DropdownMenuItem(
          value: t,
          child: Text(t),
        );
      }).toList(),
      onChanged: (value) {
        controller.text = value ?? '';
      },
    );
  }
}

/// ------------------------------
/// SELETTORE STRUTTURA CORPOREA
/// ------------------------------

class StrutturaCorporeaSelector extends StatelessWidget {
  final TextEditingController controller;

  const StrutturaCorporeaSelector({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: controller.text.isEmpty ? null : controller.text,
      decoration: InputDecoration(
        hintText: "body_structure_label".tr(),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: strutturaCorporea.map((s) {
        return DropdownMenuItem(
          value: s,
          child: Text(s),
        );
      }).toList(),
      onChanged: (value) {
        controller.text = value ?? '';
      },
    );
  }
}

/// ------------------------------
/// SELETTORE ALTEZZA (cm)
/// ------------------------------

class AltezzaSelector extends StatelessWidget {
  final TextEditingController controller;
  final String? label;

  const AltezzaSelector({
    super.key,
    required this.controller,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: "profile_select_placeholder".tr(),
        hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        suffixIcon: IconButton(
          icon: const Icon(Icons.straighten),
          onPressed: () async {
            final value = await showDialog<double>(
              context: context,
              builder: (context) => _AltezzaDialog(initial: controller.text),
            );

            if (value != null) {
              controller.text = value.toStringAsFixed(1);
            }
          },
        ),
      ),
    );
  }
}

class _AltezzaDialog extends StatefulWidget {
  final String initial;

  const _AltezzaDialog({required this.initial});

  @override
  State<_AltezzaDialog> createState() => _AltezzaDialogState();
}

class _AltezzaDialogState extends State<_AltezzaDialog> {
  double altezza = 30.0;

  @override
  void initState() {
    super.initState();
    if (double.tryParse(widget.initial) != null) {
      altezza = double.parse(widget.initial);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("height_select_title".tr()),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("${altezza.toStringAsFixed(1)} cm",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Slider(
            value: altezza,
            min: 1,
            max: 250,
            divisions: 2490,
            label: "${altezza.toStringAsFixed(1)} cm",
            onChanged: (v) => setState(() => altezza = v),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("btn_cancel".tr()),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, altezza),
          child: Text("profile_btn_confirm".tr()),
        ),
      ],
    );
  }
}