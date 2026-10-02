import 'package:flutter/material.dart';

class SitterUIHelpers {
  static const Color primaryIndigo = Color(0xFF6366F1);
  static const Color accentEmerald = Color(0xFF10B981);
  static const Color textColor = Color(0xFF1E293B);
  static const Color secondaryTextColor = Color(0xFF64748B);
  static const Color bgLight = Color(0xFFF8FAFC);

  static String getEmoji(String s) {
    switch (s) {
      case "Cani": return "🐶";
      case "Gatti": return "🐱";
      case "Volatili": return "🐦";
      case "Conigli": return "🐰";
      case "Criceti": return "🐹";
      case "Tartarughe": return "🐢";
      case "Pesci": return "🐠";
      case "Rettili": return "🦎";
      case "Insetti": return "🦋";
      case "Esotici": return "🦔";
      case "Altro": return "➕";
      default: return "🐾";
    }
  }

  static Widget buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: primaryIndigo),
        const SizedBox(width: 10),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: secondaryTextColor,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  static Widget buildDetailRow(IconData icon, String label, String value, {Color? iconColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 14, color: iconColor ?? secondaryTextColor),
          const SizedBox(width: 8),
          Text("$label: ", style: const TextStyle(fontSize: 12, color: secondaryTextColor, fontWeight: FontWeight.w500)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  static Widget buildMiniChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: primaryIndigo),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: textColor),
          ),
        ],
      ),
    );
  }

  static Widget buildEmojiMiniChip(String emoji, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: textColor),
          ),
        ],
      ),
    );
  }

  static Widget buildSmallSubHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 9, color: color, letterSpacing: 1.0)),
      ],
    );
  }

  static Widget buildPriceRow(String name, double price, {String unit = "/gg"}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded, size: 18, color: accentEmerald),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
              Text(
                "€${price.toInt()}",
                style: const TextStyle(fontWeight: FontWeight.w900, color: primaryIndigo, fontSize: 16),
              ),
              if (unit.isNotEmpty)
                Text(
                  unit,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: secondaryTextColor, fontSize: 11),
                ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget buildDogSizesImageGrid(List<String> accepted) {
    final Map<String, Map<String, dynamic>> taglieInfo = {
      'XS': {'label': 'XS', 'weight': '0-5kg', 'icon': 'assets/images/xs.png', 'imgSize': 20.0},
      'S': {'label': 'S', 'weight': '5-10kg', 'icon': 'assets/images/s.png', 'imgSize': 28.0},
      'M': {'label': 'M', 'weight': '10-25kg', 'icon': 'assets/images/media.png', 'imgSize': 38.0},
      'L': {'label': 'L', 'weight': '25-45kg', 'icon': 'assets/images/grande.png', 'imgSize': 48.0},
      'XL': {'label': 'XL', 'weight': '45kg+', 'icon': 'assets/images/xl.png', 'imgSize': 46.0},
    };

    final List<String> sortedAccepted = ['XS', 'S', 'M', 'L', 'XL']
        .where((k) => accepted.contains(k))
        .toList();

    if (sortedAccepted.isEmpty) return const SizedBox.shrink();

    if (sortedAccepted.length <= 3) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: sortedAccepted.map((key) => _buildDogSizeItem(taglieInfo[key]!)).toList(),
      );
    }

    final List<String> row1 = sortedAccepted.take(3).toList();
    final List<String> row2 = sortedAccepted.skip(3).toList();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: row1.map((key) => _buildDogSizeItem(taglieInfo[key]!)).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: row2.map((key) => _buildDogSizeItem(taglieInfo[key]!)).toList(),
        ),
      ],
    );
  }

  static Widget _buildDogSizeItem(Map<String, dynamic> info) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4), // Ridotto padding orizzontale
      child: Column(
        children: [
          Container(
            width: 72, // Ridotta larghezza per far stare 3 box su una riga
            height: 95,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            decoration: BoxDecoration(
              color: primaryIndigo.withOpacity(0.05),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: primaryIndigo.withOpacity(0.2), width: 1.2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Center(
                    child: Image.asset(
                      info['icon'], 
                      height: (info['imgSize'] as double), 
                      fit: BoxFit.contain
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  info['label'] as String,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: primaryIndigo),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            info['weight'] as String,
            style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: primaryIndigo.withOpacity(0.7)),
          )
        ],
      ),
    );
  }

  static Widget buildPremiumServiceIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Icon(
        icon,
        size: 24,
        color: color,
        shadows: [
          Shadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 2),
          )
        ],
      ),
    );
  }
}
