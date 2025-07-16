import 'package:flutter/material.dart';
import 'package:trip_link/services/settings_service.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  final _settings = SettingsService();
  String? _selected;

  final _langs = {
    'en': 'English',
    'pl': 'Polski',
    'de': 'Deutsch',
    'es': 'Español',
    // dodaj inne według potrzeb
  };

  @override
  void initState() {
    super.initState();
    _settings.fetchPreferences().then((p) {
      setState(() {
        _selected = p['language'] as String? ?? 'en';
      });
    });
  }

  void _save() async {
    final prefs = await _settings.fetchPreferences();
    prefs['language'] = _selected;
    await _settings.updatePreferences(prefs);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_selected == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Wybierz język')),
      body: ListView(
        children: _langs.entries.map((e) {
          return RadioListTile<String>(
            title: Text(e.value),
            value: e.key,
            groupValue: _selected,
            onChanged: (v) => setState(() => _selected = v),
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _save,
        child: const Icon(Icons.save),
      ),
    );
  }
}
