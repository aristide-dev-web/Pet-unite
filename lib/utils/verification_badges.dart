import 'package:flutter/material.dart';

class VerificationBadges {
  static Widget identity({bool verified = false, double size = 22}) {
    return _BaseBadge(
      isVerified: verified,
      icon: Icons.verified_rounded, 
      label: "Identità",
      color: const Color(0xFFD97706), 
      bgColor: const Color(0xFFFEF3C7),
      size: size,
    );
  }

  static Widget rating({required double rating, required int reviews, double size = 22}) {
    return _BaseBadge(
      isVerified: true,
      icon: Icons.stars_rounded,
      label: "${rating.toStringAsFixed(1)} ($reviews)",
      color: const Color(0xFFB45309), 
      bgColor: const Color(0xFFFFF7ED),
      size: size,
    );
  }

  static Widget email({bool verified = false, double size = 22}) {
    return _BaseBadge(
      isVerified: verified,
      icon: Icons.verified_user_rounded,
      label: "Email",
      color: const Color(0xFF059669), 
      bgColor: const Color(0xFFD1FAE5),
      size: size,
    );
  }

  static Widget phone({bool verified = false, double size = 22}) {
    return _BaseBadge(
      isVerified: verified,
      icon: Icons.verified_rounded, 
      label: "Telefono",
      color: const Color(0xFF4F46E5), 
      bgColor: const Color(0xFFE0E7FF),
      size: size,
    );
  }

  static Widget google({bool verified = false, double size = 22}) {
    return _BaseBadge(
      isVerified: verified,
      icon: Icons.g_mobiledata_rounded,
      label: "Google",
      color: const Color(0xFF2563EB), 
      bgColor: const Color(0xFFDBEAFE),
      size: size,
    );
  }

  static Widget certification({required String category, double size = 22}) {
    return _BaseBadge(
      isVerified: true,
      icon: Icons.workspace_premium_rounded,
      label: category,
      color: const Color(0xFF7C3AED), 
      bgColor: const Color(0xFFEDE9FE),
      size: size,
    );
  }

  // NUOVO BADGE PREMIUM
  static Widget premium({required String label, double size = 24}) {
    return _BaseBadge(
      isVerified: true,
      icon: Icons.auto_awesome_rounded,
      label: label.toUpperCase(),
      color: const Color(0xFFB45309), // Oro scuro per il testo
      bgColor: const Color(0xFFFFFBEB), // Sfondo crema chiarissimo
      size: size,
      isPremium: true,
    );
  }
}

class _BaseBadge extends StatelessWidget {
  final bool isVerified;
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final double size;
  final bool isPremium;

  const _BaseBadge({
    required this.isVerified,
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    this.size = 22,
    this.isPremium = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVerified) return const SizedBox.shrink();

    // Colori per l'effetto Premium (Oro/Giallo brillante)
    final premiumGradient = LinearGradient(
      colors: [const Color(0xFFF59E0B), const Color(0xFFD97706)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Container(
      padding: EdgeInsets.fromLTRB(size * 0.15, size * 0.15, size * 0.45, size * 0.15),
      decoration: BoxDecoration(
        color: isPremium ? const Color(0xFFFFFBEB) : bgColor,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: isPremium ? const Color(0xFFF59E0B).withOpacity(0.6) : color.withOpacity(0.4), 
          width: isPremium ? 2.2 : 1.8
        ),
        boxShadow: [
          BoxShadow(
            color: (isPremium ? const Color(0xFFF59E0B) : color).withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(size * 0.22),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.2),
              gradient: isPremium ? premiumGradient : LinearGradient(
                colors: [color, color.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isPremium ? const Color(0xFFF59E0B) : color).withOpacity(0.4),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                )
              ]
            ),
            child: Icon(icon, size: size * 0.55, color: Colors.white),
          ),
          SizedBox(width: size * 0.25),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: isPremium ? const Color(0xFF92400E) : color,
                fontSize: size * 0.52,
                fontWeight: FontWeight.w900,
                letterSpacing: isPremium ? 0.5 : -0.5,
                shadows: isPremium ? [
                   Shadow(color: const Color(0xFFF59E0B).withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 1))
                ] : null,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
