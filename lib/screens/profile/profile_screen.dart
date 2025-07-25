// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Ekrany, do których będziemy nawigować:
import 'settings_screen.dart';
import 'language_screen.dart';
import 'swipe_prefs_screen.dart';

class ProfileScreen extends StatelessWidget {
  /// Jeśli podasz [userId], wyświetli profil tej osoby.
  /// Jeśli [userId] zostanie pominięte (null), pokaże profil zalogowanego użytkownika.
  final String? userId;
  const ProfileScreen({Key? key, this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Wybieramy dokument: albo innego użytkownika, albo siebie
    final uid = userId ?? FirebaseAuth.instance.currentUser!.uid;

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
        final location = data['location'] as String? ?? '';
        final bio = data['bio'] as String? ?? '';

        return Scaffold(
          appBar: AppBar(
            title: const Text('Profil'),
            automaticallyImplyLeading:
                userId !=
                null, // ← jeśli to nie Twój profil, pokaż strzałkę "wstecz"
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
                            ? 'Jestem przewodnikiem w $location'
                            : 'Jestem podróżnikiem w $location',
                      ),
                      const SizedBox(height: 8),
                      if (bio.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            bio,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      const SizedBox(height: 16),
                      if (userId == null) // edycja tylko własnego profilu
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
                if (userId == null) ...[
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
                      MaterialPageRoute(
                        builder: (_) => const SwipePrefsScreen(),
                      ),
                    ),
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
                ] else ...[
                  const SizedBox(height: 24),
                  ElevatedButton(
                    child: const Text('Zamknij'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
