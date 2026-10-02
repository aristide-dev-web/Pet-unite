import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'momenti_service.dart';
import 'modello_memoria.dart';

class CollezioneCompletaPage extends StatefulWidget {
  final String animaleId;
  const CollezioneCompletaPage({super.key, required this.animaleId});

  @override
  State<CollezioneCompletaPage> createState() => _CollezioneCompletaPageState();
}

class _CollezioneCompletaPageState extends State<CollezioneCompletaPage> with SingleTickerProviderStateMixin {
  final MomentiService _service = MomentiService();
  Map<String, List<Memoria>> categorieMappa = {};
  bool isLoading = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    );
    _caricaTutto();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _caricaTutto() async {
    final categorie = ['Primavera', 'Spiaggia', 'Autunno', 'Inverno'];
    Map<String, List<Memoria>> tempMappa = {};
    
    for (var cat in categorie) {
      final lista = await _service.caricaMemorie(widget.animaleId, cat);
      if (lista.isNotEmpty) {
        tempMappa[cat] = lista;
      }
    }

    if (mounted) {
      setState(() {
        categorieMappa = tempMappa;
        isLoading = false;
      });
      if (categorieMappa.isNotEmpty) {
        _animationController.repeat();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFCFB), 
      appBar: AppBar(
        title: const Text("Album dei Ricordi", 
          style: TextStyle(fontFamily: 'Cursive', fontSize: 28, color: Color(0xFF5D4037), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF5D4037)),
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.brown))
        : categorieMappa.isEmpty 
          ? _buildEmptyState()
          : AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return ListView(
                  padding: EdgeInsets.zero,
                  children: categorieMappa.entries.map((entry) => _buildSezione(entry.key, entry.value)).toList(),
                );
              }
            ),
    );
  }

  Widget _buildSezione(String categoria, List<Memoria> memorie) {
    String titoloMostrato;
    IconData iconaSezione;
    Color coloreTema;
    Color coloreSfondo;

    switch (categoria) {
      case 'Primavera':
        titoloMostrato = 'Primavera';
        iconaSezione = Icons.local_florist;
        coloreTema = const Color(0xFFF06292);
        coloreSfondo = const Color(0xFFFFE4E8); 
        break;
      case 'Spiaggia':
        titoloMostrato = 'Estate';
        iconaSezione = Icons.wb_sunny;
        coloreTema = Colors.orange[700]!;
        coloreSfondo = const Color(0xFFE0F7FA); 
        break;
      case 'Autunno':
        titoloMostrato = 'Autunno';
        iconaSezione = Icons.eco;
        coloreTema = Colors.brown[700]!;
        coloreSfondo = const Color(0xFFFFF3E0); 
        break;
      case 'Inverno':
        titoloMostrato = 'Inverno';
        iconaSezione = Icons.ac_unit;
        coloreTema = Colors.blue[700]!;
        coloreSfondo = const Color(0xFFE1F5FE); 
        break;
      default:
        titoloMostrato = categoria;
        iconaSezione = Icons.collections_bookmark;
        coloreTema = Colors.brown;
        coloreSfondo = Colors.white;
    }
    
    return Column(
      children: [
        Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: coloreSfondo,
                child: CustomPaint(
                  painter: SezioneBackgroundPainter(
                    categoria: categoria,
                    progress: _animationController.value,
                    colore: coloreTema,
                  ),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(iconaSezione, color: coloreTema, size: 24),
                      const SizedBox(width: 12),
                      Text(titoloMostrato, 
                        style: TextStyle(fontFamily: 'Cursive', fontSize: 26, fontWeight: FontWeight.bold, color: coloreTema)),
                      const Spacer(),
                      Text("${memorie.length} foto", 
                        style: TextStyle(color: coloreTema.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 160,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: memorie.length,
                      itemBuilder: (context, index) {
                        return _buildPhotoCard(memorie[index], coloreTema);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const Divider(height: 1, color: Colors.black, thickness: 1.5), 
      ],
    );
  }

  Widget _buildPhotoCard(Memoria memoria, Color colore) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 15, bottom: 5, top: 5),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 5, offset: const Offset(2, 3))
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(1),
              child: Image.file(File(memoria.pathImmagine), fit: BoxFit.cover, width: double.infinity),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 3,
            width: 30,
            decoration: BoxDecoration(
              color: colore.withOpacity(0.2),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_library_outlined, size: 80, color: Colors.brown[100]),
          const SizedBox(height: 20),
          const Text("L'album è ancora vuoto...", 
            style: TextStyle(fontFamily: 'Cursive', fontSize: 20, color: Colors.grey)),
        ],
      ),
    );
  }
}

