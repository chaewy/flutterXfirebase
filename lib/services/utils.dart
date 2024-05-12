


import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class UtilsService{
  Future<String> uploadFile(File _image, String path) async {
    firebase_storage.Reference storageReference = 
        firebase_storage.FirebaseStorage.instance.ref(path);
      
    firebase_storage.UploadTask uploadTask = storageReference.putFile(_image);

    await uploadTask;
    
    // Once upload is complete, get the download URL
    String downloadURL = await storageReference.getDownloadURL();

    return downloadURL;
  }
}
