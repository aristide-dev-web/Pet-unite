import 'package:flutter/material.dart';
import 'package:petping/tipologie/selector/pelo.dart'; // Import per CustomModernSelector

final List<String> coloriAnimali = [
  // I PIÙ COMUNI
  'Nero',
  'Bianco',
  'Marrone',
  'Grigio',
  'Beige',
  'Crema',
  'Fulvo',
  'Rosso',
  'Arancione',
  
  // FANTASIE COMUNI
  'Tricolore',
  'Bicolore',
  'Pezzato',
  'Tigrato',
  'Striato',
  'Maculato',
  'Zebrato',
  
  // COLORI SPECIFICI / MENO COMUNI
  'Cioccolato',
  'Blu',
  'Lilla',
  'Fumo',
  'Argento',
  'Dorato',
  'Sabbia',
  'Miele',
  'Cannella',
  'Testa di moro',
  'Isabella',
  'Biondo',
  'Azzurro',
];

class ColoreSelector extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isDark;

  const ColoreSelector({
    super.key,
    required this.controller,
    required this.label,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomModernSelector(
      controller: controller,
      options: coloriAnimali,
      hint: label,
      isDark: isDark,
    );
  }
}
