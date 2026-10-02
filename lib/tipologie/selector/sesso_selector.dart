import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class SessoSelector extends StatelessWidget {
  final String selected;
  final void Function(String) onChanged;

  const SessoSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('profile_label_gender'.tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: selected == 'Maschio' ? Colors.blue : Colors.grey[300],
                  foregroundColor: selected == 'Maschio' ? Colors.white : Colors.black,
                ),
                onPressed: () => onChanged('Maschio'),
                icon: const Icon(Icons.male),
                label: Text('gender_male'.tr()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: selected == 'Femmina' ? Colors.pink : Colors.grey[300],
                  foregroundColor: selected == 'Femmina' ? Colors.white : Colors.black,
                ),
                onPressed: () => onChanged('Femmina'),
                icon: const Icon(Icons.female),
                label: Text('gender_female'.tr()),
              ),
            ),
          ],
        ),
      ],
    );
  }
}