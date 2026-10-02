import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:petping/petsitting/screens/search/sitter_search_screen.dart';

class SearchPanel extends StatelessWidget {
  const SearchPanel({super.key});

  // BACK: Logica di navigazione
  void _navigateToSearch(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SitterSearchScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // FRONT: UI della Card
    return _buildChoiceCard(
      context,
      "ps_panel_search_title".tr().toUpperCase(),
      "ps_panel_search_sub".tr(),
      Icons.search_rounded,
      const Color(0xFF6366F1),
      () => _navigateToSearch(context),
    );
  }

  Widget _buildChoiceCard(BuildContext context, String title, String sub, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: color.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 10))],
          border: Border.all(color: color.withOpacity(0.1), width: 2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w900, color: color, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 11), maxLines: 2),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: color.withOpacity(0.3), size: 14),
          ],
        ),
      ),
    );
  }
}
