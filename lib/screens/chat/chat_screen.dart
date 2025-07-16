import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Czaty'),
        automaticallyImplyLeading: false, // usuwa strzałkę
      ),
      body: const Center(child: Text('Tu będzie lista czatów')),
    );
  }
}
