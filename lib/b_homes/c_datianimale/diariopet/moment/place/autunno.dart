import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import '../momenti_service.dart';
import '../modello_memoria.dart';

class AutunnoMomentiPage extends StatefulWidget {
  final String animaleId;
  const AutunnoMomentiPage({super.key, required this.animaleId});

  @override
  State<AutunnoMomentiPage> createState() => _AutunnoMomentiPageState();
}

class _AutunnoMomentiPageState extends State<AutunnoMomentiPage> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;
  List<Memoria> memorie = [];
  final MomentiService _service = MomentiService();
  final ImagePicker _picker = ImagePicker();

  late AnimationController _pencilController;
  late AnimationController _leavesController;
  bool _isDrawing = false;

  @override
  void initState() {
    super.initState();
    
    _pencilController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    
    _leavesController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25), 
    )..repeat();

    _scrollController.addListener(() {
      if (mounted) {
        setState(() => _scrollOffset = _scrollController.offset);
      }
    });

    _caricaDati();
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
    final lista = await _service.caricaMemorie(widget.animaleId, 'Autunno');
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
        titolo: "moment_autumn_default_title".tr(),
        descrizione: "",
        pathImmagine: "",
        categoria: 'Autunno',
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
      backgroundColor: const Color(0xFFFBE9E7), 
      appBar: AppBar(
        title: Text("moment_autumn_title".tr(), style: const TextStyle(fontFamily: 'Cursive', fontSize: 26, color: Colors.brown)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.brown), onPressed: () => Navigator.pop(context)),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _leavesController,
              builder: (context, child) {
                return CustomPaint(
                  painter: AutunnoArtisticoPainter(
                    numeroMomenti: memorie.length + 1 + (_isDrawing ? 1 : 0),
                    scrollOffset: _scrollOffset,
                    leavesProgress: _leavesController.value,
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
                            width: 190,
                            height: 250,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.orange[100]!, width: 8),
                              boxShadow: [BoxShadow(color: Colors.brown.withOpacity(0.1), blurRadius: 10, spreadRadius: 2)],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: !isPlaceholder
                                ? Image.file(File(memorie[index].pathImmagine), fit: BoxFit.cover)
                                : const Icon(Icons.eco, size: 50, color: Colors.orange),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          isPlaceholder ? "moment_autumn_placeholder".tr() : "moment_autumn_memory_title".tr(args: [(index + 1).toString()]),
                          style: const TextStyle(fontFamily: 'Cursive', fontSize: 20, color: Colors.brown)
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
                        color: Colors.brown
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
    _leavesController.dispose();
    super.dispose();
  }
}

class AutunnoArtisticoPainter extends CustomPainter {
  final int numeroMomenti;
  final double scrollOffset;
  final double leavesProgress;
  AutunnoArtisticoPainter({required this.numeroMomenti, required this.scrollOffset, required this.leavesProgress});

