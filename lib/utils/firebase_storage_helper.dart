import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class FirebaseStorageHelper {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final Uuid _uuid = Uuid();

  /// UPLOAD ORIGINALE RIPRISTINATO - PARAMETRI POSIZIONALI
  static Future<String?> uploadImage(File imageFile, String folderName) async {
    try {
      final String fileName = '${_uuid.v4()}.jpg';
      final Reference ref = _storage.ref().child('$folderName/$fileName');
      
      final UploadTask uploadTask = ref.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Errore Upload in $folderName: $e');
      return null;
    }
  }

  static Future<String?> uploadAnimalProfileImage(File imageFile, String animalId) async {
    return await uploadImage(imageFile, 'foto_animali');
  }

  static Future<String?> uploadSocialImage(File imageFile) async {
    return await uploadImage(imageFile, 'social_posts');
  }
}
