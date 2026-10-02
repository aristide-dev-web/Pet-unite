import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';

class SharedServiziWidgets {
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color textColor = Color(0xFF1E293B);
  static const Color secondaryTextColor = Color(0xFF64748B);
  static const Color accentColor = Color(0xFF10B981);
  static const Color indigoColor = Color(0xFF6366F1);

  static final Map<String, Map<String, dynamic>> taglieInfo = {
    'XS': {'label': 'XS (0kg - 5kg)', 'icon': 'assets/images/xs.png', 'size': 20.0},
    'S': {'label': 'S (5kg - 10kg)', 'icon': 'assets/images/s.png', 'size': 30.0},
    'M': {'label': 'M (10kg - 25kg)', 'icon': 'assets/images/media.png', 'size': 50.0},
    'L': {'label': 'L (25kg - 45kg)', 'icon': 'assets/images/grande.png', 'size': 62.0},
    'XL': {'label': 'XL (45kg+)', 'icon': 'assets/images/xl.png', 'size': 75.0},
  };

  static Widget buildSubLabel(String text, {String? helpText, IconData? icon}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: secondaryTextColor.withOpacity(0.6)),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(text.toUpperCase(), 
            style: TextStyle(
              fontWeight: FontWeight.w900, 
              fontSize: 10, 
              color: secondaryTextColor.withOpacity(0.8), 
              letterSpacing: 1.3
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (helpText != null) ...[
          const SizedBox(width: 6),
          Tooltip(
            message: helpText,
            triggerMode: TooltipTriggerMode.tap,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: textColor.withOpacity(0.9), borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(color: Colors.white, fontSize: 11),
            child: Icon(Icons.help_outline_rounded, size: 14, color: secondaryTextColor.withOpacity(0.4)),
          ),
        ],
      ],
    );
  }

  static Widget buildNumberField({
    required String title,
    required TextEditingController controller,
    required Function(String) onChanged,
    bool isPerc = false,
    VoidCallback? onHelpTap,
    IconData? prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            TextInputFormatter.withFunction((oldValue, newValue) {
              final text = newValue.text.replaceAll(',', '.');
              return newValue.copyWith(text: text);
            }),
          ],
          onChanged: (v) => onChanged(v.replaceAll(',', '.')),
          style: const TextStyle(fontWeight: FontWeight.w800, color: textColor, fontSize: 15),
          decoration: InputDecoration(
            labelText: title.toUpperCase(),
            labelStyle: TextStyle(fontSize: 10, color: secondaryTextColor.withOpacity(0.6), fontWeight: FontWeight.w900, letterSpacing: 1),
            prefixIcon: Icon(prefixIcon ?? (isPerc ? Icons.percent_rounded : Icons.euro_symbol_rounded), size: 16, color: indigoColor.withOpacity(0.7)),
            suffixIcon: onHelpTap != null 
              ? IconButton(
                  onPressed: onHelpTap, 
                  icon: Icon(Icons.help_outline_rounded, size: 18, color: secondaryTextColor.withOpacity(0.3))
                ) 
              : null,
            filled: true,
            fillColor: bgLight,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: indigoColor.withOpacity(0.3), width: 2)),
          ),
        ),
      ],
    );
  }

  static Widget buildCounterField({
    required String label,
    required int current,
    required Function(int) onMaxAnimaliChanged,
    IconData? icon,
  }) {
    bool isUnlimited = current == 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgLight, 
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100)
      ),
      child: Row(
        children: [
          Expanded(
            child: buildSubLabel(
              "ps_reg_serv_max_cap".tr(), 
              helpText: "ps_reg_serv_max_cap_help".tr(),
              icon: icon ?? Icons.group_rounded
            )
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2))]
            ),
            child: Row(
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  onPressed: isUnlimited ? null : () {
                    if (current == 1) {
                      onMaxAnimaliChanged(0);
                    } else {
                      onMaxAnimaliChanged(current - 1);
                    }
                  }, 
                  icon: Icon(Icons.remove_rounded, 
                    color: isUnlimited ? Colors.grey.shade300 : Colors.redAccent, 
                    size: 20
                  )
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  constraints: const BoxConstraints(minWidth: 100),
                  child: Center(
                    child: Text(
                      isUnlimited ? "ps_reg_radius_no_limit".tr().toUpperCase() : "$current", 
                      style: TextStyle(
                        fontSize: isUnlimited ? 10 : 16, 
                        fontWeight: FontWeight.w900, 
                        color: isUnlimited ? indigoColor : textColor,
                        letterSpacing: isUnlimited ? 0.5 : 0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  onPressed: (current >= 10 && !isUnlimited) ? null : () {
                    if (isUnlimited) {
                      onMaxAnimaliChanged(1);
                    } else {
                      onMaxAnimaliChanged(current + 1);
                    }
                  },
                  icon: Icon(Icons.add_rounded, 
                    color: (current >= 10 && !isUnlimited) ? Colors.grey.shade300 : accentColor, 
                    size: 20
                  )
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildNoteField({
    required TextEditingController controller,
    required Function(String) onNoteChanged,
    String? label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSubLabel(label ?? "ps_reg_serv_notes_label".tr(), icon: Icons.notes_rounded),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          maxLines: null,
          minLines: 3,
          keyboardType: TextInputType.multiline,
          textCapitalization: TextCapitalization.sentences,
          onChanged: onNoteChanged,
          style: const TextStyle(fontWeight: FontWeight.w600, color: textColor, fontSize: 14, height: 1.5),
          decoration: InputDecoration(
            hintText: "ps_reg_serv_notes_hint".tr(),
            hintStyle: TextStyle(color: secondaryTextColor.withOpacity(0.3), fontSize: 13, fontWeight: FontWeight.w500),
            filled: true,
            fillColor: bgLight,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }
}
