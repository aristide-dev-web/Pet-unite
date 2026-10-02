import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import '../momenti_service.dart';
import '../modello_memoria.dart';

class PrimaveraMomentiPage extends StatefulWidget {
  final String animaleId;
  const PrimaveraMomentiPage({super.key, required this.animaleId});

  @override
  State<PrimaveraMomentiPage> createState() => _PrimaveraMomentiPageState();
}

class _PrimaveraMomentiPageState extends State<PrimaveraMomentiPage> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;
  List<Memoria> memorie = [];
  final MomentiService _service = MomentiService();
  final ImagePicker _picker = ImagePicker();

  late AnimationController _pencilController;
  late AnimationController _petalsController;
  bool _isDrawing = false;

  @override
  void initState() {
    super.initState();
    _caricaDati();
    _pencilController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _petalsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
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
    final lista = await _service.caricaMemorie(widget.animaleId, 'Primavera');
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
        titolo: "moment_spring_default_title".tr(),
        descrizione: "",
        pathImmagine: "",
        categoria: 'Primavera',
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
      backgroundColor: const Color(0xFFFDF2F4), 
      appBar: AppBar(
        title: Text("moment_spring_title".tr(), style: const TextStyle(fontFamily: 'Cursive', fontSize: 26, color: Color(0xFFF06292))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFF06292)), onPressed: () => Navigator.pop(context)),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _petalsController,
              builder: (context, child) {
                return CustomPaint(
                  painter: PrimaveraArtisticaPainter(
                      numeroMomenti: memorie.length + 1 + (_isDrawing ? 1 : 0),
                      scrollOffset: _scrollOffset,
                      petalsProgress: _petalsController.value,
                  ),
                );
              }
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
                          child: Transform.rotate(
                            angle: index % 2 == 0 ? 0.02 : -0.02,
                            child: Container(
                              width: 190,
                              height: 250,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: const Color(0xFFFCE4EC), width: 6),
                                boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.05), blurRadius: 15, offset: const Offset(4, 4))],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: !isPlaceholder
                                  ? Image.file(File(memorie[index].pathImmagine), fit: BoxFit.cover)
                                  : const Icon(Icons.favorite_border, size: 50, color: Color(0xFFF48FB1)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          isPlaceholder ? "moment_spring_placeholder".tr() : "moment_spring_memory_title".tr(args: [(index + 1).toString()]),
                          style: const TextStyle(fontFamily: 'Cursive', fontSize: 18, color: Color(0xFFD81B60))
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
                        color: Color(0xFFF06292)
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
    _petalsController.dispose();
    super.dispose();
  }
}

class PrimaveraArtisticaPainter extends CustomPainter {
  final int numeroMomenti;
  final double scrollOffset;
  final double petalsProgress;
  PrimaveraArtisticaPainter({required this.numeroMomenti, required this.scrollOffset, required this.petalsProgress});

