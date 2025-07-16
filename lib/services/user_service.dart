import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Pobierz dokument profilu zalogowanego użytkownika
  Future<DocumentSnapshot<Map<String, dynamic>>> fetchProfile() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return _firestore.collection('users').doc(uid).get();
  }

  /// Utwórz podstawowy profil po rejestracji
  Future<void> createProfile({
    required String uid,
    required String name,
    required String lastName,
    required String email,
  }) {
    return _firestore.collection('users').doc(uid).set({
      'name': name,
      'lastName': lastName,
      'email': email,
      'createdAt': Timestamp.now(),
    });
  }

  /// Zaktualizuj dowolne pola profilu
  Future<void> updateProfile(Map<String, dynamic> data) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return _firestore.collection('users').doc(uid).update(data);
  }
}
