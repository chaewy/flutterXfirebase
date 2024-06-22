import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads an image file to Firebase Storage.
  ///
  /// Returns the download URL of the uploaded image.
  Future<String> uploadImage(File imageFile, String folderName) async {
    try {
      // Create a reference to the location you want to upload to in Firebase Storage
      Reference ref = _storage.ref().child('$folderName/${path.basename(imageFile.path)}');

      // Upload the file to Firebase Storage
      await ref.putFile(imageFile);

      // Return the download URL of the uploaded image
      String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image to Firebase Storage: $e');
      throw Exception('Failed to upload image.');
    }
  }
}
