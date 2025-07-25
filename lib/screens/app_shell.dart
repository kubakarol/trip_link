import 'package:flutter/material.dart';
import 'chat/chat_list_screen.dart';
import 'home/swipe_screen.dart';
import 'profile/profile_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({Key? key}) : super(key: key);

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 1;
  final List<Widget> _pages = const [
    ChatListScreen(),
    SwipeScreen(),
    ProfileScreen(),
  ];

  void _onTap(int i) => setState(() => _currentIndex = i);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onTap(1),
        child: const Icon(Icons.home),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              onPressed: () => _onTap(0),
            ),
            const SizedBox(width: 48),
            IconButton(
              icon: const Icon(Icons.person_outline),
              onPressed: () => _onTap(2),
            ),
          ],
        ),
      ),
    );
  }
}
