import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _push = true;
  bool _email = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Powiadomienia')),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text('Push notifications'),
            value: _push,
            onChanged: (v) => setState(() => _push = v),
          ),
          SwitchListTile(
            title: const Text('E‑mail notifications'),
            value: _email,
            onChanged: (v) => setState(() => _email = v),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: zapisz w SettingsService jeśli chcesz
          Navigator.pop(context);
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}
