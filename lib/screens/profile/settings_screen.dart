// lib/screens/profile/settings_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:trip_link/services/storage_service.dart';
import 'package:trip_link/services/user_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _userService = UserService();
  final _storageService = StorageService();
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _travelGoalCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();

  bool _isGuide = false;
  bool _isTraveler = false; // nowa flaga
  bool _loading = true;
  File? _newImage;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    final doc = await _userService.fetchProfile();
    final data = doc.data()!;

    _nameCtrl.text = data['name'] ?? '';
    _lastNameCtrl.text = data['lastName'] ?? '';
    _locationCtrl.text = data['location'] ?? '';
    _travelGoalCtrl.text = data['travelGoal'] ?? '';
    _bioCtrl.text = data['bio'] ?? '';
    _isGuide = data['isGuide'] ?? false;
    _isTraveler = data['isTraveler'] ?? false;
    _photoUrl = data['photoUrl'];

    setState(() => _loading = false);
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _newImage = File(picked.path));
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    // kolejność: upload avatar jeśli nowy
    String? url = _photoUrl;
    if (_newImage != null) {
      url = await _storageService.uploadAvatar(_newImage!);
    }

    // aktualizujemy wszystkie pola w profilu
    await _userService.updateProfile({
      'name': _nameCtrl.text.trim(),
      'lastName': _lastNameCtrl.text.trim(),
      'location': _locationCtrl.text.trim(),
      'travelGoal': _travelGoalCtrl.text.trim(),
      'bio': _bioCtrl.text.trim(),
      'isGuide': _isGuide,
      'isTraveler': _isTraveler, // zapisujemy nową flagę
      'photoUrl': url,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    setState(() {
      _photoUrl = url;
      _loading = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Profile updated")));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // avatar + picker
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _newImage != null
                      ? FileImage(_newImage!)
                      : (_photoUrl != null
                            ? NetworkImage(_photoUrl!) as ImageProvider
                            : null),
                  child: _photoUrl == null && _newImage == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
              ),

              const SizedBox(height: 20),

              // dane tekstowe
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              TextFormField(
                controller: _lastNameCtrl,
                decoration: const InputDecoration(labelText: "Last Name"),
              ),
              TextFormField(
                controller: _locationCtrl,
                decoration: const InputDecoration(labelText: "Location"),
              ),
              TextFormField(
                controller: _travelGoalCtrl,
                decoration: const InputDecoration(labelText: "Travel Goal"),
              ),
              TextFormField(
                controller: _bioCtrl,
                decoration: const InputDecoration(labelText: "Bio"),
                maxLines: 3,
              ),

              const SizedBox(height: 16),

              // nowe przełączniki
              SwitchListTile(
                value: _isGuide,
                onChanged: (v) => setState(() => _isGuide = v),
                title: const Text("I'm a guide here"),
                subtitle: const Text(
                  "Chcę oprowadzać podróżników w moim mieście",
                ),
              ),
              SwitchListTile(
                value: _isTraveler,
                onChanged: (v) => setState(() => _isTraveler = v),
                title: const Text("I'm a traveler"),
                subtitle: const Text(
                  "Szukam przewodnika w miejscu, do którego jadę",
                ),
              ),

              const SizedBox(height: 24),

              // przycisk save
              ElevatedButton(
                onPressed: _saveChanges,
                child: const Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
