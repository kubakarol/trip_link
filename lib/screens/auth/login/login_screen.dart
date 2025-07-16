// lib/screens/auth/login/login_screen.dart

import 'package:flutter/material.dart';
import 'package:trip_link/services/auth_service.dart';
import 'package:trip_link/services/user_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  final _authService = AuthService();
  final _userService = UserService();

  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // 1) zaloguj — nie potrzebujemy `cred` jeśli nie używasz jego pola
      await _authService.signIn(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      );

      // 2) sprawdź, czy profil istnieje
      final doc = await _userService.fetchProfile();
      if (!doc.exists) {
        setState(
          () => _error = "Brak danych profilu. Skontaktuj się z supportem.",
        );
        await _authService.signOut();
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on Exception catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign In")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (v) => v == null || !v.contains('@')
                    ? 'Wprowadź poprawny e‑mail'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordCtrl,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
                validator: (v) =>
                    v == null || v.length < 6 ? 'Hasło min. 6 znaków' : null,
              ),
              const SizedBox(height: 24),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      child: const Text("Sign In"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
