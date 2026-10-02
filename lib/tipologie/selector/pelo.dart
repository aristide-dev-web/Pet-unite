import 'package:flutter/material.dart';

/// LISTA GRANDEZZE PELO
final List<String> grandezzePelo = [
  'Corto',
  'Medio',
  'Lungo',
  'Molto lungo',
  'Raso',
  'Semi-lungo',
];

/// LISTA TIPI DI PELO
final List<String> tipiPelo = [
  'Liscio',
  'Riccio',
  'Ondulato',
  'Setoso',
  'Ruvido',
  'Duro',
  'Morbido',
  'Doppio strato',
  'Lanoso',
  'Spinoso',
  'Crespo',
  'Senza pelo',
  'Ibrido',
];

class CustomModernSelector extends StatelessWidget {
  final TextEditingController controller;
  final List<String> options;
  final String hint;
  final bool isDark; // AGGIUNTO

  const CustomModernSelector({
    super.key,
    required this.controller,
    required this.options,
    this.hint = "Seleziona",
    this.isDark = true, // Default scuro
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor = isDark ? Colors.white : const Color(0xFF4E342E);
    final Color hintColor = isDark ? Colors.white38 : Colors.grey;
    final Color iconColor = isDark ? Colors.white70 : const Color(0xFFC5A059);
    final Color dropdownBg = isDark ? const Color(0xFF1A1A1A) : Colors.white;

    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: dropdownBg,
      ),
      child: DropdownButtonFormField<String>(
        value: controller.text.isEmpty ? null : (options.contains(controller.text) ? controller.text : null),
        isExpanded: true,
        alignment: Alignment.centerLeft,
        dropdownColor: dropdownBg,
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: iconColor, size: 22),
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15),
        borderRadius: BorderRadius.circular(20),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: hintColor, fontSize: 14, fontWeight: FontWeight.normal),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        ),
        selectedItemBuilder: (BuildContext context) {
          return options.map<Widget>((String item) {
            return Container(
              alignment: Alignment.centerLeft,
              child: Text(item, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15), overflow: TextOverflow.ellipsis),
            );
          }).toList();
        },
        items: options.map((String p) {
          return DropdownMenuItem(
            value: p,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(p, style: TextStyle(color: textColor, fontSize: 14)),
            ),
          );
        }).toList(),
        onChanged: (value) {
          controller.text = value ?? '';
        },
      ),
    );
  }
}

/// SELETTORE GRANDEZZA PELO
class PeloGrandezzaSelector extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;

  const PeloGrandezzaSelector({
    super.key,
    required this.controller,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomModernSelector(controller: controller, options: grandezzePelo, isDark: isDark);
  }
}

/// SELETTORE TIPO DI PELO (Solo scelta)
class TipoPeloSelector extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;

  const TipoPeloSelector({
    super.key,
    required this.controller,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomModernSelector(controller: controller, options: tipiPelo, isDark: isDark);
  }
}

/// NOTE SUL PELO
class PeloNoteField extends StatelessWidget {
  final TextEditingController controller;

  const PeloNoteField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: 3,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: "Aggiungi note...",
        hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
        filled: true,
        fillColor: Colors.black26,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
