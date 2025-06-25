import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  static Future<String> uploadImage(Uint8List imageBytes, String fileName) async {
    final storageRef = FirebaseStorage.instance.ref().child('clothes/$fileName');
    final uploadTask = storageRef.putData(imageBytes);
    await uploadTask.whenComplete(() {});
    final downloadUrl = await storageRef.getDownloadURL();
    return downloadUrl;
  }
}
