import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Wrzuca plik avataru i zwraca URL
  Future<String> uploadAvatar(File file) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final ref = _storage.ref().child('user_photos/$uid.jpg');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }
}
