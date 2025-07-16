import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _travelGoalCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();

  bool _isGuide = false;
  bool _loading = true;
  String? _photoUrl;
  File? _newImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    final data = doc.data()!;

    setState(() {
      _nameCtrl.text = data['name'] ?? '';
      _lastNameCtrl.text = data['lastName'] ?? '';
      _locationCtrl.text = data['location'] ?? '';
      _travelGoalCtrl.text = data['travelGoal'] ?? '';
      _bioCtrl.text = data['bio'] ?? '';
      _isGuide = data['isGuide'] ?? false;
      _photoUrl = data['photoUrl'];
      _loading = false;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() => _newImage = File(picked.path));
    }
  }

  Future<String?> _uploadImage(String uid) async {
    if (_newImage == null) return _photoUrl;

    final ref = FirebaseStorage.instance.ref().child('user_photos/$uid.jpg');
    await ref.putFile(_newImage!);
    return await ref.getDownloadURL();
  }

  void _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final photo = await _uploadImage(uid);

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'name': _nameCtrl.text.trim(),
      'lastName': _lastNameCtrl.text.trim(),
      'location': _locationCtrl.text.trim(),
      'travelGoal': _travelGoalCtrl.text.trim(),
      'bio': _bioCtrl.text.trim(),
      'isGuide': _isGuide,
      'updatedAt': Timestamp.now(),
      'photoUrl': photo,
    });

    setState(() {
      _loading = false;
      _photoUrl = photo;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Profile updated")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        automaticallyImplyLeading: false,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _newImage != null
                            ? FileImage(_newImage!)
                            : (_photoUrl != null
                                  ? NetworkImage(_photoUrl!) as ImageProvider
                                  : const AssetImage('assets/avatar.png')),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: const Icon(Icons.edit, size: 20),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
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
                      decoration: const InputDecoration(
                        labelText: "Travel Goal",
                      ),
                    ),
                    TextFormField(
                      controller: _bioCtrl,
                      decoration: const InputDecoration(labelText: "Bio"),
                    ),
                    SwitchListTile(
                      value: _isGuide,
                      onChanged: (v) => setState(() => _isGuide = v),
                      title: const Text("I'm a guide"),
                    ),
                    const SizedBox(height: 16),
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
