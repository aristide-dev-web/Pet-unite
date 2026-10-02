import 'package:flutter/material.dart';
import 'package:petping/tipologie/selector/pelo.dart'; // Import per CustomModernSelector

/// ------------------------------
/// LISTE CODA
/// ------------------------------

final List<String> grandezzaCoda = [
  'Piccola',
  'Media',
  'Grande',
  'Molto grande',
  'Non ce l’ha',
];

final List<String> tipoCoda = [
  'Dritta',
  'Arricciata',
  'A ricciolo',
  'A pennello',
  'A frusta',
  'Mozza',
  'Sottile',
  'Spessa',
  'Non ce l’ha',
];

/// ------------------------------
/// LISTE ORECCHIE
/// ------------------------------

final List<String> grandezzaOrecchie = [
  'Piccole',
  'Medie',
  'Grandi',
  'Molto grandi',
  'Non ce l’ha',
];

final List<String> tipoOrecchie = [
  'Erette',
  'Pendenti',
  'A punta',
  'Arrotondate',
  'Lunghe',
  'Corte',
  'Tagliate',
  'A pipistrello',
  'A triangolo',
  'Non ce l’ha',
];

/// ------------------------------
/// CODA
/// ------------------------------

class CodaGrandezzaSelector extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;

  const CodaGrandezzaSelector({
    super.key, 
    required this.controller,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomModernSelector(
      controller: controller,
      options: grandezzaCoda,
      isDark: isDark,
    );
  }
}

class CodaTipoSelector extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;

  const CodaTipoSelector({
    super.key, 
    required this.controller,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomModernSelector(
      controller: controller,
      options: tipoCoda,
      isDark: isDark,
    );
  }
}

/// ------------------------------
/// ORECCHIE
/// ------------------------------

class OrecchieGrandezzaSelector extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;

  const OrecchieGrandezzaSelector({
    super.key, 
    required this.controller,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomModernSelector(
      controller: controller,
      options: grandezzaOrecchie,
      isDark: isDark,
    );
  }
}

class OrecchieTipoSelector extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;

  const OrecchieTipoSelector({
    super.key, 
    required this.controller,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomModernSelector(
      controller: controller,
      options: tipoOrecchie,
      isDark: isDark,
    );
  }
}
