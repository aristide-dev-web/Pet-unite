import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class SitterEditFront extends StatelessWidget {
  final bool isDeleting;
  final VoidCallback onEditProfile;
  final VoidCallback onDeleteProfile;

  const SitterEditFront({
    super.key,
    required this.isDeleting,
    required this.onEditProfile,
    required this.onDeleteProfile,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryIndigo = Color(0xFF6366F1);
    const Color bgLight = Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        title: Text("ps_edit_header".tr(), style: const TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        centerTitle: true,
      ),
      body: isDeleting 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card Informativa
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: primaryIndigo.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: primaryIndigo, size: 30),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          "ps_edit_info_card_msg".tr(),
                          style: TextStyle(fontSize: 13, color: primaryIndigo.withOpacity(0.8), fontWeight: FontWeight.w600, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 35),
                Text("ps_edit_actions_title".tr().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.grey, fontSize: 12, letterSpacing: 1.2)),
                const SizedBox(height: 15),

                // TASTO MODIFICA
                _buildActionCard(
                  title: "ps_edit_btn_edit_info".tr(),
                  subtitle: "ps_edit_btn_edit_info_sub".tr(),
                  icon: Icons.edit_document,
                  color: Colors.blueAccent,
                  onTap: onEditProfile,
                ),

                const SizedBox(height: 15),

                // TASTO ELIMINA
                _buildActionCard(
                  title: "ps_edit_btn_delete_sitter".tr(),
                  subtitle: "ps_edit_btn_delete_sitter_sub".tr(),
                  icon: Icons.no_accounts_rounded,
                  color: Colors.redAccent,
                  onTap: onDeleteProfile,
                ),

                const SizedBox(height: 50),
                const Center(
                  child: Text(
                    "PetPing Professional v1.0",
                    style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildActionCard({required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF1E293B))),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }
}
