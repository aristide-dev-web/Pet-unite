import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../modello_memoria.dart';
import '../momenti_service.dart';
import 'package:easy_localization/easy_localization.dart';

class SeasonReviewPage extends StatefulWidget {
  final String animaleId;
  final String categoria; // Es: 'Primavera', 'Estate', 'Inverno', 'Autunno'

  const SeasonReviewPage({super.key, required this.animaleId, required this.categoria});

  @override
  State<SeasonReviewPage> createState() => _SeasonReviewPageState();
}

class _SeasonReviewPageState extends State<SeasonReviewPage> {
  final MomentiService _service = MomentiService();
  late Future<List<Memoria>> _memorieFuture;
  final PageController _pageController = PageController();
  double _scrollPosition = 0.0;

  @override
  void initState() {
    super.initState();
    _memorieFuture = _service.caricaMemorie(widget.animaleId, widget.categoria);
    _pageController.addListener(() {
      setState(() => _scrollPosition = _pageController.page ?? 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<List<Memoria>>(
        future: _memorieFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.pinkAccent));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final memorie = snapshot.data!;

          return Stack(
            children: [
              // SFONDO DINAMICO (Petali che cadono anche qui!)
              Positioned.fill(
                child: CustomPaint(
                  painter: ReviewBackgroundPainter(
                    scrollOffset: _scrollPosition * 400,
                    categoria: widget.categoria,
                  ),
                ),
              ),

              // CAROSELLO FOTO STILE STORIES
              PageView.builder(
                controller: _pageController,
                itemCount: memorie.length,
                itemBuilder: (context, index) {
                  return _buildStoryItem(memorie[index]);
                },
              ),

              // TASTO CHIUDI
              Positioned(
                top: 50,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStoryItem(Memoria memoria) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20)],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(File(memoria.pathImmagine), fit: BoxFit.cover),
            // Overlay sfumato per il testo
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    memoria.titolo,
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontFamily: 'Cursive', fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${memoria.data.day}/${memoria.data.month}/${memoria.data.year}",
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          Text('season_review_empty_msg'.tr(args: [widget.categoria]), style: const TextStyle(color: Colors.white, fontSize: 18)),
          TextButton(onPressed: () => Navigator.pop(context), child: Text('btn_back'.tr())),
        ],
      ),
    );
  }
}

// PAINTER SEMPLIFICATO PER LO SFONDO DELLA REVIEW
class ReviewBackgroundPainter extends CustomPainter {
  final double scrollOffset;
  final String categoria;
  ReviewBackgroundPainter({required this.scrollOffset, required this.categoria});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = categoria == 'Primavera' ? Colors.pink[100]!.withOpacity(0.3) : Colors.orange[100]!.withOpacity(0.2);

    // Pioggia di elementi (Petali o Foglie)
    for (int i = 0; i < 25; i++) {
      double xStart = (i * 100.0);
      double yPos = (scrollOffset * 0.5 + (i * 150)) % (size.height + 100) - 50;
      double xOsc = math.sin(scrollOffset * 0.01 + i) * 40;

      canvas.save();
      canvas.translate(xStart + xOsc, yPos);
      canvas.rotate(scrollOffset * 0.01 + i);
      canvas.drawOval(Rect.fromLTWH(0, 0, 12, 7), p);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}