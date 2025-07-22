// lib/screens/chat/chat_list_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// rozwiązuje konflikt nazwy Badge
import 'package:badges/badges.dart' as badges;

import 'invitation_screen.dart';
import 'chat_detail_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  _fetchChats() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final snap = await FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: uid)
        .get();
    return snap.docs;
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Czaty'),
        automaticallyImplyLeading: false,
        actions: [
          // Badge z liczbą zaproszeń
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .collection('invites')
                .snapshots(),
            builder: (ctx, snap) {
              final count = snap.data?.docs.length ?? 0;
              return badges.Badge(
                position: badges.BadgePosition.topEnd(top: 4, end: 4),
                badgeContent: Text(
                  '$count',
                  style: const TextStyle(color: Colors.white),
                ),
                showBadge: count > 0,
                child: IconButton(
                  icon: const Icon(Icons.mail_outline),
                  tooltip: 'Zaproszenia',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const InvitationScreen(),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
        future: _fetchChats(),
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final chats = snap.data!;
          if (chats.isEmpty) {
            return const Center(child: Text('Brak aktywnych czatów'));
          }
          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (ctx, i) {
              final data = chats[i].data();
              final myUid = FirebaseAuth.instance.currentUser!.uid;
              final otherUid = (data['participants'] as List)
                  .cast<String>()
                  .firstWhere((x) => x != myUid);
              return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(otherUid)
                    .get(),
                builder: (ctx2, snap2) {
                  if (snap2.connectionState != ConnectionState.done) {
                    return const ListTile();
                  }
                  final userData = snap2.data!.data()!;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                        userData['photoUrl'] as String? ??
                            userData['avatar'] as String? ??
                            '',
                      ),
                    ),
                    title: Text(userData['name'] as String? ?? ''),
                    subtitle: Text(data['lastMessage'] as String? ?? ''),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatDetailScreen(
                            chatId: chats[i].id,
                            otherUserId: otherUid,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
