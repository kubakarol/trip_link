import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Zaloguj użytkownika e‑mailem i hasłem
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Zarejestruj użytkownika
  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Wyloguj
  Future<void> signOut() {
    return _auth.signOut();
  }

  /// Aktualnie zalogowany użytkownik (może być null)
  User? get currentUser => _auth.currentUser;
}
