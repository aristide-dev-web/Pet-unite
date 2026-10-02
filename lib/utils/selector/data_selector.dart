import 'package:flutter/material.dart';

class DataSelector extends StatelessWidget {
  final String label;
  final String selectedDate;
  final void Function(String) onChanged;

  const DataSelector({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final data = await showDatePicker(
          context: context,
          initialDate: DateTime.tryParse(selectedDate) ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (data != null) {
          onChanged(data.toIso8601String().split('T').first);
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          controller: TextEditingController(text: selectedDate),
          decoration: InputDecoration(labelText: label),
        ),
      ),
    );
  }
}