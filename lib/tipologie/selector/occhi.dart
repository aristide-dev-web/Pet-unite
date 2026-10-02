import 'package:flutter/material.dart';
import 'package:petping/tipologie/selector/pelo.dart'; // Import per CustomModernSelector

/// ------------------------------
/// LISTA COLORI OCCHI
/// ------------------------------

final List<String> coloriOcchi = [
  'Marrone',
  'Nero',
  'Ambra',
  'Azzurro',
  'Verde',
  'Giallo',
  'Heterocromia',
  'Grigio',
];

/// ------------------------------
/// LISTA FORME OCCHI
/// ------------------------------

final List<String> formeOcchi = [
  'Rotondi',
  'A mandorla',
  'Grandi',
  'Piccoli',
  'Sporgenti',
  'Profondi',
  'Obliqui',
];

/// ------------------------------
/// SELETTORE COLORE OCCHI
/// ------------------------------

class OcchiColoreSelector extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final bool isDark;

  const OcchiColoreSelector({
    super.key,
    required this.controller,
    this.label,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomModernSelector(
      controller: controller,
      options: coloriOcchi,
      hint: label ?? "Seleziona",
      isDark: isDark,
    );
  }
}

/// ------------------------------
/// SELETTORE FORMA OCCHI
/// ------------------------------

class OcchiFormaSelector extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;

  const OcchiFormaSelector({
    super.key,
    required this.controller,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomModernSelector(
      controller: controller,
      options: formeOcchi,
      isDark: isDark,
    );
  }
}
