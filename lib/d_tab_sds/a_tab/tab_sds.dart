import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petping/d_tab_sds/d_smarriti/a_home/animals_home.dart';
import 'package:petping/d_tab_sds/custodia_animali/a/home_custodia.dart';
import 'package:petping/d_tab_sds/adozione_animali/search_adozione_animals_screen.dart';

class SecondaryBottomTabs extends StatefulWidget {
  final Color initialColor;
  final int initialIndex;
  final VoidCallback? onBack;

  const SecondaryBottomTabs({
    super.key,
    required this.initialColor,
    this.initialIndex = 0,
    this.onBack,
  });

  @override
  State<SecondaryBottomTabs> createState() => _SecondaryBottomTabsState();
}

class _SecondaryBottomTabsState extends State<SecondaryBottomTabs> {
  late int index;

  final List<Color> tabColors = [
    const Color(0xFFE67E22), // Arancio - Smarriti
    const Color(0xFF2980B9), // Blu Sicurezza - Custodia
    const Color(0xFF27AE60), // Verde - Adozioni
  ];

  @override
  void initState() {
    super.initState();
    index = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final Color currentColor = tabColors[index];

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      // Rimosso l'AppBar che veniva mostrato solo per il tab Adozioni, 
      // creando il disallineamento rispetto a Smarriti e Custodia.
      appBar: null,
      extendBody: false, 
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 100), 
            child: _buildCurrentPage(index, currentColor),
          ),
          
          // Barra di navigazione "Premium Glassmorphism"
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 25, left: 20, right: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(35),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    height: 75,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(35),
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: currentColor.withOpacity(0.12),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildTabItem(0, Icons.explore_rounded, "S.O.S.", currentColor),
                        _buildTabItem(1, Icons.shield_rounded, "CUSTODIA", currentColor),
                        _buildTabItem(2, Icons.favorite_rounded, "ADOZIONI", currentColor),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(int i, IconData icon, String label, Color activeColor) {
    final bool isSelected = index == i;
    return GestureDetector(
      onTap: () {
        if (index != i) {
          HapticFeedback.mediumImpact();
          setState(() => index = i);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.elasticOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? activeColor : Colors.grey.shade500,
              size: isSelected ? 26 : 22,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: activeColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentPage(int currentIndex, Color activeColor) {
    switch (currentIndex) {
      case 0:
        return LostAnimalsHome(onBack: widget.onBack);
      case 1:
        return CustodiaHome(onBack: widget.onBack);
      case 2:
        return SearchAdozioneAnimalsScreen(onBack: widget.onBack);
      default:
        return const SizedBox();
    }
  }
}
