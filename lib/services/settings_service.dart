import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsService {
  final _firestore = FirebaseFirestore.instance;
  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  /// Pobiera mapę preferences z dokumentu users/{uid}
  Future<Map<String, dynamic>> fetchPreferences() async {
    final doc = await _firestore.collection('users').doc(_uid).get();
    final data = doc.data() ?? {};
    return (data['preferences'] as Map<String, dynamic>?) ??
        {
          'language': 'en',
          'minAge': 18,
          'maxAge': 99,
          'showGuides': true,
          'showTravelers': true,
        };
  }

  /// Zapisuje całą mapę preferences
  Future<void> updatePreferences(Map<String, dynamic> prefs) {
    return _firestore.collection('users').doc(_uid).update({
      'preferences': prefs,
    });
  }
}
