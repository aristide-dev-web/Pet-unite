import 'dart:io';
import 'package:flutter/material.dart';

class FotoPreviewWidget extends StatelessWidget {
  final List<File?> files;
  final List<String> existingUrls;
  final Function(int) onRemoveFile;
  final Function(int) onRemoveExisting;
  final VoidCallback onAdd;
  final String title;

  const FotoPreviewWidget({
    super.key,
    required this.files,
    required this.existingUrls,
    required this.onRemoveFile,
    required this.onRemoveExisting,
    required this.onAdd,
    this.title = "AGGIUNGI FOTO",
  });

  void _showFullScreenImage(BuildContext context, ImageProvider image) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (context) => GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.5,
                  maxScale: 4,
                  child: Image(image: image, fit: BoxFit.contain, width: double.infinity, height: double.infinity),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 50, right: 20),
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 35),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color indigoColor = const Color(0xFF6366F1);
    
    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: existingUrls.length + files.length + 1,
        itemBuilder: (context, index) {
          // Tasto Aggiungi
          if (index == existingUrls.length + files.length) {
            return GestureDetector(
              onTap: onAdd,
              child: Container(
                width: 100,
                margin: const EdgeInsets.only(right: 12, bottom: 10, top: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: indigoColor.withOpacity(0.3), width: 3, style: BorderStyle.solid),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo_rounded, color: indigoColor, size: 30),
                    const SizedBox(height: 6),
                    Text("AGGIUNGI", style: TextStyle(color: indigoColor, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5)),
                  ],
                ),
              ),
            );
          }

          bool isExisting = index < existingUrls.length;
          final ImageProvider imageProvider = isExisting 
            ? NetworkImage(existingUrls[index])
            : FileImage(files[index - existingUrls.length]!) as ImageProvider;

          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 12, bottom: 10, top: 10),
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () => _showFullScreenImage(context, imageProvider),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 6))],
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Image(
                        image: imageProvider,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: -2,
                  right: -2,
                  child: GestureDetector(
                    onTap: () => isExisting ? onRemoveExisting(index) : onRemoveFile(index - existingUrls.length),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.redAccent, 
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                      ),
                      child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
                    ),
                  ),
                ),
                // Icona Zoom Overlay (Suggerimento visivo)
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), shape: BoxShape.circle),
                    child: const Icon(Icons.zoom_in_rounded, color: Colors.white, size: 14),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
