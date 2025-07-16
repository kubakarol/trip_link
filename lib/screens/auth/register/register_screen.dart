import 'package:flutter/material.dart';
import 'package:trip_link/services/auth_service.dart';
import 'package:trip_link/services/user_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  final _authService = AuthService();
  final _userService = UserService();

  bool _loading = false;
  String? _error;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // rejestracja w Firebase Auth
      final cred = await _authService.signUp(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      );

      // utworzenie dokumentu profilu w Firestore
      await _userService.createProfile(
        uid: cred.user!.uid,
        name: _nameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
      );

      // przejście do setupu
      Navigator.pushReplacementNamed(context, '/setup');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create account"),
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
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
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: "Name"),
                validator: (v) => v == null || v.isEmpty ? 'Wymagane' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lastNameCtrl,
                decoration: const InputDecoration(labelText: "Last name"),
                validator: (v) => v == null || v.isEmpty ? 'Wymagane' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (v) => v == null || !v.contains('@')
                    ? 'Wprowadź prawidłowy e‑mail'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordCtrl,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
                validator: (v) =>
                    v != null && v.length >= 6 ? null : 'Min 6 znaków',
              ),
              const SizedBox(height: 24),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _register,
                      child: const Text("Sign up"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
