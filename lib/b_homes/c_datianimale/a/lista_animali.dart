import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../tab_pet.dart';
import '../addati/aggiungi_animale.dart';
import 'package:petping/b_homes/c_datianimale/a/pet_card.dart';
import '../diariopet/back_diario.dart';
import 'package:petping/utils/navigator_helpers.dart';
import 'package:easy_localization/easy_localization.dart';

class ListaAnimali extends StatefulWidget {
  const ListaAnimali({super.key});

  @override
  State<ListaAnimali> createState() => _ListaAnimaliState();
}

class _ListaAnimaliState extends State<ListaAnimali> with TickerProviderStateMixin {
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
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('pets_list_title'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE1F5FE), 
              Color(0xFFB3E5FC), 
              Color(0xFFFFECB3), 
              Color(0xFFFFCCBC), 
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) => CustomPaint(
                  painter: AnimalCartoonPainter(animationValue: _animationController.value),
                ),
              ),
            ),
            ValueListenableBuilder(
              valueListenable: Hive.box<Animale>(animaliBoxName).listenable(),
              builder: (context, Box<Animale> box, _) {
                final animali = box.values.toList();

                if (animali.isEmpty) {
                  return Center(
                    child: Text('pets_list_empty'.tr(), 
                    style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 18)),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.70,
                  ),
                  itemCount: animali.length,
                  itemBuilder: (context, index) {
                    final a = animali[index];

                    return GestureDetector(
                      onTap: () {
                        pushWithFadeSlow(context, TabPet(
                          animaleId: a.id,
                          initialData: a,
                        ));
                      },
                      child: CartaAnimale(
                        animaleId: a.id,
                        nome: a.nome,
                        sesso: a.sesso,
                        razza: a.razza,
                        note: '',
                        temaCarta: 'beije', // Default o aggiungi campo a modello Animale se necessario
                        fotoUrl: a.fotoUrl,
                        day: a.day,
                        month: a.month,
                        year: a.year,
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () => pushWithSlide(context, const AggiungiAnimale()),
        backgroundColor: Colors.lightBlue[400],
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}

class AnimalCartoonPainter extends CustomPainter {
  final double animationValue;
  AnimalCartoonPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(42);
    
    const int cols = 5;
    const int rows = 8;
    final double colWidth = size.width / cols;
    final double rowHeight = size.height / rows;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (random.nextDouble() > 0.7) continue; 

        final double baseX = c * colWidth + random.nextDouble() * (colWidth * 0.4);
        final double baseY = r * rowHeight + random.nextDouble() * (rowHeight * 0.4);
        
        final double time = animationValue * 2 * math.pi;
        final double dx = math.cos(time + (r * c)) * 12; 
        final double dy = math.sin(time + (r + c)) * 15; 
        
        int type = random.nextInt(5);
        
        Color itemColor;
        switch (type) {
          case 0: itemColor = const Color(0xFF263238).withOpacity(0.3); break;
          case 1: itemColor = const Color(0xFF795548).withOpacity(0.3); break;
          case 2: itemColor = const Color(0xFFFF7043).withOpacity(0.35); break;
          case 3: itemColor = const Color(0xFFE53935).withOpacity(0.35); break;
          default: itemColor = const Color(0xFF81D4FA).withOpacity(0.25);
        }

        canvas.save();
        canvas.translate(baseX + dx, baseY + dy);
        canvas.rotate(random.nextDouble() * math.pi / 4 + math.sin(time + r) * 0.1); 
        
        paint.color = itemColor;
        if (type == 0) _drawPaw(canvas, paint);
        else if (type == 1) _drawBone(canvas, paint);
        else if (type == 2) _drawFish(canvas, paint);
        else if (type == 3) _drawHeart(canvas, paint);
        else _drawYarnBall(canvas, paint);
        
        canvas.restore();
      }
    }
  }

  void _drawPaw(Canvas canvas, Paint paint) {
    canvas.drawCircle(Offset.zero, 8, paint);
    canvas.drawCircle(const Offset(-10, -10), 4, paint);
    canvas.drawCircle(const Offset(0, -13), 4, paint);
    canvas.drawCircle(const Offset(10, -10), 4, paint);
  }

  void _drawBone(Canvas canvas, Paint paint) {
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-12, -3, 24, 6), const Radius.circular(3)), paint);
    canvas.drawCircle(const Offset(-12, -3), 4, paint);
    canvas.drawCircle(const Offset(-12, 3), 4, paint);
    canvas.drawCircle(const Offset(12, -3), 4, paint);
    canvas.drawCircle(const Offset(12, 3), 4, paint);
  }

  void _drawFish(Canvas canvas, Paint paint) {
    final path = Path()
      ..moveTo(-10, 0)
      ..quadraticBezierTo(0, -8, 10, 0)
      ..quadraticBezierTo(0, 8, -10, 0)
      ..moveTo(-10, 0)
      ..lineTo(-15, -5)
      ..lineTo(-15, 5)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawHeart(Canvas canvas, Paint paint) {
    final path = Path()
      ..moveTo(0, 4)
      ..cubicTo(-10, -6, -15, 6, 0, 15)
      ..cubicTo(15, 6, 10, -6, 0, 4);
    canvas.drawPath(path, paint);
  }

  void _drawYarnBall(Canvas canvas, Paint paint) {
    canvas.drawCircle(Offset.zero, 9, paint);
    final strokePaint = Paint()
      ..color = paint.color.withOpacity(paint.color.opacity + 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(const Offset(-7, -4), const Offset(7, 4), strokePaint);
    canvas.drawLine(const Offset(-7, 4), const Offset(7, -4), strokePaint);
    canvas.drawLine(const Offset(0, -8), const Offset(0, 8), strokePaint);
  }

  @override
  bool shouldRepaint(covariant AnimalCartoonPainter oldDelegate) => 
      oldDelegate.animationValue != animationValue;
}
