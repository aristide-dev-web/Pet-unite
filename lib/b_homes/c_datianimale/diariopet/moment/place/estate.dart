import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import '../momenti_service.dart';
import '../modello_memoria.dart';

class MareMomentiPage extends StatefulWidget {
  final String animaleId;
  const MareMomentiPage({super.key, required this.animaleId});

  @override
  State<MareMomentiPage> createState() => _MareMomentiPageState();
}

class _MareMomentiPageState extends State<MareMomentiPage> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;
  List<Memoria> memorie = [];
  final MomentiService _service = MomentiService();
  final ImagePicker _picker = ImagePicker();

  late AnimationController _pencilController;
  late AnimationController _summerController;
  bool _isDrawing = false;

  @override
  void initState() {
    super.initState();
    _caricaDati();
    _pencilController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _summerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _scrollController.addListener(() {
      if (mounted) {
        setState(() => _scrollOffset = _scrollController.offset);
      }
    });
  }

  void _scrollToEnd({int durationMs = 2000, Curve curve = Curves.easeInOutQuart}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: durationMs),
          curve: curve,
        );
      }
    });
  }

  Future<void> _caricaDati() async {
    final lista = await _service.caricaMemorie(widget.animaleId, 'Spiaggia');
    if (mounted) {
      setState(() => memorie = lista);
      _scrollToEnd(durationMs: 1500);
    }
  }

  Future<void> _aggiungiMomento() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();

      setState(() => _isDrawing = true);
      _pencilController.repeat(reverse: true);

      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.offset + 350,
          duration: const Duration(seconds: 3),
          curve: Curves.linear,
        );
      }

      await Future.delayed(const Duration(seconds: 3));

      final nuovaMemoria = Memoria(
        titolo: "moment_summer_default_title".tr(),
        descrizione: "",
        pathImmagine: "",
        categoria: 'Spiaggia',
        data: DateTime.now(),
        animaleId: widget.animaleId,
      );

      await _service.salvaMemoria(nuovaMemoria, bytes);
      await _caricaDati();

      _pencilController.stop();
      setState(() => _isDrawing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    int displayCount = memorie.length + 1;

    return Scaffold(
      backgroundColor: const Color(0xFFE0F7FA), // Cielo azzurro chiarissimo
      appBar: AppBar(
        title: Text("moment_summer_title".tr(), style: const TextStyle(fontFamily: 'Cursive', fontSize: 24, color: Colors.cyan)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.cyan), onPressed: () => Navigator.pop(context)),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _summerController,
              builder: (context, child) {
                return CustomPaint(
                  painter: MareArtisticoPainter(
                    numeroMomenti: memorie.length + 1 + (_isDrawing ? 1 : 0),
                    scrollOffset: _scrollOffset,
                    animationProgress: _summerController.value,
                  ),
                );
              },
            ),
          ),
          SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...List.generate(displayCount, (index) {
                  bool isPlaceholder = index == memorie.length;
                  return Container(
                    width: 350,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: isPlaceholder ? _aggiungiMomento : null,
                          child: Container(
                            width: 195,
                            height: 235,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.cyan[50]!, width: 8),
                              boxShadow: [BoxShadow(color: Colors.cyan.withOpacity(0.1), blurRadius: 10, spreadRadius: 2)],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: !isPlaceholder
                                ? Image.file(File(memorie[index].pathImmagine), fit: BoxFit.cover)
                                : const Icon(Icons.beach_access_rounded, size: 50, color: Colors.orangeAccent),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          isPlaceholder ? "moment_summer_placeholder".tr() : "moment_summer_memory_title".tr(args: [(index + 1).toString()]),
                          style: const TextStyle(fontFamily: 'Cursive', fontSize: 20, color: Colors.blueGrey)
                        ),
                      ],
                    ),
                  );
                }),
                if (_isDrawing) Container(width: 350),
              ],
            ),
          ),
          if (_isDrawing)
            AnimatedBuilder(
              animation: _pencilController,
              builder: (context, child) {
                double verticalSweep = math.sin(_pencilController.value * math.pi * 2) * 180;
                double trembleX = math.sin(_pencilController.value * math.pi * 40) * 5;
                double trembleY = math.cos(_pencilController.value * math.pi * 40) * 5;

                return Positioned(
                  right: 20 + trembleX,
                  top: (MediaQuery.of(context).size.height / 2) + verticalSweep + trembleY - 50,
                  child: Transform.rotate(
                    angle: -0.6 + (math.sin(_pencilController.value * math.pi * 10) * 0.2),
                    child: const Icon(
                        Icons.edit,
                        size: 85,
                        color: Colors.cyan
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pencilController.dispose();
    _summerController.dispose();
    super.dispose();
  }
}

class MareArtisticoPainter extends CustomPainter {
  final int numeroMomenti;
  final double scrollOffset;
  final double animationProgress;
  MareArtisticoPainter({required this.numeroMomenti, required this.scrollOffset, required this.animationProgress});

  @override
  void paint(Canvas canvas, Size size) {
    double larghezzaTotale = (numeroMomenti + 5) * 350.0;

    // --- IL MARE CON SFUMATURE ED ONDE ---
    final paintMareLontano = Paint()..color = const Color(0xFF00ACC1);
    final paintMareVicino = Paint()..color = const Color(0xFF4DD0E1);
    final paintSabbia = Paint()..color = const Color(0xFFFFE082);
    
    // Disegna mare profondo
    canvas.drawRect(Rect.fromLTWH(-scrollOffset * 0.3, size.height * 0.45, larghezzaTotale, size.height * 0.1), paintMareLontano);
    
    // Onde bianche sfumate nel mare
    final paintSchiuma = Paint()..color = Colors.white.withOpacity(0.3)..style = PaintingStyle.stroke..strokeWidth = 2;
    for (int i = 0; i < 5; i++) {
        double yOnda = size.height * 0.48 + (i * 15);
        double offsetOnda = math.sin(animationProgress * math.pi * 2 + i) * 20;
        Path wave = Path();
        wave.moveTo(-20, yOnda);
        for (double x = 0; x < size.width + 20; x += 30) {
            wave.quadraticBezierTo(x + 15 + offsetOnda, yOnda - 5, x + 30 + offsetOnda, yOnda);
        }
        canvas.drawPath(wave, paintSchiuma);
    }

    // Disegna mare vicino
    canvas.drawRect(Rect.fromLTWH(-scrollOffset * 0.6, size.height * 0.55, larghezzaTotale, size.height * 0.1), paintMareVicino);

    // --- PESCIOLINI ---
    _drawPesciolini(canvas, size);

    // --- LA SABBIA ---
    canvas.drawRect(Rect.fromLTWH(-scrollOffset, size.height * 0.65, larghezzaTotale, size.height * 0.35), paintSabbia);

    // --- EFFETTO ONDA RIVA ---
    final paintOndeRiva = Paint()..color = Colors.white.withOpacity(0.6)..style = PaintingStyle.fill;
    double rivaY = size.height * 0.65;
    double oscillazioneRiva = math.sin(animationProgress * math.pi * 2) * 5;
    
    for (int i = 0; i < numeroMomenti + 10; i++) {
      double xOnda = (i * 150) - scrollOffset;
      Path wavePath = Path();
      wavePath.moveTo(xOnda, rivaY + oscillazioneRiva);
      wavePath.quadraticBezierTo(xOnda + 75, rivaY - 10 + oscillazioneRiva, xOnda + 150, rivaY + oscillazioneRiva);
      wavePath.lineTo(xOnda + 150, rivaY + 20);
      wavePath.quadraticBezierTo(xOnda + 75, rivaY + 10, xOnda, rivaY + 20);
      canvas.drawPath(wavePath, paintOndeRiva);
    }

    // --- OGGETTI DEL MONDO ---
    for (int i = 0; i < numeroMomenti + 3; i++) {
      double xBase = (i * 350.0) - scrollOffset;

      // Cielo
      _drawSoleSplendente(canvas, xBase + 280, 80);
      _drawRondineInVolo(canvas, xBase + 50 + (math.sin(animationProgress * math.pi * 2 + i) * 30), 120 + (math.cos(animationProgress * math.pi * 2 + i) * 15), animationProgress);

      // Spiaggia
      if (i % 3 == 0) {
        _drawOmbrellone(canvas, xBase + 240, size.height * 0.72);
        _drawSdraio(canvas, xBase + 280, size.height * 0.8);
      } else if (i % 3 == 1) {
        _drawCastelloSabbia(canvas, xBase + 100, size.height * 0.85);
        _drawSecchiello(canvas, xBase + 160, size.height * 0.88);
      } else {
        _drawPalma(canvas, xBase + 60, size.height * 0.7);
        _drawPallaMare(canvas, xBase + 200, size.height * 0.9);
      }
    }
  }

  void _drawPesciolini(Canvas canvas, Size size) {
      final fishPaint = Paint()..color = Colors.orangeAccent.withOpacity(0.8);
      for (int i = 0; i < 4; i++) {
          double x = ((animationProgress + i * 0.25) % 1.0) * size.width;
          double y = size.height * 0.5 + (math.sin(animationProgress * math.pi * 4 + i) * 10);
          
          canvas.save();
          canvas.translate(x, y);
          // Corpo
          canvas.drawOval(Rect.fromLTWH(0, 0, 12, 6), fishPaint);
          // Coda
          Path tail = Path();
          tail.moveTo(0, 3);
          tail.lineTo(-4, 0);
          tail.lineTo(-4, 6);
          tail.close();
          canvas.drawPath(tail, fishPaint);
          canvas.restore();
      }
  }

  void _drawSoleSplendente(Canvas canvas, double x, double y) {
    // Il sole ruota leggermente o pulsa
    double pulse = math.sin(animationProgress * math.pi * 2) * 3;
    final solePaint = Paint()..color = Colors.orange[400]!;
    canvas.drawCircle(Offset(x, y), 30 + pulse, solePaint);
    
    // --- VISO SORRIDENTE ---
    final facePaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.fill;
    
    // Occhietti
    canvas.drawCircle(Offset(x - 8, y - 5), 3, facePaint);
    canvas.drawCircle(Offset(x + 8, y - 5), 3, facePaint);
    
    // Sorriso
    final smilePaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    
    canvas.drawArc(
      Rect.fromCenter(center: Offset(x, y + 5), width: 20, height: 12),
      0.2, 
      math.pi - 0.4, 
      false,
      smilePaint,
    );

    final raggiPaint = Paint()..color = Colors.orange[300]!..strokeWidth = 3;
    for (int j = 0; j < 12; j++) {
      double angle = j * (math.pi * 2) / 12 + (animationProgress * 0.5); // Rotazione lenta
      double rStart = 35 + pulse;
      double rEnd = 55 + pulse;
      canvas.drawLine(
          Offset(x + math.cos(angle) * rStart, y + math.sin(angle) * rStart),
          Offset(x + math.cos(angle) * rEnd, y + math.sin(angle) * rEnd),
          raggiPaint
      );
    }
  }

  void _drawRondineInVolo(Canvas canvas, double x, double y, double progress) {
    final p = Paint()..color = Colors.black87..style = PaintingStyle.stroke..strokeWidth = 2;
    // Battito d'ali
    double wingAngle = math.sin(progress * math.pi * 8) * 0.5;
    
    canvas.save();
    canvas.translate(x, y);
    
    // Ala sinistra
    Path wingL = Path();
    wingL.moveTo(0, 0);
    wingL.quadraticBezierTo(-10, -10 - (wingAngle * 10), -20, 0);
    canvas.drawPath(wingL, p);
    
    // Ala destra
    Path wingR = Path();
    wingR.moveTo(0, 0);
    wingR.quadraticBezierTo(10, -10 - (wingAngle * 10), 20, 0);
    canvas.drawPath(wingR, p);
    
    canvas.restore();
  }

  void _drawOmbrellone(Canvas canvas, double x, double y) {
    final p = Paint()..style = PaintingStyle.fill;
    p.color = Colors.brown[300]!;
    canvas.drawRect(Rect.fromLTWH(x, y, 4, 80), p);
    p.color = Colors.redAccent;
    canvas.drawArc(Rect.fromLTWH(x - 50, y - 20, 104, 60), 3.14, 3.14, true, p);
    p.color = Colors.white;
    canvas.drawArc(Rect.fromLTWH(x - 30, y - 20, 64, 60), 3.14, 3.14, true, p);
  }

  void _drawSdraio(Canvas canvas, double x, double y) {
    final p = Paint()..color = Colors.blue[300]!..strokeWidth = 4..style = PaintingStyle.stroke;
    Path tela = Path();
    tela.moveTo(x, y);
    tela.lineTo(x + 40, y + 10);
    tela.lineTo(x + 50, y + 40);
    canvas.drawPath(tela, p);
    p..color = Colors.brown[400]!..strokeWidth = 2;
    canvas.drawLine(Offset(x, y), Offset(x, y + 40), p);
    canvas.drawLine(Offset(x + 40, y + 10), Offset(x + 40, y + 40), p);
  }

  void _drawCastelloSabbia(Canvas canvas, double x, double y) {
    final p = Paint()..color = const Color(0xFFD4AF37); 
    canvas.drawRect(Rect.fromLTWH(x, y, 60, 40), p);
    canvas.drawRect(Rect.fromLTWH(x, y - 20, 15, 20), p);
    canvas.drawRect(Rect.fromLTWH(x + 45, y - 20, 15, 20), p);
    canvas.drawRect(Rect.fromLTWH(x + 20, y - 10, 20, 10), p);
    canvas.drawLine(Offset(x + 30, y - 10), Offset(x + 30, y - 30), Paint()..color = Colors.black);
    canvas.drawPath(Path()..moveTo(x + 30, y - 30)..lineTo(x + 45, y - 25)..lineTo(x + 30, y - 20), Paint()..color = Colors.red);
  }

  void _drawSecchiello(Canvas canvas, double x, double y) {
    final p = Paint()..color = Colors.blueAccent;
    Path secchio = Path();
    secchio.moveTo(x, y);
    secchio.lineTo(x + 20, y);
    secchio.lineTo(x + 15, y + 20);
    secchio.lineTo(x + 5, y + 20);
    secchio.close();
    canvas.drawPath(secchio, p);
    canvas.drawArc(Rect.fromLTWH(x, y - 10, 20, 20), 3.14, 3.14, false, Paint()..style = PaintingStyle.stroke..color = Colors.grey);
  }

  void _drawPalma(Canvas canvas, double x, double y) {
    final tronco = Paint()..color = Colors.brown[400]!;
    canvas.drawRect(Rect.fromLTWH(x, y - 100, 12, 100), tronco);
    final foglie = Paint()..color = Colors.green[700]!;
    for (int j = 0; j < 5; j++) {
      double angle = j * (math.pi / 2.5);
      canvas.save();
      canvas.translate(x + 6, y - 100);
      canvas.rotate(angle);
      canvas.drawOval(Rect.fromLTWH(0, -5, 50, 15), foglie);
      canvas.restore();
    }
  }

  void _drawPallaMare(Canvas canvas, double x, double y) {
    canvas.drawCircle(Offset(x, y), 15, Paint()..color = Colors.white);
    canvas.drawArc(Rect.fromCircle(center: Offset(x, y), radius: 15), 0, 2.1, true, Paint()..color = Colors.redAccent);
    canvas.drawArc(Rect.fromCircle(center: Offset(x, y), radius: 15), 2.1, 2.1, true, Paint()..color = Colors.blueAccent);
    canvas.drawArc(Rect.fromCircle(center: Offset(x, y), radius: 15), 4.2, 2.1, true, Paint()..color = Colors.yellowAccent);
  }

  @override
  bool shouldRepaint(covariant MareArtisticoPainter oldDelegate) =>
      oldDelegate.scrollOffset != scrollOffset || 
      oldDelegate.animationProgress != animationProgress ||
      oldDelegate.numeroMomenti != numeroMomenti;
}
