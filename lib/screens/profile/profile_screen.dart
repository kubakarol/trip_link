// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Ekrany, do których będziemy nawigować:
import 'settings_screen.dart';
import 'language_screen.dart';
import 'swipe_prefs_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final data = snap.data?.data();
        if (data == null) {
          return const Scaffold(
            body: Center(child: Text('Brak danych użytkownika')),
          );
        }

        final name = data['name'] as String? ?? '';
        final email = data['email'] as String? ?? '';
        final avatar = data['photoUrl'] as String?;
        final isGuide = data['isGuide'] as bool? ?? false;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Profil'),
            automaticallyImplyLeading: false,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // ——— Górna połowa — avatar i dane ———
                Container(
                  width: double.infinity,
                  color: Theme.of(context).colorScheme.primaryContainer,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: avatar != null
                            ? NetworkImage(avatar)
                            : null,
                        child: avatar == null
                            ? const Icon(Icons.person, size: 50)
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(email, style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 4),
                      Text(
                        isGuide
                            ? 'Jestem przewodnikiem'
                            : 'Jestem podróżnikiem',
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.edit),
                        label: const Text('Edytuj profil'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ——— Dolna połowa — pozostałe ustawienia ———
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Język aplikacji'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LanguageScreen()),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.filter_alt),
                  title: const Text('Preferencje swipowania'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SwipePrefsScreen()),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Powiadomienia'),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/profile/settings/notifications',
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.lock_reset),
                  title: const Text('Zmień hasło'),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/profile/settings/change_password',
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Wyloguj się'),
                  onTap: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pushReplacementNamed(context, '/');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_forever),
                  title: const Text('Usuń konto'),
                  onTap: () {
                    // TODO: dialog potwierdzenia, usunięcie konta
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
