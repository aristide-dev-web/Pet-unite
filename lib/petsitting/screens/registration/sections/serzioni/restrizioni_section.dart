import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'shared_servizi_widgets.dart';

class RestrizioniSection extends StatefulWidget {
  final List<String> razzeEscluse;
  final List<String> comportamentiEsclusi;
  final Function(String) onRazzaAggiunta;
  final Function(String) onRazzaRimossa;
  final Function(String) onComportamentoAggiunto;
  final Function(String) onComportamentoRimosso;

  const RestrizioniSection({
    super.key,
    required this.razzeEscluse,
    required this.comportamentiEsclusi,
    required this.onRazzaAggiunta,
    required this.onRazzaRimossa,
    required this.onComportamentoAggiunto,
    required this.onComportamentoRimosso,
  });

  @override
  State<RestrizioniSection> createState() => _RestrizioniSectionState();
}

class _RestrizioniSectionState extends State<RestrizioniSection> {
  final TextEditingController _razzaController = TextEditingController();
  final TextEditingController _comportamentoController = TextEditingController();

  final Color accentColor = const Color(0xFF475569);
  final Color cardBg = const Color(0xFFF1F5F9);

  @override
  void dispose() {
    _razzaController.dispose();
    _comportamentoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: cardBg, width: 4),
        boxShadow: [BoxShadow(color: accentColor.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [accentColor, accentColor.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.gpp_maybe_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 15),
              Text("ps_reg_rest_header".tr().toUpperCase(), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: accentColor, letterSpacing: 1.2)),
            ],
          ),
          const SizedBox(height: 30),
          _buildInputList(
            label: "ps_reg_rest_breeds_label".tr(),
            hint: "ps_reg_rest_breeds_hint".tr(),
            controller: _razzaController,
            items: widget.razzeEscluse,
            onAdd: widget.onRazzaAggiunta,
            onRemove: widget.onRazzaRimossa,
          ),
          const SizedBox(height: 35),
          _buildInputList(
            label: "ps_reg_rest_behaviors_label".tr(),
            hint: "ps_reg_rest_behaviors_hint".tr(),
            controller: _comportamentoController,
            items: widget.comportamentiEsclusi,
            onAdd: widget.onComportamentoAggiunto,
            onRemove: widget.onComportamentoRimosso,
          ),
        ],
      ),
    );
  }

  Widget _buildInputList({
    required String label,
    required String hint,
    required TextEditingController controller,
    required List<String> items,
    required Function(String) onAdd,
    required Function(String) onRemove,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: SharedServiziWidgets.secondaryTextColor, letterSpacing: 1.1)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                style: const TextStyle(fontWeight: FontWeight.w600, color: SharedServiziWidgets.textColor, fontSize: 14),
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(fontSize: 13, color: SharedServiziWidgets.secondaryTextColor.withOpacity(0.4)),
                  filled: true,
                  fillColor: SharedServiziWidgets.bgLight,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                if (controller.text.isNotEmpty) {
                  onAdd(controller.text.trim());
                  controller.clear();
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor, 
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: accentColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                ),
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
              ),
            ),
          ],
        ),
        if (items.isNotEmpty) ...[
          const SizedBox(height: 15),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accentColor.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(item, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: accentColor)),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => onRemove(item),
                    child: Icon(Icons.close_rounded, size: 16, color: accentColor.withOpacity(0.5)),
                  ),
                ],
              ),
            )).toList(),
          ),
        ],
      ],
    );
  }
}
