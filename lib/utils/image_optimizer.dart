import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class ImageOptimizer {
  /// Ottimizza un'immagine riducendone il peso usando il pacchetto 'image'.
  /// Ridimensiona se necessario e comprime in formato JPEG.
  static Future<File> optimize({
    required File file,
    int quality = 70,
    int maxWidth = 1024,
  }) async {
    try {
      final Uint8List bytes = await file.readAsBytes();
      
      // Decodifica l'immagine usando il pacchetto 'image'
      img.Image? image = img.decodeImage(bytes);
      if (image == null) return file;

      // 1. Ridimensiona se troppo grande (mantenendo le proporzioni)
      if (image.width > maxWidth) {
        image = img.copyResize(image, width: maxWidth);
      }

      // 2. Comprime in formato JPG (molto leggero)
      final Uint8List compressedBytes = Uint8List.fromList(
        img.encodeJpg(image, quality: quality),
      );

      // 3. Salva in una directory temporanea
      final tempDir = await getTemporaryDirectory();
      final String fileName = 'opt_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File optimizedFile = File('${tempDir.path}/$fileName');

      await optimizedFile.writeAsBytes(compressedBytes);
      
      if (kDebugMode) {
        print('ImageOptimizer: Original ${file.lengthSync() / 1024} KB');
        print('ImageOptimizer: Optimized ${optimizedFile.lengthSync() / 1024} KB');
      }

      return optimizedFile;
    } catch (e) {
      if (kDebugMode) print('Error optimizing image: $e');
      return file;
    }
  }
}