  @override
  void paint(Canvas canvas, Size size) {
    double larghezzaTotale = (numeroMomenti + 5) * 350.0;

    final verniceSfondo = Paint()..color = Colors.brown[100]!.withOpacity(0.3);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), verniceSfondo);

    final paintTerreno = Paint()..color = const Color(0xFF8D6E63); 
    canvas.drawRect(Rect.fromLTWH(-scrollOffset, size.height * 0.7, larghezzaTotale, size.height * 0.3), paintTerreno);

    for (int i = 0; i < numeroMomenti + 5; i++) {
      double xBase = (i * 350.0) - scrollOffset;
      _drawAlberoAutunnale(canvas, xBase + 50, size.height * 0.7);
      _drawAlberoSpennato(canvas, xBase + 300, size.height * 0.7);
      _drawZucca(canvas, xBase + 220, size.height * 0.72);
      
      if (i % 2 == 0) {
        _drawPozzanghera(canvas, xBase + 180, size.height * 0.75);
        _drawCestinoCastagne(canvas, xBase + 120, size.height * 0.82);
      } else {
        _drawFogliaAterra(canvas, xBase + 40, size.height * 0.85, i);
        _drawFogliaAterra(canvas, xBase + 85, size.height * 0.88, i + 10);
        _drawCestinoCastagne(canvas, xBase + 260, size.height * 0.88);
      }
    }

    // Pioggia di foglie continua
    for (int i = 0; i < 40; i++) {
      _drawFogliaCadente(canvas, size, i);
    }
  }

  void _drawAlberoAutunnale(Canvas canvas, double x, double y) {
    final tronco = Paint()..color = const Color(0xFF4E342E);
    final chioma = Paint()..color = Colors.orange[800]!;

    canvas.drawRect(Rect.fromLTWH(x, y - 100, 15, 100), tronco);

    canvas.drawCircle(Offset(x + 7, y - 110), 40, chioma);
    canvas.drawCircle(Offset(x - 20, y - 90), 30, chioma..color = Colors.deepOrange[700]!);
    canvas.drawCircle(Offset(x + 35, y - 90), 30, chioma..color = Colors.brown[400]!);
  }

  void _drawAlberoSpennato(Canvas canvas, double x, double y) {
    final tronco = Paint()..color = const Color(0xFF3E2723)..strokeWidth = 4..strokeCap = StrokeCap.round;
    
    Path path = Path();
    path.moveTo(x, y);
    path.quadraticBezierTo(x + 5, y - 40, x - 2, y - 90);
    canvas.drawPath(path, tronco..style = PaintingStyle.stroke);
    
    final ramoPaint = Paint()..color = const Color(0xFF3E2723)..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(x - 1, y - 50), Offset(x - 20, y - 75), ramoPaint..strokeWidth = 2);
    canvas.drawLine(Offset(x, y - 70), Offset(x + 15, y - 95), ramoPaint..strokeWidth = 2);
    canvas.drawLine(Offset(x - 2, y - 90), Offset(x - 10, y - 110), ramoPaint..strokeWidth = 1.5);
    canvas.drawLine(Offset(x - 2, y - 90), Offset(x + 12, y - 115), ramoPaint..strokeWidth = 1.5);
  }

  void _drawCestinoCastagne(Canvas canvas, double x, double y) {
    final pCesto = Paint()..color = const Color(0xFFA1887F);
    final pTrama = Paint()..color = const Color(0xFF795548)..style = PaintingStyle.stroke..strokeWidth = 1.5;

    // Manico
    canvas.drawArc(Rect.fromLTWH(x + 5, y - 12, 25, 20), math.pi, math.pi, false, pTrama);

    // Castagne dentro
    _drawCastagna(canvas, x + 4, y - 2);
    _drawCastagna(canvas, x + 12, y - 4);
    _drawCastagna(canvas, x + 20, y - 2);

    // Corpo del cesto
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, 35, 18), const Radius.circular(4)), pCesto);
    
    for(double i = x + 7; i < x + 35; i += 7) {
      canvas.drawLine(Offset(i, y), Offset(i, y + 18), pTrama..strokeWidth = 1);
    }
    canvas.drawLine(Offset(x, y + 9), Offset(x + 35, y + 9), pTrama..strokeWidth = 1);
  }

  void _drawCastagna(Canvas canvas, double x, double y) {
    final p = Paint()..color = const Color(0xFF4E342E);
    canvas.drawOval(Rect.fromLTWH(x, y, 12, 9), p);
    canvas.drawArc(Rect.fromLTWH(x + 2, y + 5, 8, 4), 0, math.pi, true, Paint()..color = const Color(0xFF8D6E63));
  }

  void _drawFogliaAterra(Canvas canvas, double x, double y, int seed) {
    final random = math.Random(seed);
    final colors = [
      Colors.orange[700]!,
      Colors.brown[400]!,
      Colors.deepOrange[400]!,
    ];
    final p = Paint()..color = colors[random.nextInt(colors.length)];
    
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(random.nextDouble() * math.pi * 2);
    
    Path leaf = Path();
    leaf.moveTo(0, 0);
    leaf.quadraticBezierTo(8, -5, 18, 0);
    leaf.quadraticBezierTo(8, 5, 0, 0);
    canvas.drawPath(leaf, p);
    
    canvas.restore();
  }

  void _drawZucca(Canvas canvas, double x, double y) {
    final p = Paint()..color = Colors.orange[900]!;
    canvas.drawOval(Rect.fromCenter(center: Offset(x, y), width: 40, height: 30), p);
    canvas.drawOval(Rect.fromCenter(center: Offset(x, y), width: 20, height: 30), p..color = Colors.orange[800]!);
    canvas.drawRect(Rect.fromLTWH(x - 2, y - 20, 4, 8), Paint()..color = Colors.green[800]!);
  }

  void _drawFogliaCadente(Canvas canvas, Size size, int index) {
    final random = math.Random(index);
    final p = Paint()..color = (index % 3 == 0)
        ? Colors.orange[700]! 
        : (index % 3 == 1 ? Colors.brown[400]! : Colors.deepOrange[400]!);

    double individualSpeed = 0.8 + (random.nextDouble() * 0.4);
    double individualPhase = random.nextDouble() * math.pi * 2;
    
    double xStart = (index * (size.width / 10)) % size.width;
    double offsetIniziale = (index * 120.0);
    
    double yPos = ((leavesProgress * individualSpeed * size.height) + offsetIniziale) % (size.height + 150) - 100;
    
    double xOscillazione = math.sin(leavesProgress * math.pi * 4 + individualPhase) * 50;
    double xFinal = (xStart + xOscillazione) % size.width;

    canvas.save();
    canvas.translate(xFinal, yPos);
    canvas.rotate(math.sin(leavesProgress * math.pi * 3 + individualPhase) * 1.2);
    
    Path leaf = Path();
    leaf.moveTo(0, 0);
    leaf.quadraticBezierTo(12, -8, 24, 0);
    leaf.quadraticBezierTo(12, 8, 0, 0);
    canvas.drawPath(leaf, p);

    canvas.restore();
  }

  void _drawPozzanghera(Canvas canvas, double x, double y) {
    final p = Paint()..color = Colors.blueGrey[200]!.withOpacity(0.5);
    canvas.drawOval(Rect.fromCenter(center: Offset(x, y), width: 60, height: 10), p);
  }

  @override
  bool shouldRepaint(covariant AutunnoArtisticoPainter oldDelegate) =>
      oldDelegate.scrollOffset != scrollOffset || 
      oldDelegate.numeroMomenti != numeroMomenti ||
      oldDelegate.leavesProgress != leavesProgress;
}
