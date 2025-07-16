// lib/screens/profile/account_actions_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountActionsScreen extends StatelessWidget {
  const AccountActionsScreen({super.key});

  Future<void> _deleteAccount(BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    // potwierdź dialogiem:
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Usuń konto'),
        content: const Text('Czy na pewno chcesz usunąć konto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Anuluj'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Usuń'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // usuwamy dokument użytkownika, a potem konto w Auth
    await FirebaseFirestore.instance.collection('users').doc(uid).delete();
    await FirebaseAuth.instance.currentUser!.delete();

    // wracamy do ekranu powitalnego i czyścimy stos
    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Konto')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Wyloguj się'),
            onTap: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: const Text('Usuń konto'),
            onTap: () => _deleteAccount(context),
          ),
        ],
      ),
    );
  }
}
