import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class VaccinatoSelector extends StatelessWidget {
  final TextEditingController controller;

  const VaccinatoSelector({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: controller.text.isEmpty ? null : controller.text,
      decoration: InputDecoration(
        hintText: "profile_select_placeholder".tr(),
        hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: [
        DropdownMenuItem(value: "Sì", child: Text("yes".tr())),
        DropdownMenuItem(value: "No", child: Text("no".tr())),
      ],
      onChanged: (value) {
        controller.text = value ?? '';
      },
    );
  }
}