class SezioneBackgroundPainter extends CustomPainter {
  final String categoria;
  final double progress;
  final Color colore;

  SezioneBackgroundPainter({required this.categoria, required this.progress, required this.colore});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(categoria.hashCode);
    final paint = Paint()..style = PaintingStyle.fill;

    if (categoria == 'Primavera') {
      // Arcobaleno soffuso
      final rainbowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round;

      final colors = [
        Colors.red.withOpacity(0.1),
        Colors.orange.withOpacity(0.1),
        Colors.yellow.withOpacity(0.1),
        Colors.green.withOpacity(0.1),
        Colors.blue.withOpacity(0.1),
      ];

      for (int i = 0; i < colors.length; i++) {
        rainbowPaint.color = colors[i];
        canvas.drawArc(
          Rect.fromLTWH(-50, 10 + (i * 3), 150, 100),
          math.pi,
          math.pi / 2,
          false,
          rainbowPaint,
        );
      }

      // Alberello di ciliegio in basso a destra
      double treeX = size.width - 45;
      double treeY = size.height - 15;
      
      // Tronco
      paint.color = const Color(0xFF795548).withOpacity(0.6);
      Path trunk = Path();
      trunk.moveTo(treeX - 5, treeY);
      trunk.lineTo(treeX - 2, treeY - 40);
      trunk.quadraticBezierTo(treeX, treeY - 50, treeX + 6, treeY - 55);
      trunk.lineTo(treeX + 9, treeY - 53);
      trunk.quadraticBezierTo(treeX + 4, treeY - 48, treeX + 2, treeY - 40);
      trunk.lineTo(treeX + 6, treeY);
      trunk.close();
      canvas.drawPath(trunk, paint);

      // Chioma (Fiori di ciliegio)
      paint.color = Colors.pink[100]!.withOpacity(0.75);
      canvas.drawCircle(Offset(treeX + 2, treeY - 60), 18, paint);
      canvas.drawCircle(Offset(treeX - 10, treeY - 50), 14, paint);
      canvas.drawCircle(Offset(treeX + 14, treeY - 48), 15, paint);
      canvas.drawCircle(Offset(treeX + 3, treeY - 42), 12, paint);
      
      // Qualche fiorellino più scuro nell'albero
      paint.color = Colors.pink[200]!.withOpacity(0.6);
      canvas.drawCircle(Offset(treeX + 6, treeY - 58), 5, paint);
      canvas.drawCircle(Offset(treeX - 4, treeY - 50), 4, paint);
      canvas.drawCircle(Offset(treeX + 10, treeY - 45), 4.5, paint);

      // Uccellini che volano
      final birdPaint = Paint()
        ..color = Colors.brown[400]!.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3
        ..strokeCap = StrokeCap.round;

      for (int i = 0; i < 2; i++) {
        double birdX = (size.width * (0.2 + i * 0.15) + (progress * 130)) % (size.width + 100) - 50;
        double birdY = 28.0 + math.sin(progress * math.pi * 5 + i) * 8;
        double wingSpread = 6.5 + math.sin(progress * math.pi * 12) * 3.5;
        
        Path birdPath = Path();
        birdPath.moveTo(birdX - wingSpread, birdY - 2);
        birdPath.quadraticBezierTo(birdX - wingSpread/2, birdY + 2, birdX, birdY);
        birdPath.quadraticBezierTo(birdX + wingSpread/2, birdY + 2, birdX + wingSpread, birdY - 2);
        canvas.drawPath(birdPath, birdPaint);
      }

      // Farfalle che svolazzano
      final butterflyPaint = Paint()..style = PaintingStyle.fill;
      for (int i = 0; i < 3; i++) {
        double x = (size.width * (0.2 + i * 0.3) + math.sin(progress * math.pi * 4 + i) * 30) % size.width;
        double y = 40.0 + math.cos(progress * math.pi * 2 + i) * 15;
        butterflyPaint.color = [Colors.blue[200]!, Colors.purple[100]!, Colors.yellow[200]!][i].withOpacity(0.4);

        double wingSwing = math.sin(progress * math.pi * 15) * 4;
        canvas.drawOval(Rect.fromCenter(center: Offset(x - 3, y), width: 6 + wingSwing, height: 8), butterflyPaint);
        canvas.drawOval(Rect.fromCenter(center: Offset(x + 3, y), width: 6 + wingSwing, height: 8), butterflyPaint);
      }

      // Petali rosa cadenti
      paint.color = Colors.pink[100]!.withOpacity(0.5);
      for (int i = 0; i < 12; i++) {
        double x = (random.nextDouble() * size.width + (progress * 40)) % size.width;
        double y = (random.nextDouble() * size.height + (progress * size.height)) % (size.height + 20) - 10;
        canvas.drawOval(Rect.fromLTWH(x, y, 10, 6), paint);
      }
    } else if (categoria == 'Spiaggia') {
      // Spuma del mare
      final spumaPaint = Paint()..color = Colors.white.withOpacity(0.35);
      for (int i = 0; i < 50; i++) {
        double x = (random.nextDouble() * size.width + (progress * 45)) % size.width;
        double y = size.height * 0.15 + (random.nextDouble() * size.height * 0.85);
        double radius = 1.2 + random.nextDouble() * 5.5;
        canvas.drawCircle(Offset(x, y), radius, spumaPaint);
      }

      // Sole Sorridente
      double soleX = size.width * 0.5;
      double soleY = 45;
      final solePaint = Paint()..color = Colors.yellow[400]!.withOpacity(0.5);
      canvas.drawCircle(Offset(soleX, soleY), 15, solePaint);
      
      final facePaint = Paint()
        ..color = Colors.orange[700]!.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4;

      canvas.drawCircle(Offset(soleX - 4, soleY - 3), 1.2, facePaint..style = PaintingStyle.fill);
      canvas.drawCircle(Offset(soleX + 4, soleY - 3), 1.2, facePaint..style = PaintingStyle.fill);

      facePaint.style = PaintingStyle.stroke;
      canvas.drawArc(Rect.fromCenter(center: Offset(soleX, soleY + 2), width: 10, height: 8), 0.2, math.pi - 0.4, false, facePaint);

      final raggiPaint = Paint()..color = Colors.orange[300]!.withOpacity(0.4)..strokeWidth = 1.2;
      for (int j = 0; j < 8; j++) {
        double angle = j * (math.pi * 2) / 8 + (progress * 0.3);
        canvas.drawLine(Offset(soleX + math.cos(angle) * 19, soleY + math.sin(angle) * 19), Offset(soleX + math.cos(angle) * 26, soleY + math.sin(angle) * 26), raggiPaint);
      }

      // Rondini
      final birdPaint = Paint()..color = const Color(0xFF424242).withOpacity(0.3)..style = PaintingStyle.stroke..strokeWidth = 1.2..strokeCap = StrokeCap.round;
      for (int i = 0; i < 3; i++) {
        double birdX = (size.width * (0.1 + i * 0.4) + (progress * 180)) % (size.width + 100) - 50;
        double birdY = 30.0 + math.sin(progress * math.pi * 4 + i) * 8;
        double wingSpread = 7.0 + math.sin(progress * math.pi * 10) * 4;
        Path swallow = Path();
        swallow.moveTo(birdX - wingSpread, birdY - 2);
        swallow.quadraticBezierTo(birdX - wingSpread/2, birdY + 2, birdX, birdY);
        swallow.quadraticBezierTo(birdX + wingSpread/2, birdY + 2, birdX + wingSpread, birdY - 2);
        canvas.drawPath(swallow, birdPaint);
      }

      // Onde
      paint.color = Colors.white.withOpacity(0.4);
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 2.0;
      for (int i = 0; i < 2; i++) {
        double y = size.height * 0.4 + (i * 40);
        Path wave = Path();
        wave.moveTo(-20, y);
        for (double x = -20; x < size.width + 20; x += 50) {
          wave.quadraticBezierTo(x + 25, y + math.sin(progress * math.pi * 2 + i) * 12, x + 50, y);
        }
        canvas.drawPath(wave, paint);
      }
    } else if (categoria == 'Autunno') {
      // Molte più foglie, anche verso il centro
      final colors = [Colors.orange[300]!, Colors.brown[300]!, Colors.deepOrange[200]!];
      for (int i = 0; i < 40; i++) {
        paint.color = colors[random.nextInt(colors.length)].withOpacity(0.5);
        double x = (random.nextDouble() * size.width - (progress * 25)) % size.width;
        double y = (random.nextDouble() * size.height + (progress * size.height)) % (size.height + 20) - 10;
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(progress * math.pi + i);
        Path leaf = Path();
        leaf.moveTo(0, 0);
        leaf.quadraticBezierTo(5, -3, 12, 0);
        leaf.quadraticBezierTo(5, 3, 0, 0);
        canvas.drawPath(leaf, paint..style = PaintingStyle.fill);
        canvas.restore();
      }
    } else if (categoria == 'Inverno') {
      // Neve cadente
      paint.color = Colors.white.withOpacity(0.7);
      paint.style = PaintingStyle.fill;
      for (int i = 0; i < 20; i++) {
        double x = (random.nextDouble() * size.width + math.sin(progress * math.pi * 2 + i) * 12) % size.width;
        double y = (random.nextDouble() * size.height + (progress * size.height)) % (size.height + 15);
        canvas.drawCircle(Offset(x, y), random.nextDouble() * 2.5 + 1, paint);
      }

      // Pupazzo di neve (Snowman)
      double smX = size.width * 0.85;
      double smY = size.height * 0.72;

      // Ombra soffusa alla base
      paint.color = Colors.black.withOpacity(0.05);
      canvas.drawOval(Rect.fromCenter(center: Offset(smX, smY + 15), width: 35, height: 8), paint);

      // Corpo (due palle di neve)
      paint.color = Colors.white.withOpacity(0.95);
      canvas.drawCircle(Offset(smX, smY + 5), 16, paint); // Base
      canvas.drawCircle(Offset(smX, smY - 15), 12, paint); // Testa

      // Occhietti neri
      paint.color = Colors.black87;
      canvas.drawCircle(Offset(smX - 4, smY - 18), 1.5, paint);
      canvas.drawCircle(Offset(smX + 4, smY - 18), 1.5, paint);

      // Nasino a carota
      paint.color = Colors.orange[700]!;
      Path carota = Path();
      carota.moveTo(smX, smY - 16);
      carota.lineTo(smX + 8, smY - 14);
      carota.lineTo(smX, smY - 13);
      carota.close();
      canvas.drawPath(carota, paint);

      // Sciarpa Rossa
      paint.color = Colors.red[700]!;
      paint.style = PaintingStyle.fill;
      canvas.drawRRect(RRect.fromLTRBR(smX - 9, smY - 6, smX + 9, smY - 1, const Radius.circular(3)), paint);
      Path lembo = Path();
      lembo.moveTo(smX + 3, smY - 2);
      lembo.lineTo(smX + 9, smY + 10);
      lembo.lineTo(smX + 4, smY + 11);
      lembo.close();
      canvas.drawPath(lembo, paint);

      // Bottoni sul corpo
      paint.color = Colors.black54;
      canvas.drawCircle(Offset(smX, smY + 4), 1.5, paint);
      canvas.drawCircle(Offset(smX, smY + 10), 1.5, paint);

      // Braccine di legno e Guanti
      paint.color = Colors.brown[400]!;
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 1.5;
      
      double braccioMove = math.sin(progress * math.pi * 4) * 2;
      
      // Braccio e guanto sinistro
      canvas.drawLine(Offset(smX - 10, smY - 5), Offset(smX - 25, smY - 12 + braccioMove), paint);
      paint.style = PaintingStyle.fill;
      paint.color = Colors.red[400]!;
      canvas.drawCircle(Offset(smX - 25, smY - 12 + braccioMove), 3.5, paint);

      // Braccio e guanto destro
      paint.color = Colors.brown[400]!;
      paint.style = PaintingStyle.stroke;
      canvas.drawLine(Offset(smX + 10, smY - 5), Offset(smX + 25, smY - 12 - braccioMove), paint);
      paint.style = PaintingStyle.fill;
      paint.color = Colors.red[400]!;
      canvas.drawCircle(Offset(smX + 25, smY - 12 - braccioMove), 3.5, paint);

      // Cappellino di Natale
      paint.color = Colors.red[600]!;
      Path cappello = Path();
      cappello.moveTo(smX - 11, smY - 24);
      cappello.lineTo(smX + 11, smY - 24);
      cappello.lineTo(smX + 4, smY - 42); 
      cappello.close();
      canvas.drawPath(cappello, paint);

      // Bordo del cappello e pom-pom
      paint.color = Colors.white;
      canvas.drawRRect(RRect.fromLTRBR(smX - 12, smY - 27, smX + 12, smY - 22, const Radius.circular(2)), paint);
      canvas.drawCircle(Offset(smX + 4, smY - 42), 4, paint);
    }
  }

  @override
  bool shouldRepaint(covariant SezioneBackgroundPainter oldDelegate) => true;
}
