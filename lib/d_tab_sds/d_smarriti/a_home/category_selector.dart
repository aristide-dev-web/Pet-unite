import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';

class CategorySelector extends StatefulWidget {
  final String? selectedSpecies;
  final Function(String?) onSelected;
  final bool showAll;
  final Color activeColor;
  final bool isSOS; 

  const CategorySelector({
    super.key,
    required this.selectedSpecies,
    required this.onSelected,
    this.showAll = true,
    this.activeColor = const Color(0xFFC5A059),
    this.isSOS = false, 
  });

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: ui.Clip.none,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: widget.isSOS 
          ? [
              _buildItem(null, 'sos_cat_general'),
              _buildItem('Cane', 'sos_cat_dog'),
              _buildItem('Gatto', 'sos_cat_cat'),
              _buildItem('Coniglio', 'sos_cat_rabbit'),
              _buildItem('Altro', 'sos_cat_other'),
            ]
          : [
              _buildItem(null, 'sos_cat_general'),
              _buildItem('Cane', 'sos_cat_dog'),
              _buildItem('Gatto', 'sos_cat_cat'),
              _buildItem('Coniglio', 'sos_cat_rabbit'),
              _buildItem('Criceto', 'sos_cat_hamster'),
              _buildItem('Uccello', 'sos_cat_bird'),
              _buildItem('Tartaruga', 'sos_cat_turtle'),
              _buildItem('Altro', 'sos_cat_other'),
            ],
      ),
    );
  }

  Widget _buildItem(String? species, String labelKey) {
    final bool isSelected = widget.selectedSpecies == species;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onSelected(species);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.12 : 1.0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (isSelected)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: widget.activeColor.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),

                  if (isSelected)
                    RotationTransition(
                      turns: _rotationController,
                      child: CustomPaint(
                        size: const Size(72, 72),
                        painter: _PremiumRingPainter(color: widget.activeColor),
                      ),
                    ),

                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isSelected
                            ? [
                                widget.activeColor.withOpacity(0.9),
                                widget.activeColor.darken(0.3),
                              ]
                            : [const Color(0xFFF8F8F8), Colors.white],
                      ),
                      border: Border.all(
                        color: isSelected 
                            ? Colors.white.withOpacity(0.6) 
                            : Colors.black.withOpacity(0.05),
                        width: 1.5,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          top: 2,
                          child: Container(
                            width: 44,
                            height: 22,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withOpacity(isSelected ? 0.4 : 0.1),
                                  Colors.white.withOpacity(0),
                                ],
                              ),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                            ),
                          ),
                        ),
                        
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return CustomPaint(
                              size: const Size(34, 32),
                              painter: _NanoAnimalPainter(
                                species: species,
                                color: isSelected ? Colors.white : Colors.grey.shade500,
                                progress: _pulseController.value,
                                isSelected: isSelected,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              labelKey.tr().toUpperCase(),
              style: TextStyle(
                color: isSelected ? widget.activeColor : Colors.grey.shade500,
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(top: 4),
              width: isSelected ? 12 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: widget.activeColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension ColorUtils on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsv = HSVColor.fromColor(this);
    return hsv.withValue((hsv.value - amount).clamp(0.0, 1.0)).toColor();
  }
}

class _PremiumRingPainter extends CustomPainter {
  final Color color;
  _PremiumRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..shader = ui.Gradient.sweep(
        center,
        [color.withOpacity(0), color, color.withOpacity(0)],
        [0.0, 0.5, 1.0],
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, paint);

    final dotPaint = Paint()..color = color..style = PaintingStyle.fill;
    for (int i = 0; i < 3; i++) {
      final angle = (i * 120) * math.pi / 180;
      canvas.drawCircle(
        Offset(center.dx + radius * math.cos(angle), center.dy + radius * math.sin(angle)),
        1.5,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NanoAnimalPainter extends CustomPainter {
  final String? species;
  final Color color;
  final double progress;
  final bool isSelected;

  _NanoAnimalPainter({
    required this.species,
    required this.color,
    required this.progress,
    required this.isSelected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final center = Offset(size.width / 2, size.height / 2);
    final breathe = isSelected ? (progress * 2.0) : 0.0;

    switch (species) {
      case 'Cane':
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: center + Offset(0, 1), width: 18 + breathe, height: 14 + breathe), const Radius.circular(8)), paint);
        final earL = Path()..moveTo(center.dx - 10, center.dy - 2)..quadraticBezierTo(center.dx - 16, center.dy + 3, center.dx - 10, center.dy + 12);
        final earR = Path()..moveTo(center.dx + 10, center.dy - 2)..quadraticBezierTo(center.dx + 16, center.dy + 3, center.dx + 10, center.dy + 12);
        canvas.drawPath(earL, paint);
        canvas.drawPath(earR, paint);
        canvas.drawCircle(center + Offset(-4, -1), 1.2, paint..style = PaintingStyle.fill);
        canvas.drawCircle(center + Offset(4, -1), 1.2, paint);
        canvas.drawCircle(center + Offset(0, 4), 1.5, paint);
        break;

      case 'Gatto':
        canvas.drawCircle(center + Offset(0, 1), 10 + breathe/2, paint);
        final earL = Path()..moveTo(center.dx - 9, center.dy - 4)..lineTo(center.dx - 11, center.dy - 14)..lineTo(center.dx - 2, center.dy - 7);
        final earR = Path()..moveTo(center.dx + 9, center.dy - 4)..lineTo(center.dx + 11, center.dy - 14)..lineTo(center.dx + 3, center.dy - 7);
        canvas.drawPath(earL, paint);
        canvas.drawPath(earR, paint);
        canvas.drawCircle(center + Offset(-3.5, 0), 1.5, paint..style = PaintingStyle.fill);
        canvas.drawCircle(center + Offset(3.5, 0), 1.5, paint);
        break;

      case 'Coniglio':
        canvas.drawCircle(center + Offset(0, 5), 9 + breathe/3, paint);
        final earL = Path()..moveTo(center.dx - 4, center.dy - 1)..quadraticBezierTo(center.dx - 7, center.dy - 19, center.dx - 1, center.dy - 1);
        final earR = Path()..moveTo(center.dx + 4, center.dy - 1)..quadraticBezierTo(center.dx + 7, center.dy - 19, center.dx + 1, center.dy - 1);
        canvas.drawPath(earL, paint);
        canvas.drawPath(earR, paint);
        canvas.drawCircle(center + Offset(-3, 4), 1.2, paint..style = PaintingStyle.fill);
        canvas.drawCircle(center + Offset(3, 4), 1.2, paint);
        break;

      case 'Uccello':
        canvas.drawCircle(center + Offset(0, 1), 9, paint);
        final beak = Path()..moveTo(center.dx + 8, center.dy - 1)..lineTo(center.dx + 14, center.dy + 1.5)..lineTo(center.dx + 8, center.dy + 4)..close();
        canvas.drawPath(beak, paint..style = PaintingStyle.fill);
        canvas.drawCircle(center + Offset(2, -1), 1.2, paint..style = PaintingStyle.fill);
        break;

      case 'Tartaruga':
        canvas.drawArc(Rect.fromCenter(center: center + Offset(0, 2), width: 25, height: 16), 3.14, 3.14, false, paint);
        canvas.drawLine(center + Offset(-12.5, 2), center + Offset(12.5, 2), paint);
        canvas.drawCircle(center + Offset(14, 0), 4.5, paint);
        canvas.drawCircle(center + Offset(16, -1), 1.0, paint..style = PaintingStyle.fill);
        break;

      case 'Criceto':
        canvas.drawOval(Rect.fromCenter(center: center + Offset(0, 2), width: 20 + breathe, height: 16 + breathe), paint);
        canvas.drawCircle(center + Offset(-8, -4), 4, paint);
        canvas.drawCircle(center + Offset(8, -4), 4, paint);
        canvas.drawCircle(center + Offset(-4, 1), 1.2, paint..style = PaintingStyle.fill);
        canvas.drawCircle(center + Offset(4, 1), 1.2, paint);
        break;

      case 'Altro':
        final star = Path();
        for (int i = 0; i < 5; i++) {
          final angle = (i * 72 - 90) * math.pi / 180;
          final p = Offset(center.dx + 12 * math.cos(angle), center.dy + 12 * math.sin(angle));
          if (i == 0) star.moveTo(p.dx, p.dy); else star.lineTo(p.dx, p.dy);
          final innerAngle = (i * 72 + 36 - 90) * math.pi / 180;
          star.lineTo(center.dx + 6 * math.cos(innerAngle), center.dy + 6 * math.sin(innerAngle));
        }
        star.close();
        canvas.drawPath(star, paint..style = PaintingStyle.stroke);
        canvas.drawCircle(center + Offset(-3, -2), 1.2, paint..style = PaintingStyle.fill);
        canvas.drawCircle(center + Offset(3, -2), 1.2, paint);
        break;

      case null:
      case 'Generale':
        final pad = Path()..addOval(Rect.fromCenter(center: center + Offset(0, 4), width: 16, height: 12));
        canvas.drawPath(pad, paint..style = PaintingStyle.fill);
        for (int i = 0; i < 4; i++) {
          final angle = (i * 40 - 60) * math.pi / 180;
          canvas.drawCircle(center + Offset(math.sin(angle) * 12, math.cos(angle) * -12 + 2), 3.5, paint..style = PaintingStyle.fill);
        }
        break;

      default:
        canvas.drawCircle(center, 12, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _NanoAnimalPainter oldDelegate) => true;
}
