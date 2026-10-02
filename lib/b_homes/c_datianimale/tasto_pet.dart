import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:petping/b_homes/c_datianimale/a/lista_animali.dart';
import 'package:petping/utils/navigator_helpers.dart';


class TastoPet extends StatefulWidget {
  const TastoPet({super.key});

  @override
  State<TastoPet> createState() => _TastoPetState();
}

class _TastoPetState extends State<TastoPet> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: Colors.deepPurple,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: AnimalCartoonPainter(
                        animationValue: _animationController.value,
                        opacity: 0.15,
                      ),
                    );
                  },
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => pushWithSlide(context, const ListaAnimali()),
              icon: const Icon(Icons.pets, color: Colors.white),
              label: const Text(
                'I tuoi animali',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimalCartoonPainter extends CustomPainter {
  final double animationValue;
  final double opacity;
  AnimalCartoonPainter({required this.animationValue, this.opacity = 0.3});
  @override void paint(Canvas canvas, Size size) {}
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
