import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class Step10Inviato extends StatelessWidget {
  final VoidCallback onFinish;

  const Step10Inviato({
    super.key,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    // Palette Premium
    final Color primaryColor = const Color(0xFF4338CA); // Indigo 700
    final Color accentColor = const Color(0xFF10B981); // Emerald 500
    final Color textColor = const Color(0xFF1E293B);
    final Color secondaryTextColor = const Color(0xFF64748B);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
              Icon(Icons.check_circle_rounded, size: 100, color: accentColor),
            ],
          ),
          const SizedBox(height: 50),
          Text(
            "ps_reg_sent_title".tr(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: textColor, letterSpacing: -1),
          ),
          const SizedBox(height: 20),
          Text(
            "ps_reg_sent_msg".tr(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: secondaryTextColor, height: 1.6, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 60),
          
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [primaryColor, const Color(0xFF3730A3)],
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: ElevatedButton(
              onPressed: onFinish,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                minimumSize: const Size(double.infinity, 65),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: Text(
                "ps_reg_sent_btn".tr(), 
                style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 14, letterSpacing: 1.5)
              ),
            ),
          ),
        ],
      ),
    );
  }
}
