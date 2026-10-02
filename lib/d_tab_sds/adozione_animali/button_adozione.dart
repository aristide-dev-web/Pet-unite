import 'package:flutter/material.dart';
import 'search_adozione_animals_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class ButtonAdozione extends StatelessWidget {
  const ButtonAdozione({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.favorite),
      label: Text('adozione_search_btn'.tr()),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: const TextStyle(fontSize: 16),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SearchAdozioneAnimalsScreen(),
          ),
        );
      },
    );
  }
}