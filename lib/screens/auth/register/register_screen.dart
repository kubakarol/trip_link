import 'package:flutter/material.dart';
import 'package:trip_link/services/auth_service.dart';
import 'package:trip_link/services/user_service.dart';
import 'package:intl/intl.dart';

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

  String? _gender; // "male"|"female"
  DateTime? _birthdate;
  bool _loading = false;
  String? _error;

  final _authService = AuthService();
  final _userService = UserService();

  Future<void> _pickBirthdate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) setState(() => _birthdate = picked);
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate() ||
        _gender == null ||
        _birthdate == null) {
      setState(
        () => _error = "Wypełnij wszystkie pola i wybierz datę oraz płeć",
      );
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final cred = await _authService.signUp(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      );

      await _userService.createProfile(
        uid: cred.user!.uid,
        name: _nameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        gender: _gender!,
        birthdate: _birthdate!,
      );

      // albo od razu do home jeśli nie masz więcej setup‑u
      Navigator.pushReplacementNamed(context, '/setup');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final birthLabel = _birthdate == null
        ? "Wybierz datę urodzenia"
        : DateFormat.yMMMMd().format(_birthdate!);

    return Scaffold(
      appBar: AppBar(title: const Text("Create account")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
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
                validator: (v) =>
                    v != null && v.contains('@') ? null : 'Niepoprawny email',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordCtrl,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
                validator: (v) =>
                    v != null && v.length >= 6 ? null : 'Min. 6 znaków',
              ),
              const SizedBox(height: 24),

              // płeć
              const Text("Płeć", style: TextStyle(fontWeight: FontWeight.bold)),
              RadioListTile<String>(
                title: const Text("Mężczyzna"),
                value: "male",
                groupValue: _gender,
                onChanged: (v) => setState(() => _gender = v),
              ),
              RadioListTile<String>(
                title: const Text("Kobieta"),
                value: "female",
                groupValue: _gender,
                onChanged: (v) => setState(() => _gender = v),
              ),
              RadioListTile<String>(
                title: const Text("Inna"),
                value: "other",
                groupValue: _gender,
                onChanged: (v) => setState(() => _gender = v),
              ),

              const SizedBox(height: 16),

              // data urodzenia
              ElevatedButton(
                onPressed: _pickBirthdate,
                child: Text(birthLabel),
              ),

              const SizedBox(height: 24),
              _loading
                  ? const Center(child: CircularProgressIndicator())
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
