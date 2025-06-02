import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final guides = [
      {
        "name": "Sophia",
        "city": "Sydney",
        "avatar": "https://i.pravatar.cc/150?img=47",
      },
      {
        "name": "Emily",
        "city": "Sydney",
        "avatar": "https://i.pravatar.cc/150?img=15",
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Home"),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: "Search",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: guides.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final guide = guides[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(guide["avatar"]!),
                    ),
                    title: Text(guide["name"]!),
                    subtitle: Text(guide["city"]!),
                    onTap: () {}, // TODO: navigate to chat/profile
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
