import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;
  final String otherUserId;

  const ChatDetailScreen({
    Key? key,
    required this.chatId,
    required this.otherUserId,
  }) : super(key: key);

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _controller = TextEditingController();

  Future<Map<String, dynamic>> _fetchOtherUser() async {
    final doc = await _firestore
        .collection('users')
        .doc(widget.otherUserId)
        .get();
    return doc.data() ?? {};
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final uid = _auth.currentUser!.uid;
    final now = Timestamp.now();

    _firestore
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add({'senderId': uid, 'text': text, 'createdAt': now});

    _firestore.collection('chats').doc(widget.chatId).update({
      'lastMessage': text,
      'updatedAt': now,
    });

    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildMessage(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final uid = _auth.currentUser!.uid;
    final isMe = data['senderId'] == uid;
    final text = data['text'] as String? ?? '';
    final ts = data['createdAt'] as Timestamp? ?? Timestamp.now();
    final time = TimeOfDay.fromDateTime(ts.toDate()).format(context);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isMe
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(text, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messagesRef = _firestore
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true);

    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchOtherUser(),
      builder: (ctx, snapUser) {
        final other = snapUser.data;
        final otherName = other?['name'] as String? ?? '—';
        final otherPhoto =
            other?['photoUrl'] as String? ?? other?['avatar'] as String?;

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                CircleAvatar(
                  backgroundImage: otherPhoto != null
                      ? NetworkImage(otherPhoto)
                      : null,
                  child: otherPhoto == null ? const Icon(Icons.person) : null,
                ),
                const SizedBox(width: 12),
                Text(otherName),
              ],
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: messagesRef.snapshots(),
                  builder: (ctx, snap) {
                    if (snap.connectionState != ConnectionState.active) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snap.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return const Center(
                        child: Text('Tu zaczyna się rozmowa'),
                      );
                    }
                    return ListView.builder(
                      reverse: true,
                      itemCount: docs.length,
                      itemBuilder: (ctx, i) => _buildMessage(docs[i]),
                    );
                  },
                ),
              ),
              SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration(
                            hintText: 'Napisz wiadomość...',
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _sendMessage,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
