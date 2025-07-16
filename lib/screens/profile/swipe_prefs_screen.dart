import 'package:flutter/material.dart';
import 'package:trip_link/services/settings_service.dart';

class SwipePrefsScreen extends StatefulWidget {
  const SwipePrefsScreen({super.key});

  @override
  State<SwipePrefsScreen> createState() => _SwipePrefsScreenState();
}

class _SwipePrefsScreenState extends State<SwipePrefsScreen> {
  final _settings = SettingsService();

  bool _showGuides = true;
  bool _showTravelers = true;
  RangeValues _ageRange = const RangeValues(18, 60);
  String _preferredGender = 'any'; // 'male', 'female', 'any'

  @override
  void initState() {
    super.initState();
    _settings.fetchPreferences().then((p) {
      setState(() {
        _showGuides = p['showGuides'] as bool? ?? true;
        _showTravelers = p['showTravelers'] as bool? ?? true;
        _ageRange = RangeValues(
          (p['minAge'] as num?)?.toDouble() ?? 18,
          (p['maxAge'] as num?)?.toDouble() ?? 60,
        );
        _preferredGender = p['preferredGender'] as String? ?? 'any';
      });
    });
  }

  Future<void> _save() async {
    final prefs = await _settings.fetchPreferences();
    prefs['showGuides'] = _showGuides;
    prefs['showTravelers'] = _showTravelers;
    prefs['minAge'] = _ageRange.start.toInt();
    prefs['maxAge'] = _ageRange.end.toInt();
    prefs['preferredGender'] = _preferredGender;
    await _settings.updatePreferences(prefs);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preferencje swipowania')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Pokaż przewodników'),
              value: _showGuides,
              onChanged: (v) => setState(() => _showGuides = v),
            ),
            SwitchListTile(
              title: const Text('Pokaż podróżników'),
              value: _showTravelers,
              onChanged: (v) => setState(() => _showTravelers = v),
            ),
            const SizedBox(height: 24),
            Text(
              'Zakres wieku: ${_ageRange.start.toInt()}–${_ageRange.end.toInt()}',
            ),
            RangeSlider(
              values: _ageRange,
              min: 18,
              max: 99,
              divisions: 81,
              labels: RangeLabels(
                _ageRange.start.toInt().toString(),
                _ageRange.end.toInt().toString(),
              ),
              onChanged: (r) => setState(() => _ageRange = r),
            ),
            const SizedBox(height: 24),
            const Text('Preferowana płeć użytkowników:'),
            RadioListTile<String>(
              title: const Text('Dowolna'),
              value: 'any',
              groupValue: _preferredGender,
              onChanged: (v) => setState(() => _preferredGender = v!),
            ),
            RadioListTile<String>(
              title: const Text('Mężczyźni'),
              value: 'male',
              groupValue: _preferredGender,
              onChanged: (v) => setState(() => _preferredGender = v!),
            ),
            RadioListTile<String>(
              title: const Text('Kobiety'),
              value: 'female',
              groupValue: _preferredGender,
              onChanged: (v) => setState(() => _preferredGender = v!),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _save,
        child: const Icon(Icons.save),
      ),
    );
  }
}
