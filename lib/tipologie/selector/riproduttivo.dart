import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

/// Stato riproduttivo semplificato
final List<String> statiRiproduttivi = [
  'yes', // Verrà tradotto come "Sì"
  'no',  // Verrà tradotto come "No"
  'not_known',
];

class StatoRiproduttivoSelector extends StatefulWidget {
  final TextEditingController controller;

  const StatoRiproduttivoSelector({
    super.key,
    required this.controller,
  });

  @override
  State<StatoRiproduttivoSelector> createState() => _StatoRiproduttivoSelectorState();
}

class _StatoRiproduttivoSelectorState extends State<StatoRiproduttivoSelector> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      readOnly: true,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: "select_label".tr(),
        hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.white),
      ),
      onTap: () => _apriPopup(context),
    );
  }

  void _apriPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            "reproductive_status_upper".tr(),
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: statiRiproduttivi.map((s) {
                return ListTile(
                  title: Text(s.tr(), style: const TextStyle(color: Colors.white)),
                  trailing: widget.controller.text == s.tr()
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : null,
                  onTap: () {
                    setState(() {
                      widget.controller.text = s.tr();
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
