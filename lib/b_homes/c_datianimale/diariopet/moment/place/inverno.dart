import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import '../momenti_service.dart';
import '../modello_memoria.dart';

class InvernoMomentiPage extends StatefulWidget {
  final String animaleId;
  const InvernoMomentiPage({super.key, required this.animaleId});

  @override
  State<InvernoMomentiPage> createState() => _InvernoMomentiPageState();
}

class _InvernoMomentiPageState extends State<InvernoMomentiPage> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;
  List<Memoria> memorie = [];
  final MomentiService _service = MomentiService();
  final ImagePicker _picker = ImagePicker();

  late AnimationController _pencilController;
  late AnimationController _snowController;
  bool _isDrawing = false;

  @override
  void initState() {
    super.initState();
    
    _pencilController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    
    _snowController = AnimationController(
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
    final lista = await _service.caricaMemorie(widget.animaleId, 'Inverno');
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
        titolo: "moment_winter_default_title".tr(),
        descrizione: "",
        pathImmagine: "",
        categoria: 'Inverno',
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
      backgroundColor: const Color(0xFFF0F4F8), 
      appBar: AppBar(
        title: Text("moment_winter_title".tr(), style: const TextStyle(fontFamily: 'Cursive', fontSize: 26, color: Colors.redAccent)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.redAccent), onPressed: () => Navigator.pop(context)),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _snowController,
              builder: (context, child) {
                return CustomPaint(
                  painter: InvernoArtisticoPainter(
                    numeroMomenti: displayCount + (_isDrawing ? 1 : 0),
                    scrollOffset: _scrollOffset,
                    snowProgress: _snowController.value,
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
                            width: 200,
                            height: 250,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.red[100]!, width: 6),
                              boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.05), blurRadius: 15)],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: !isPlaceholder
                                ? Image.file(File(memorie[index].pathImmagine), fit: BoxFit.cover)
                                : const Icon(Icons.ac_unit_rounded, size: 50, color: Colors.redAccent),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          isPlaceholder ? "moment_winter_placeholder".tr() : "moment_winter_memory_title".tr(args: [(index + 1).toString()]),
                          style: const TextStyle(fontFamily: 'Cursive', fontSize: 20, color: Colors.green, fontWeight: FontWeight.bold),
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
                    child: const Icon(Icons.edit, size: 85, color: Colors.redAccent),
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
    _snowController.dispose();
    super.dispose();
  }
}

class InvernoArtisticoPainter extends CustomPainter {
  final int numeroMomenti;
  final double scrollOffset;
  final double snowProgress;
  InvernoArtisticoPainter({required this.numeroMomenti, required this.scrollOffset, required this.snowProgress});

  @override
  void paint(Canvas canvas, Size size) {
    double larghezzaMondo = (numeroMomenti + 5) * 350.0;

    // Suolo innevato
    final pNeve = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(-scrollOffset, size.height * 0.7, larghezzaMondo, size.height * 0.3), pNeve);
    final pOmbraNeve = Paint()..color = Colors.blue[50]!;
    canvas.drawRect(Rect.fromLTWH(-scrollOffset, size.height * 0.68, larghezzaMondo, 15), pOmbraNeve);

    // NEVICATA - Quantità e velocità sincronizzate con Autunno
    final int numeroFiocchi = 40; 
    final pFiocco = Paint()..color = Colors.white.withOpacity(0.8);

    for (int i = 0; i < numeroFiocchi; i++) {
      final random = math.Random(i);
      
      // Variazione individuale come in autunno
      double individualSpeed = 0.8 + (random.nextDouble() * 0.4);
      double individualPhase = random.nextDouble() * math.pi * 2;
      
      double xStart = (i * (size.width / 10)) % size.width;
      double offsetIniziale = (i * 120.0);
      
      // Y calcolata con velocità variabile
      double yPos = ((snowProgress * individualSpeed * size.height) + offsetIniziale) % (size.height + 150) - 100;
      
      // Oscillazione simile alle foglie ma più "leggera"
      double xOscillazione = math.sin(snowProgress * math.pi * 4 + individualPhase) * 40;
      double xFinal = (xStart + xOscillazione) % size.width;

      Offset center = Offset(xFinal, yPos);
      
      if (i % 8 == 0) {
        // Ogni tanto un fiocchetto a stellina
        final pStellina = Paint()..color = Colors.blue[100]!..style = PaintingStyle.stroke..strokeWidth = 1.2;
        double s = 5.0;
        canvas.drawLine(center + Offset(-s, 0), center + Offset(s, 0), pStellina);
        canvas.drawLine(center + Offset(0, -s), center + Offset(0, s), pStellina);
      } else {
        canvas.drawCircle(center, 2.5 + (random.nextDouble() * 3), pFiocco);
      }
    }

