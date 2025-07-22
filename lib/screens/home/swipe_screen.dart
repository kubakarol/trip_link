// lib/screens/home/swipe_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

enum Direction { left, right }

class SwipeScreen extends StatefulWidget {
  const SwipeScreen({Key? key}) : super(key: key);

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen>
    with SingleTickerProviderStateMixin {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  List<DocumentSnapshot<Map<String, dynamic>>> _cards = [];
  int _currentIndex = 0;

  // Drag state
  Offset _dragOffset = Offset.zero;
  double _dragAngle = 0;

  // Preferencje
  late String _desiredCity;
  late int _minAge, _maxAge;
  late bool _showGuides, _showTravelers;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final meUid = _auth.currentUser!.uid;
    final meDoc = await _firestore.collection('users').doc(meUid).get();
    final me = meDoc.data()!;
    final prefs = me['preferences'] as Map<String, dynamic>? ?? {};

    _minAge = prefs['minAge'] as int? ?? 18;
    _maxAge = prefs['maxAge'] as int? ?? 99;
    _showGuides = prefs['showGuides'] as bool? ?? true;
    _showTravelers = prefs['showTravelers'] as bool? ?? true;
    _desiredCity = (me['travelGoal'] as String?)?.toLowerCase() ?? '';

    // 1) pobierz listę polubień i odrzuceń
    final likesSnap = await _firestore
        .collection('users')
        .doc(meUid)
        .collection('likes')
        .get();
    final passesSnap = await _firestore
        .collection('users')
        .doc(meUid)
        .collection('passes')
        .get();
    final likedIds = likesSnap.docs.map((d) => d.id).toSet();
    final passedIds = passesSnap.docs.map((d) => d.id).toSet();

    // 2) pobierz listę chatów i uczestników
    final chatSnap = await _firestore
        .collection('chats')
        .where('participants', arrayContains: meUid)
        .get();
    final chattedWith = <String>{};
    for (var c in chatSnap.docs) {
      final parts = (c.data()['participants'] as List).cast<String>();
      for (var p in parts) {
        if (p != meUid) chattedWith.add(p);
      }
    }

    // 3) pobierz wszystkich użytkowników
    final snap = await _firestore.collection('users').get();
    final today = DateTime.now();

    // 4) filtruj
    final filtered = snap.docs.where((doc) {
      final uid = doc.id;
      if (uid == meUid) return false;
      if (likedIds.contains(uid)) return false;
      if (passedIds.contains(uid)) return false;
      if (chattedWith.contains(uid)) return false;

      final d = doc.data();
      // miasto
      final theirCity = (d['location'] as String?)?.toLowerCase() ?? '';
      if (_desiredCity.isNotEmpty && theirCity != _desiredCity) return false;

      // rola
      final isGuide = d['isGuide'] as bool? ?? false;
      if (!isGuide && !_showTravelers) return false;
      if (isGuide && !_showGuides) return false;

      // wiek
      final rawB = d['birthdate'];
      if (rawB == null || rawB is! Timestamp) return false;
      final age = today.year - rawB.toDate().year;
      if (age < _minAge || age > _maxAge) return false;

      return true;
    }).toList();

    // 5) sortuj prowodników na topie
    filtered.sort((a, b) {
      final aG = (a.data()['isGuide'] as bool? ?? false) ? 1 : 0;
      final bG = (b.data()['isGuide'] as bool? ?? false) ? 1 : 0;
      return bG - aG;
    });

    setState(() {
      _cards = filtered;
      _currentIndex = _cards.isEmpty ? -1 : 0;
    });
  }

  Future<void> _onSwipe(Direction dir) async {
    final meUid = _auth.currentUser!.uid;
    if (_currentIndex < 0 || _currentIndex >= _cards.length) return;
    final targetUid = _cards[_currentIndex].id;

    // zapisz w likes/passes
    final meRef = _firestore.collection('users').doc(meUid);
    if (dir == Direction.right) {
      await meRef.collection('likes').doc(targetUid).set({
        'at': FieldValue.serverTimestamp(),
      });
      // invite u odbiorcy
      await _firestore
          .collection('users')
          .doc(targetUid)
          .collection('invites')
          .doc(meUid)
          .set({'at': FieldValue.serverTimestamp()});
    } else {
      await meRef.collection('passes').doc(targetUid).set({
        'at': FieldValue.serverTimestamp(),
      });
    }

    setState(() {
      _dragOffset = Offset.zero;
      _dragAngle = 0;
      _currentIndex++;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentIndex < 0 || _currentIndex >= _cards.length) {
      return const Scaffold(body: Center(child: Text("Brak więcej profili")));
    }

    final data = _cards[_currentIndex].data()!;
    final photo = data['photoUrl'] as String? ?? data['avatar'] as String?;
    final name = data['name'] as String? ?? '';
    final city = data['location'] as String? ?? '';
    final birth = data['birthdate'] as Timestamp;
    final age = DateTime.now().year - birth.toDate().year;
    final role = (data['isGuide'] as bool? ?? false)
        ? 'Przewodnik'
        : 'Podróżnik';
    final bio = data['bio'] as String? ?? '';

    final size = MediaQuery.of(context).size;
    final cardW = size.width * 0.9;
    final cardH = size.height * 0.7;
    final threshold = size.width * 0.25;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Swipe"),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: GestureDetector(
          onPanUpdate: (d) => setState(() {
            _dragOffset += d.delta;
            _dragAngle = (_dragOffset.dx / size.width) * 0.5;
          }),
          onPanEnd: (_) {
            if (_dragOffset.dx.abs() > threshold) {
              _onSwipe(_dragOffset.dx > 0 ? Direction.right : Direction.left);
            } else {
              setState(() {
                _dragOffset = Offset.zero;
                _dragAngle = 0;
              });
            }
          },
          child: Transform.translate(
            offset: _dragOffset,
            child: Transform.rotate(
              angle: _dragAngle,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SizedBox(
                  width: cardW,
                  height: cardH,
                  child: Column(
                    children: [
                      // zdjęcie
                      Expanded(
                        flex: 2,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: photo != null
                              ? Image.network(
                                  photo,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                )
                              : Container(color: Colors.grey.shade300),
                        ),
                      ),
                      // dane + opis
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "$city, $age lat",
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(role),
                              const SizedBox(height: 8),
                              if (bio.isNotEmpty)
                                Text(
                                  bio,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              const Spacer(),
                              Center(
                                child: Text("Przesuń w prawo, by zaprosić"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