  @override
  void paint(Canvas canvas, Size size) {
    double larghezzaMondo = (numeroMomenti + 5) * 350.0;

    final cieloPaint = Paint()..color = const Color(0xFFFCE4EC);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), cieloPaint);

    final pratoPaint = Paint()..color = const Color(0xFFE8F5E9);
    canvas.drawRect(Rect.fromLTWH(-scrollOffset, size.height * 0.75, larghezzaMondo, size.height * 0.25), pratoPaint);

    for(int i=0; i < 40; i++) {
      _drawPetaloCadente(canvas, size, i);
    }

    for (int i = 0; i < numeroMomenti + 5; i++) {
      double x = (i * 350.0) - scrollOffset;
      _drawCiliegioInFiore(canvas, x + 60, size.height * 0.75);
      if (i % 2 == 0) {
        _drawPanchinaRomantica(canvas, x + 240, size.height * 0.82);
      } else {
        _drawLampioneStilizzato(canvas, x + 280, size.height * 0.75);
      }
      
      _drawGrandiFiori(canvas, x, 350, size.height * 0.75, size.height * 0.25, scrollOffset);
    }
  }

  void _drawGrandiFiori(Canvas canvas, double startX, double width, double yBase, double height, double currentScroll) {
    // Seed fisso basato sulla coordinata X originale del blocco per stabilità
    final originalX = startX + currentScroll;
    final random = math.Random(originalX.toInt().abs() + 2);
    final colors = [
      Colors.pink[100]!,
      Colors.purple[100]!,
      Colors.yellow[100]!,
      Colors.blue[100]!,
    ];
    
    for (int i = 0; i < 4; i++) {
      double fx = startX + random.nextDouble() * width;
      double fy = yBase + random.nextDouble() * height;
      double size = 12 + random.nextDouble() * 6;
      
      final p = Paint()..style = PaintingStyle.fill;
      p.color = colors[i % colors.length];
      
      for (int j = 0; j < 5; j++) {
        double angle = (j * 2 * math.pi) / 5;
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(fx + math.cos(angle) * (size/1.5), fy + math.sin(angle) * (size/1.5)),
            width: size,
            height: size * 0.7,
          ),
          p,
        );
      }
      
      p.color = Colors.yellow[600]!;
      canvas.drawCircle(Offset(fx, fy), size * 0.4, p);
      
      final steloPaint = Paint()..color = Colors.green[300]!..strokeWidth = 2;
      canvas.drawLine(Offset(fx, fy + size * 0.4), Offset(fx, fy + size * 1.5), steloPaint);
    }
  }

  void _drawPetaloCadente(Canvas canvas, Size size, int index) {
    final random = math.Random(index);
    final p = Paint()..color = Colors.pink[100]!.withOpacity(0.7)..style = PaintingStyle.fill;
    double individualSpeed = 0.7 + (random.nextDouble() * 0.5);
    double individualPhase = random.nextDouble() * math.pi * 2;
    double xStart = (index * (size.width / 12)) % size.width;
    double offsetIniziale = (index * 70.0);
    double yPos = ((petalsProgress * individualSpeed * size.height) + offsetIniziale) % (size.height + 150) - 100;
    double xOscillazione = math.sin(petalsProgress * math.pi * 4 + individualPhase) * 45;
    double xFinal = (xStart + xOscillazione) % size.width;
    canvas.save();
    canvas.translate(xFinal, yPos);
    canvas.rotate(math.sin(petalsProgress * math.pi * 3 + individualPhase) * 1.0);
    canvas.drawOval(Rect.fromLTWH(0, 0, 11, 6), p);
    canvas.restore();
  }

  void _drawCiliegioInFiore(Canvas canvas, double x, double yBase) {
    final tronco = Paint()..color = const Color(0xFF5D4037);
    final chiomaRosa = Paint()..color = const Color(0xFFF48FB1);
    final chiomaScura = Paint()..color = const Color(0xFFF06292);
    Path trunk = Path();
    trunk.moveTo(x, yBase);
    trunk.quadraticBezierTo(x - 10, yBase - 40, x, yBase - 80);
    trunk.lineTo(x + 15, yBase - 80);
    trunk.quadraticBezierTo(x + 25, yBase - 40, x + 15, yBase);
    trunk.close();
    canvas.drawPath(trunk, tronco);
    canvas.drawCircle(Offset(x + 7, yBase - 100), 45, chiomaRosa);
    canvas.drawCircle(Offset(x - 25, yBase - 85), 35, chiomaRosa);
    canvas.drawCircle(Offset(x + 40, yBase - 85), 35, chiomaRosa);
    canvas.drawCircle(Offset(x + 10, yBase - 110), 4, chiomaScura);
    canvas.drawCircle(Offset(x - 15, yBase - 90), 4, chiomaScura);
    canvas.drawCircle(Offset(x + 30, yBase - 95), 4, chiomaScura);
  }

  void _drawPanchinaRomantica(Canvas canvas, double x, double yBase) {
    final legno = Paint()..color = const Color(0xFF8D6E63)..style = PaintingStyle.fill;
    final ferro = Paint()..color = Colors.black87..style = PaintingStyle.stroke..strokeWidth = 2;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, yBase, 60, 6), const Radius.circular(2)), legno);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, yBase - 20, 60, 6), const Radius.circular(2)), legno);
    canvas.drawLine(Offset(x + 5, yBase), Offset(x + 5, yBase + 12), ferro);
    canvas.drawLine(Offset(x + 55, yBase), Offset(x + 55, yBase + 12), ferro);
    canvas.drawLine(Offset(x + 5, yBase - 20), Offset(x + 5, yBase), ferro);
    canvas.drawLine(Offset(x + 55, yBase - 20), Offset(x + 55, yBase), ferro);
  }

  void _drawLampioneStilizzato(Canvas canvas, double x, double yBase) {
    final p = Paint()..color = Colors.black87..style = PaintingStyle.stroke..strokeWidth = 2;
    canvas.drawLine(Offset(x, yBase), Offset(x, yBase - 130), p);
    canvas.drawCircle(Offset(x, yBase - 130), 12, Paint()..color = const Color(0xFFFFF176));
    canvas.drawCircle(Offset(x, yBase - 130), 12, p);
  }

  @override
  bool shouldRepaint(covariant PrimaveraArtisticaPainter oldDelegate) =>
      oldDelegate.scrollOffset != scrollOffset || 
      oldDelegate.numeroMomenti != numeroMomenti ||
      oldDelegate.petalsProgress != petalsProgress;
}
