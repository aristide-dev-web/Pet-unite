import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'diariopet/moment/tuoi_momenti.dart';
import 'diariopet/calendario/calendario.dart';
import 'diariopet/diario_pet.dart';
import 'diariopet/back_diario.dart';
import 'package:easy_localization/easy_localization.dart';

class TabPet extends StatefulWidget {
  final String animaleId;
  final Animale? initialData;

  const TabPet({required this.animaleId, this.initialData, super.key});

  @override
  State<TabPet> createState() => _TabPetState();
}

class _TabPetState extends State<TabPet> with TickerProviderStateMixin {
  late TabController _tabController;
  AnimationController? _bgAnimationController;
  static const Duration _animDuration = Duration(milliseconds: 1000);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _bgAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bgAnimationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int hour = DateTime.now().hour;
    final bool isNotte = hour >= 20 || hour < 6;

    final List<Color> gradientColors = isNotte
        ? [
      const Color(0xFF0A1931), 
      const Color(0xFF1E3A5F), 
      const Color(0xFF4A148C), 
      const Color(0xFF880E4F).withOpacity(0.8), 
      const Color(0xFFF5F5DC),
    ]
        : [
      const Color(0xFFE1F5FE), // Azzurro lista animali (Parte Alta)
      const Color(0xFFB3E5FC),
      // Azzurro lista animali (Secondo Colore)
      const Color(0xFF9ACCE5),
      const Color(0xFFFFC9A1) ,// Rosa Fantasy
      const Color(0xFFFFF9C4), // Giallo Crema
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: AnimatedDefaultTextStyle(
          duration: _animDuration,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: 2,
            color: isNotte ? Colors.white.withOpacity(0.9) : Colors.blueGrey.shade800,
            shadows: [
              Shadow(
                blurRadius: 10,
                color: isNotte ? Colors.black45 : Colors.white70,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text('pet_diary_title_upper'.tr()),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: isNotte ? Colors.white70 : Colors.blueGrey.shade700),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: _buildTabBar(isNotte),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedContainer(
              duration: _animDuration,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: gradientColors,
                  stops: const [0.0, 0.25, 0.45, 0.7, 1.0],
                ),
              ),
            ),
          ),

          if (_bgAnimationController != null)
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: _animDuration,
                child: RepaintBoundary(
                  key: ValueKey(isNotte),
                  child: AnimatedBuilder(
                    animation: _bgAnimationController!,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: PetArtPainter(
                          animationValue: _bgAnimationController!.value,
                          isNotte: isNotte,
                        ),
                        child: Container(),
                      );
                    },
                  ),
                ),
              ),
            ),

          SafeArea(
            bottom: false,
            child: TabBarView(
              controller: _tabController,
              children: [
                DiarioPet(
                  animaleId: widget.animaleId,
                  initialData: widget.initialData,
                  isNotte: isNotte,
                ),
                TuoiMomenti(animaleId: widget.animaleId),
                CalendarioPage(animaleId: widget.animaleId),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isNotte) {
    return AnimatedContainer(
      duration: _animDuration,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: (isNotte ? Colors.white : Colors.blueGrey).withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: isNotte ? Colors.white.withOpacity(0.8) : Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)
            ]
        ),
        labelColor: Colors.blueGrey.shade900,
        unselectedLabelColor: isNotte ? Colors.white60 : Colors.blueGrey.shade400,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        tabs: [
          Tab(text: "pet_tab_diary".tr()),
          Tab(text: "pet_tab_moments".tr()),
          Tab(text: "pet_tab_events".tr()),
        ],
      ),
    );
  }
}

class PetArtPainter extends CustomPainter {
  final double animationValue;
  final bool isNotte;

  static final List<Offset> starBasePositions = List.generate(45, (i) {
    final r = math.Random(i);
    return Offset(r.nextDouble(), r.nextDouble());
  });

  static final List<Offset> dayFloatingPositions = List.generate(20, (i) {
    final r = math.Random(i + 100);
    return Offset(r.nextDouble(), r.nextDouble());
  });

  PetArtPainter({required this.animationValue, required this.isNotte});

  @override
  void paint(Canvas canvas, Size size) {
    if (isNotte) {
      _drawShootingStar(canvas, size);
      _drawRealisticMoon(canvas, Offset(size.width * 0.85, size.height * 0.08));

      final starPaint = Paint();
      for (int i = 0; i < starBasePositions.length; i++) {
        Offset basePos = starBasePositions[i];
        double orbitX = basePos.dx * size.width + math.cos(animationValue * 2 * math.pi + i) * 8;
        double orbitY = basePos.dy * size.height * 0.6 + math.sin(animationValue * 2 * math.pi + i) * 8;
        double pulse = (math.sin(animationValue * 15 * math.pi + i) + 1) / 2;

        starPaint.color = Colors.white.withOpacity(0.15 + (pulse * 0.35));
        canvas.drawCircle(Offset(orbitX, orbitY), 1 + (pulse * 1.8), starPaint);
      }
      _drawVividClouds(canvas, size, 0.06);
    } else {
      _drawCuteRainbow(canvas, size); // Arcobaleno soffice in background
      final sunCenter = Offset(size.width * 0.15, size.height * 0.08);
      _drawSunRays(canvas, sunCenter);
      _drawSoftSun(canvas, sunCenter);
      _drawNaturalDayClouds(canvas, size); // Animazione naturale per il giorno
      _drawFlyingBirds(canvas, size);
      _drawFlyingBirds(canvas, size);
      _drawFloatingFantasies(canvas, size); // Particelle magiche luccicanti
    }
  }

