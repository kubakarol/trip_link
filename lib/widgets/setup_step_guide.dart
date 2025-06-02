import 'package:flutter/material.dart';

class SetupStepGuide extends StatelessWidget {
  final bool isGuide;
  final ValueChanged<bool> onChanged;
  const SetupStepGuide({
    super.key,
    required this.isGuide,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Do you want to be a guide?",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SwitchListTile.adaptive(
            title: Text(
              isGuide
                  ? "Yes, I want to guide others"
                  : "No, I don't want to guide",
            ),
            value: isGuide,
            onChanged: onChanged,
            activeColor: Colors.blue,
          ),
        ],
      ),
    );
  }
}
