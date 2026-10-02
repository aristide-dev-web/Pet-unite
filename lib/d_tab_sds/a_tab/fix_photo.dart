import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

class FixPhotoScreen extends StatefulWidget {
  final List<File> images;
  final bool isCustodia; // AGGIUNTO: per distinguere lo stile

  const FixPhotoScreen({
    super.key,
    required this.images,
    this.isCustodia = false, // Default a false per mantenere compatibilità
  });

  @override
  State<FixPhotoScreen> createState() => _FixPhotoScreenState();
}

class _FixPhotoScreenState extends State<FixPhotoScreen> {
  late List<File> _currentImages;
  int _currentIndex = 0;
  bool _isSaving = false;

  final GlobalKey _boundaryKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _currentImages = List.from(widget.images);
  }

  Future<File> _captureCurrentCrop() async {
    try {
      RenderRepaintBoundary? boundary = _boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return _currentImages[_currentIndex];

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      var byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      var pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/crop_${DateTime.now().microsecondsSinceEpoch}.png';
      final file = File(path);
      await file.writeAsBytes(pngBytes);
      return file;
    } catch (e) {
      return _currentImages[_currentIndex];
    }
  }

  Future<void> _saveAndExit() async {
    setState(() => _isSaving = true);
    File cropped = await _captureCurrentCrop();
    _currentImages[_currentIndex] = cropped;
    setState(() => _isSaving = false);
    Navigator.pop(context, _currentImages);
  }

  Future<void> _switchImage(int newIndex) async {
    if (_currentIndex == newIndex) return;
    setState(() => _isSaving = true);
    File cropped = await _captureCurrentCrop();
    setState(() {
      _currentImages[_currentIndex] = cropped;
      _currentIndex = newIndex;
      _isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color themeColor = widget.isCustodia ? const Color(0xFF2980B9) : const Color(0xFFE67E22);
    const Color vintageGold = Color(0xFFC5A059);
    const Color deepText = Color(0xFF2C3E50);
    
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth = screenWidth - 32;
    const double cardImageHeight = 280;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFF121212),
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context, _currentImages),
            ),
            title: const Column(
              children: [
                Text("ADATTA FOTO", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.2)),
                Text("Trascina per centrare l'animale", style: TextStyle(color: Colors.white38, fontSize: 10)),
              ],
            ),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: TextButton(
                  onPressed: _isSaving ? null : _saveAndExit,
                  child: Text("SALVA", style: TextStyle(color: themeColor, fontWeight: FontWeight.w900, fontSize: 14)),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: _currentImages.isEmpty
                    ? const Center(child: Text("Nessuna foto", style: TextStyle(color: Colors.white38)))
                    : Center(
                        child: Container(
                          width: cardWidth,
                          height: 440,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
                          child: Column(
                            children: [
                              RepaintBoundary(
                                key: _boundaryKey,
                                child: SizedBox(
                                  height: cardImageHeight,
                                  width: cardWidth,
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                                        child: InteractiveViewer(
                                          key: ValueKey(_currentImages[_currentIndex].path),
                                          minScale: 1.0,
                                          maxScale: 5.0,
                                          child: Image.file(
                                            _currentImages[_currentIndex],
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 15, right: 15,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(color: themeColor, borderRadius: BorderRadius.circular(10)),
                                          child: Text(
                                            widget.isCustodia ? "CUSTODIA" : "SOS",
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(widget.isCustodia ? "PET TROVATO" : "NOME PET", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: deepText, letterSpacing: -0.5)),
                                          const Spacer(),
                                          Icon(Icons.account_circle_rounded, color: deepText.withOpacity(0.1), size: 30),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text("Razza o Specie dell'animale", style: TextStyle(color: deepText.withOpacity(0.5), fontSize: 13, fontWeight: FontWeight.w600)),
                                      const Spacer(),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text("Oggi, 00:00", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500)),
                                          Text("VEDI DETTAGLI", style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, fontSize: 11)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
              Container(
                height: 140,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: const BorderRadius.vertical(top: Radius.circular(30))),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _currentImages.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _switchImage(index),
                      child: Container(
                        width: 80,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: _currentIndex == index ? themeColor : Colors.white24, width: 2.5),
                          image: DecorationImage(image: FileImage(_currentImages[index]), fit: BoxFit.cover),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        if (_isSaving) Container(color: Colors.black54, child: const Center(child: CircularProgressIndicator(color: Colors.white))),
      ],
    );
  }
}