  void _drawCuteRainbow(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.55);
    final radius = size.width * 0.7;
    
    final colors = [
      Colors.red.withOpacity(0.05),
      Colors.orange.withOpacity(0.05),
      Colors.yellow.withOpacity(0.05),
      Colors.green.withOpacity(0.05),
      Colors.blue.withOpacity(0.05),
      Colors.purple.withOpacity(0.05),
    ];

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    for (int i = 0; i < colors.length; i++) {
      paint.color = colors[i];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - (i * 12)),
        math.pi + 0.2,
        math.pi - 0.4,
        false,
        paint,
      );
    }
  }

  void _drawNaturalDayClouds(Canvas canvas, Size size) {
    final cloudPaint = Paint()..color = Colors.white.withOpacity(0.45);
    final dayCloudConfigs = [
      {'y': 0.15, 'speed': 0.12, 'offset': 0.1, 'size': 50.0},
      {'y': 0.28, 'speed': 0.07, 'offset': 0.4, 'size': 35.0},
      {'y': 0.22, 'speed': 0.10, 'offset': 0.7, 'size': 42.0},
      {'y': 0.35, 'speed': 0.05, 'offset': 0.2, 'size': 55.0},
    ];

    for (var config in dayCloudConfigs) {
      double speed = config['speed'] as double;
      double offset = config['offset'] as double;
      double t = (offset + animationValue * speed) % 1.0;
      double x = t * (size.width + 400) - 200;
      double y = size.height * (config['y'] as double);
      double s = config['size'] as double;

      canvas.drawCircle(Offset(x, y), s, cloudPaint);
      canvas.drawCircle(Offset(x + s * 0.5, y + s * 0.2), s * 0.8, cloudPaint);
      canvas.drawCircle(Offset(x - s * 0.5, y + s * 0.1), s * 0.7, cloudPaint);
      canvas.drawCircle(Offset(x + s * 0.2, y - s * 0.3), s * 0.6, cloudPaint);
    }
  }

  void _drawSunRays(Canvas canvas, Offset center) {
    final rayPaint = Paint()
      ..color = const Color(0xFFFFE082).withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    
    for (int i = 0; i < 8; i++) {
      double angle = (i * 45 * math.pi / 180) + (animationValue * 0.3 * math.pi);
      canvas.drawLine(
        center + Offset(math.cos(angle) * 50, math.sin(angle) * 50),
        center + Offset(math.cos(angle) * 85, math.sin(angle) * 85),
        rayPaint,
      );
    }
  }

  void _drawFlyingBirds(Canvas canvas, Size size) {
    final birdPaint = Paint()
      ..color = Colors.blueGrey.shade600.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 3; i++) {
      double t = (animationValue * 0.08 + i * 0.3) % 1.0;
      double x = size.width * (1.2 - t * 1.4);
      double y = size.height * (0.2 + i * 0.06 + math.sin(t * 8) * 0.02);
      double wingPos = math.sin(animationValue * 50 + i) * 6;
      
      Path path = Path();
      path.moveTo(x - 12, y + wingPos);
      path.quadraticBezierTo(x, y - 4, x + 12, y + wingPos);
      canvas.drawPath(path, birdPaint);
    }
  }

  void _drawFloatingFantasies(Canvas canvas, Size size) {
    final p = Paint();
    for (int i = 0; i < dayFloatingPositions.length; i++) {
      Offset basePos = dayFloatingPositions[i];
      double x = (basePos.dx * size.width + animationValue * 40 + math.sin(animationValue * 4 + i) * 25) % (size.width + 100) - 50;
      double y = basePos.dy * size.height;
      
      // Luccichio: variazione di scala e opacità
      double sparkle = (math.sin(animationValue * 12 + i) + 1.0) / 2.0;
      double sizeMult = 1.0 + sparkle * 1.5;

      p.color = (i % 3 == 0 ? Colors.white : (i % 3 == 1 ? const Color(0xFFFFD1DC) : const Color(0xFFB2EBF2))).withOpacity(0.1 + sparkle * 0.3);
      canvas.drawCircle(Offset(x, y), 2.0 * sizeMult, p);
      
      // Piccolo bagliore centrale per le particelle più luminose
      if (sparkle > 0.8) {
        canvas.drawCircle(Offset(x, y), 1.0, Paint()..color = Colors.white.withOpacity(sparkle));
      }
    }
  }

  void _drawVividClouds(Canvas canvas, Size size, double baseOpacity) {
    final cloudPaint = Paint()..color = Colors.white.withOpacity(baseOpacity);
    final cloudConfigs = [
      {'y': 0.18, 'speed': 0.15, 'dir': 1.0, 'size': 45.0},
      {'y': 0.32, 'speed': 0.08, 'dir': -1.0, 'size': 38.0},
      {'y': 0.25, 'speed': 0.12, 'dir': 1.0, 'size': 42.0},
    ];

    for (var config in cloudConfigs) {
      double dir = config['dir'] as double;
      double speed = config['speed'] as double;
      double x = ((animationValue * speed * dir) % 1.0) * (size.width + 400) - 200;
      if (dir < 0) x = size.width - x;

      double y = size.height * (config['y'] as double);
      double s = config['size'] as double;

      canvas.drawCircle(Offset(x, y), s, cloudPaint);
      canvas.drawCircle(Offset(x + s * 0.5, y + s * 0.2), s * 0.8, cloudPaint);
      canvas.drawCircle(Offset(x - s * 0.5, y + s * 0.1), s * 0.7, cloudPaint);
      canvas.drawCircle(Offset(x + s * 0.1, y - s * 0.3), s * 0.6, cloudPaint);
    }
  }

  void _drawRealisticMoon(Canvas canvas, Offset center) {
    const radius = 42.0;
    canvas.drawCircle(center, radius + 25, Paint()
      ..color = const Color(0xFFFFFDE7).withOpacity(0.06)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25));

    final moonPaint = Paint()..color = const Color(0xFFFFFDE7);
    canvas.drawCircle(center, radius, moonPaint);

    final craterPaint = Paint()..color = const Color(0xFFE6EE9C).withOpacity(0.3);
    final craterShadow = Paint()..color = Colors.black.withOpacity(0.04);

    void drawCrater(Offset offset, double r) {
      canvas.drawCircle(center + offset, r, craterPaint);
      canvas.drawCircle(center + offset - const Offset(1, 1), r * 0.7, craterShadow);
    }

    drawCrater(const Offset(-15, -12), 9);
    drawCrater(const Offset(12, 18), 7);
    drawCrater(const Offset(25, -5), 5);
    drawCrater(const Offset(-5, 28), 4);

    final facePaint = Paint()..color = Colors.blueGrey.shade400.withOpacity(0.5)..style = PaintingStyle.stroke..strokeWidth = 2.5..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCenter(center: center + const Offset(-12, -4), width: 12, height: 10), 0, -math.pi, false, facePaint);
    canvas.drawArc(Rect.fromCenter(center: center + const Offset(12, -4), width: 12, height: 10), 0, -math.pi, false, facePaint);
    canvas.drawArc(Rect.fromCenter(center: center + const Offset(0, 10), width: 16, height: 12), 0.3, math.pi - 0.6, false, facePaint);
    canvas.drawCircle(center + const Offset(-20, 5), 4, Paint()..color = Colors.pinkAccent.withOpacity(0.15)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    canvas.drawCircle(center + const Offset(20, 5), 4, Paint()..color = Colors.pinkAccent.withOpacity(0.15)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
  }

  void _drawShootingStar(Canvas canvas, Size size) {
    double t = (animationValue * 7) % 1.0;
    if (t < 0.06) {
      double progress = t / 0.06;
      final start = Offset(size.width * 0.95, size.height * 0.1);
      final end = Offset(size.width * 0.05, size.height * 0.5);
      final currentPos = Offset.lerp(start, end, progress)!;
      final tail = Offset.lerp(start, end, (progress - 0.25).clamp(0, 1))!;
      canvas.drawLine(currentPos, tail, Paint()
        ..color = Colors.white.withOpacity(0.4 * (1 - progress))
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round);
    }
  }

  void _drawSoftSun(Canvas canvas, Offset center) {
    canvas.drawCircle(center, 55, Paint()
      ..color = const Color(0xFFFFE082).withOpacity(0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30));
    canvas.drawCircle(center, 35, Paint()..color = const Color(0xFFFFD54F).withOpacity(0.45));

    final facePaint = Paint()..color = Colors.orange.shade800.withOpacity(0.5)..style = PaintingStyle.fill;
    canvas.drawCircle(center + const Offset(-8, -5), 3, facePaint);
    canvas.drawCircle(center + const Offset(8, -5), 3, facePaint);
    final mouthPaint = Paint()..color = Colors.orange.shade800.withOpacity(0.5)..style = PaintingStyle.stroke..strokeWidth = 2.5..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCenter(center: center + const Offset(0, 8), width: 14, height: 10), 0, math.pi, false, mouthPaint);
  }

  @override
  bool shouldRepaint(covariant PetArtPainter oldDelegate) => true;
}
