import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:easy_localization/easy_localization.dart';

class PhotoEditorPage extends StatefulWidget {
  final File imageFile;

  const PhotoEditorPage({super.key, required this.imageFile});

  @override
  State<PhotoEditorPage> createState() => _PhotoEditorPageState();
}

class _PhotoEditorPageState extends State<PhotoEditorPage> {
  final TransformationController _controller = TransformationController();
  final GlobalKey _cropKey = GlobalKey();

  double _rotation = 0.0;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _imageBytes = widget.imageFile.readAsBytesSync();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double cropSize = size.width * 0.75;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text("zoom_title".tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          TextButton(
            onPressed: _confirmImage,
            child: Text("btn_confirm_action".tr(), style: const TextStyle(color: Color(0xFF00FBFF), fontWeight: FontWeight.bold, fontSize: 16)),
          )
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black, Color(0xFF1A1A1A)])),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                RepaintBoundary(
                  key: _cropKey,
                  child: Container(
                    width: cropSize, height: cropSize,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black),
                    clipBehavior: Clip.antiAlias,
                    child: InteractiveViewer(
                      transformationController: _controller,
                      minScale: 1.0, maxScale: 5.0,
                      boundaryMargin: EdgeInsets.all(cropSize),
                      constrained: true,
                      child: Transform.rotate(
                        angle: _rotation,
                        child: SizedBox(width: cropSize, height: cropSize, child: Image.memory(_imageBytes!, fit: BoxFit.cover)),
                      ),
                    ),
                  ),
                ),
                IgnorePointer(child: Container(width: size.width, height: size.width, decoration: BoxDecoration(shape: BoxShape.rectangle, border: Border.all(color: Colors.black.withOpacity(0.8), width: (size.width - cropSize) / 2)))),
                IgnorePointer(child: Container(width: cropSize, height: cropSize, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.4), width: 3)))),
              ],
            ),
            const SizedBox(height: 50),
            Text("zoom_instruction".tr(), style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.5)),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _actionBtn(Icons.rotate_left_rounded, () => setState(() => _rotation -= 1.5708)),
                const SizedBox(width: 40),
                _actionBtn(Icons.rotate_right_rounded, () => setState(() => _rotation += 1.5708)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(height: 60, width: 60, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.1), border: Border.all(color: Colors.white24, width: 1.5)), child: Icon(icon, color: Colors.white, size: 28)),
    );
  }

  Future<void> _confirmImage() async {
    try {
      final boundary = _cropKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      
      // 1. Cattura l'immagine a risoluzione standard (1.0) per non pesare MB
      final ui.Image image = await boundary.toImage(pixelRatio: 1.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      
      if (byteData == null) return;

      // 2. Converti in immagine elaborabile
      final img.Image? baseImg = img.Image.fromBytes(
        width: image.width,
        height: image.height,
        bytes: byteData.buffer,
        order: img.ChannelOrder.rgba,
      );

      if (baseImg == null) return;

      // 3. 🔥 CONVERSIONE IN JPEG CON COMPRESSIONE 80% (Taglia il 95% del peso!)
      final Uint8List jpgBytes = Uint8List.fromList(img.encodeJpg(baseImg, quality: 80));

      // 4. Salva il file ottimizzato
      final tempDir = await getTemporaryDirectory();
      final File optimizedFile = File('${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await optimizedFile.writeAsBytes(jpgBytes);

      if (!mounted) return;
      Navigator.pop(context, optimizedFile);
      
      debugPrint("✅ Foto Ottimizzata: ${jpgBytes.length / 1024} KB");
    } catch (e) {
      debugPrint("🚨 Errore ottimizzazione: $e");
    }
  }
}
