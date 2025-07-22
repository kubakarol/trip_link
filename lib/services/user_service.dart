// lib/services/user_service.dart

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
    required String gender,
    required DateTime birthdate,
  }) {
    return _firestore.collection('users').doc(uid).set({
      'name': name,
      'lastName': lastName,
      'email': email,
      'gender': gender,
      'birthdate': Timestamp.fromDate(birthdate),
      'createdAt': FieldValue.serverTimestamp(),

      // wartości domyślne dla nowych flag:
      'isGuide': false,
      'isTraveler': false,

      // domyślne preferencje swipe’owania:
      'preferences': {
        'language': 'en',
        'minAge': 18,
        'maxAge': 99,
        'showGuides': true,
        'showTravelers': true,
        // ewentualnie: 'preferredGender': 'any'
      },
    });
  }

  /// Zaktualizuj dowolne pola profilu
  Future<void> updateProfile(Map<String, dynamic> data) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return _firestore.collection('users').doc(uid).update(data);
  }
}
