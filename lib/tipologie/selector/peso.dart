import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class PesoSelector extends StatelessWidget {
  final TextEditingController controller;
  final String? label;

  const PesoSelector({
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
        hintText: label ?? 'pet_label_weight'.tr(),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        suffixIcon: IconButton(
          icon: const Icon(Icons.calculate),
          onPressed: () async {
            final value = await showDialog<double>(
              context: context,
              builder: (context) => _PesoDialog(initial: controller.text),
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

class _PesoDialog extends StatefulWidget {
  final String initial;

  const _PesoDialog({required this.initial});

  @override
  State<_PesoDialog> createState() => _PesoDialogState();
}

class _PesoDialogState extends State<_PesoDialog> {
  double peso = 5.0;

  @override
  void initState() {
    super.initState();
    if (double.tryParse(widget.initial) != null) {
      peso = double.parse(widget.initial);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('peso_select_title'.tr()),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("${peso.toStringAsFixed(1)} kg",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Slider(
            value: peso,
            min: 0.1,
            max: 200,
            divisions: 2000,
            label: "${peso.toStringAsFixed(1)} kg",
            onChanged: (v) => setState(() => peso = v),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('btn_cancel'.tr()),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, peso),
          child: Text('profile_btn_confirm'.tr()),
        ),
      ],
    );
  }
}