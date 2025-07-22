import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../profile/profile_screen.dart'; // import z aliasem względnym
import 'chat_detail_screen.dart';

class InvitationScreen extends StatefulWidget {
  const InvitationScreen({Key? key}) : super(key: key);

  @override
  State<InvitationScreen> createState() => _InvitationScreenState();
}

class _InvitationScreenState extends State<InvitationScreen> {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _fetchInvites() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('invites')
        .get()
        .then((snap) => snap.docs);
  }

  Future<void> _acceptInvite(String inviterId) async {
    final batch = FirebaseFirestore.instance.batch();
    final inviteRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('invites')
        .doc(inviterId);
    batch.delete(inviteRef);

    final chatRef = FirebaseFirestore.instance.collection('chats').doc();
    batch.set(chatRef, {
      'participants': [uid, inviterId],
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessage': '',
    });

    await batch.commit();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ChatDetailScreen(chatId: chatRef.id, otherUserId: inviterId),
      ),
    );
  }

  Future<void> _rejectInvite(String inviterId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('invites')
        .doc(inviterId)
        .delete();
  }

  void _showProfile(String otherUid) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: ProfileScreen(
          userId: otherUid, // teraz istnieje takie pole
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Zaproszenia')),
      body: FutureBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
        future: _fetchInvites(),
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final invites = snap.data!;
          if (invites.isEmpty) {
            return const Center(child: Text('Brak nowych zaproszeń'));
          }
          return ListView.builder(
            itemCount: invites.length,
            itemBuilder: (ctx, i) {
              final inviterId = invites[i].id;
              final at = (invites[i].data()['at'] as Timestamp).toDate();
              return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(inviterId)
                    .get(),
                builder: (ctx2, snap2) {
                  if (snap2.connectionState != ConnectionState.done) {
                    return const ListTile();
                  }
                  final u = snap2.data!.data()!;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                        u['photoUrl'] as String? ??
                            u['avatar'] as String? ??
                            '',
                      ),
                    ),
                    title: Text(u['name'] as String? ?? ''),
                    subtitle: Text(
                      'Zaproszono: ${at.hour}:${at.minute.toString().padLeft(2, '0')}',
                    ),
                    onTap: () => _showProfile(inviterId),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () async {
                            await _rejectInvite(inviterId);
                            setState(() {});
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () async {
                            await _acceptInvite(inviterId);
                          },
                        ),
                      ],
                    ),
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
