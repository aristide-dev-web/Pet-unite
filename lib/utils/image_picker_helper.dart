import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Apre la galleria e restituisce un File dell'immagine selezionata
  static Future<File?> pickImageFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  /// Apre la galleria per selezionare più immagini contemporaneamente
  static Future<List<File>> pickMultiImagesFromGallery() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage(
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    return pickedFiles.map((xfile) => File(xfile.path)).toList();
  }

  /// Apre la fotocamera e restituisce un File dell'immagine scattata
  /// Limitiamo risoluzione e qualità per non far crashare l'AI sui telefoni datati
  static Future<File?> pickImageFromCamera() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 75,
    );
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }
}
