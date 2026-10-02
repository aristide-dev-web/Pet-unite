import 'package:flutter/material.dart';

class NoteGeneraliSelector extends StatelessWidget {
  final TextEditingController controller;

  const NoteGeneraliSelector({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: 5,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: " (comportamento, salute, abitudini...)",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}