    for (int i = 0; i < numeroMomenti + 4; i++) {
      double x = (i * 350.0) - scrollOffset;
      _drawAbeteDecorato(canvas, x + 30, size.height * 0.7);
      
      if (i % 2 == 0) {
        _drawPupazzoDettagliato(canvas, x + 60, size.height * 0.8);
      } else {
        _drawOminoMarzapane(canvas, x + 65, size.height * 0.85);
        _drawBastoncinoZucchero(canvas, x + 40, size.height * 0.82);
      }
      
      _drawCasaMarzapane(canvas, x + 285, size.height * 0.7);
    }
  }

  void _drawCasaMarzapane(Canvas canvas, double x, double yBase) {
    final corpo = Paint()..color = const Color(0xFF8D6E63);
    final tetto = Paint()..color = const Color(0xFF5D4037);
    final glassa = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2.5;
    final finestra = Paint()..color = Colors.yellow[100]!;
    final neveTetto = Paint()..color = Colors.white;
    
    // Camino
    canvas.drawRect(Rect.fromLTWH(x + 32, yBase - 85, 8, 20), Paint()..color = const Color(0xFF4E342E));
    canvas.drawRect(Rect.fromLTWH(x + 31, yBase - 87, 10, 3), neveTetto);
    
    // Corpo casa
    canvas.drawRect(Rect.fromLTWH(x, yBase - 55, 50, 55), corpo);
    
    // Tetto
    Path tPath = Path();
    tPath.moveTo(x - 8, yBase - 55);
    tPath.lineTo(x + 25, yBase - 90);
    tPath.lineTo(x + 58, yBase - 55);
    tPath.close();
    canvas.drawPath(tPath, tetto);
    
    // Neve sul tetto
    canvas.drawPath(tPath, neveTetto..style = PaintingStyle.stroke..strokeWidth = 5);
    
    // Glassa decorativa
    canvas.drawLine(Offset(x - 8, yBase - 55), Offset(x + 25, yBase - 90), glassa);
    canvas.drawLine(Offset(x + 25, yBase - 90), Offset(x + 58, yBase - 55), glassa);
    
    // Porta con arco
    canvas.drawRRect(RRect.fromRectAndCorners(
      Rect.fromLTWH(x + 17, yBase - 28, 16, 28),
      topLeft: const Radius.circular(8),
      topRight: const Radius.circular(8),
    ), Paint()..color = const Color(0xFF3E2723));
    
    // Pomello porta
    canvas.drawCircle(Offset(x + 29, yBase - 14), 1.5, Paint()..color = Colors.yellow);
    
    // Finestrella rotonda luminosa
    canvas.drawCircle(Offset(x + 25, yBase - 65), 7, finestra);
    canvas.drawCircle(Offset(x + 25, yBase - 65), 7, glassa..strokeWidth = 1.5);
    // Croce finestra
    canvas.drawLine(Offset(x + 18, yBase - 65), Offset(x + 32, yBase - 65), glassa);
    canvas.drawLine(Offset(x + 25, yBase - 72), Offset(x + 25, yBase - 58), glassa);
    
    // Zuccherini colorati alla base
    for(int i = 0; i < 5; i++) {
       canvas.drawCircle(Offset(x + 5 + (i * 10), yBase - 5), 3, Paint()..color = (i % 2 == 0 ? Colors.redAccent : Colors.greenAccent));
    }
  }

  void _drawAbeteDecorato(Canvas canvas, double x, double yBase) {
    final tronco = Paint()..color = const Color(0xFF5D4037);
    final chioma = Paint()..color = const Color(0xFF1B5E20);
    canvas.drawRect(Rect.fromLTWH(x + 10, yBase - 120, 12, 120), tronco);
    for (int i = 0; i < 3; i++) {
      double width = 50.0 - (i * 12);
      Path p = Path();
      p.moveTo(x + 16 - width, yBase - 30 - (i * 35));
      p.lineTo(x + 16, yBase - 80 - (i * 35));
      p.lineTo(x + 16 + width, yBase - 30 - (i * 35));
      p.close();
      canvas.drawPath(p, chioma);
      canvas.drawCircle(Offset(x + 16 - width/2, yBase - 40 - (i * 35)), 4, Paint()..color = Colors.red);
      canvas.drawCircle(Offset(x + 16 + width/2, yBase - 40 - (i * 35)), 4, Paint()..color = Colors.red);
    }
  }

  void _drawPupazzoDettagliato(Canvas canvas, double x, double yBase) {
    final p = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(x, yBase - 20), 22, p);
    canvas.drawCircle(Offset(x, yBase - 50), 16, p);
    canvas.drawCircle(Offset(x, yBase - 72), 11, p);
    final pRosso = Paint()..color = Colors.redAccent;
    canvas.drawRect(Rect.fromLTWH(x - 12, yBase - 84, 24, 4), pRosso);
    canvas.drawRect(Rect.fromLTWH(x - 8, yBase - 98, 16, 14), pRosso);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x - 12, yBase - 60, 24, 6), const Radius.circular(5)), pRosso);
    canvas.drawPath(Path()..moveTo(x, yBase - 72)..lineTo(x + 15, yBase - 70)..lineTo(x, yBase - 68)..close(), Paint()..color = Colors.orange);
    canvas.drawCircle(Offset(x - 4, yBase - 76), 1.5, Paint()..color = Colors.black);
    canvas.drawCircle(Offset(x + 4, yBase - 76), 1.5, Paint()..color = Colors.black);
  }

  void _drawOminoMarzapane(Canvas canvas, double x, double y) {
    final p = Paint()..color = const Color(0xFF8D6E63);
    canvas.drawCircle(Offset(x, y - 25), 8, p);
    canvas.drawRect(Rect.fromCenter(center: Offset(x, y - 15), width: 14, height: 16), p);
    canvas.drawCircle(Offset(x - 10, y - 18), 4, p);
    canvas.drawCircle(Offset(x + 10, y - 18), 4, p);
    canvas.drawCircle(Offset(x - 5, y - 5), 4, p);
    canvas.drawCircle(Offset(x + 5, y - 5), 4, p);
    final glassa = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 1.5;
    canvas.drawCircle(Offset(x - 3, y - 26), 1, Paint()..color = Colors.black);
    canvas.drawCircle(Offset(x + 3, y - 26), 1, Paint()..color = Colors.black);
    canvas.drawLine(Offset(x - 8, y - 18), Offset(x - 12, y - 18), glassa);
    canvas.drawLine(Offset(x + 8, y - 18), Offset(x + 12, y - 18), glassa);
  }

  void _drawBastoncinoZucchero(Canvas canvas, double x, double y) {
    final p = Paint()..color = Colors.white..strokeWidth = 5..style = PaintingStyle.stroke;
    Path b = Path();
    b.moveTo(x, y);
    b.lineTo(x, y - 30);
    b.arcTo(Rect.fromLTWH(x - 15, y - 45, 15, 30), 0, -3.14, false);
    canvas.drawPath(b, p);
    p.color = Colors.red;
    p.strokeWidth = 2;
    canvas.drawLine(Offset(x, y - 10), Offset(x + 4, y - 12), p);
    canvas.drawLine(Offset(x, y - 25), Offset(x + 4, y - 27), p);
  }

  @override
  bool shouldRepaint(covariant InvernoArtisticoPainter oldDelegate) =>
      oldDelegate.scrollOffset != scrollOffset || oldDelegate.snowProgress != snowProgress || oldDelegate.numeroMomenti != numeroMomenti;
}
