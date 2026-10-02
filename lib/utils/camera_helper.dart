import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CameraHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Scatta una foto con la fotocamera e restituisce un File
  static Future<File?> takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      return File(photo.path);
    }
    return null;
  }
}