import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../widgets/registerSetup/setup_step_bio.dart';
import '../../widgets/registerSetup/setup_step_location.dart';
import '../../widgets/registerSetup/setup_step_guide.dart';
import '../../widgets/registerSetup/setup_step_goal.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final PageController _controller = PageController();
  final _bioCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _goalCtrl = TextEditingController();
  bool _isGuide = false;

  int _currentPage = 0;
  bool _loading = false;
  String? _error;

  void _nextPage() {
    if (_currentPage < 3) {
      setState(() => _currentPage++);
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submit();
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'bio': _bioCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
        'isGuide': _isGuide,
        'travelGoal': _goalCtrl.text.trim(),
        'updatedAt': Timestamp.now(),
      });
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() {
        _error = 'Something went wrong: $e';
        _loading = false;
      });
    }
  }

  List<Widget> get _steps => [
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SetupStepBio(controller: _bioCtrl),
    ),
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SetupStepLocation(controller: _locationCtrl),
    ),
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SetupStepGuide(
        isGuide: _isGuide,
        onChanged: (val) => setState(() => _isGuide = val),
      ),
    ),
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SetupStepGoal(controller: _goalCtrl),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Complete your profile"),
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _ProgressBar(currentStep: _currentPage),
          Expanded(
            child: Column(
              children: [
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                Expanded(
                  child: GestureDetector(
                    onHorizontalDragEnd: (details) {
                      // details.primaryVelocity > 0: swipe w prawo (back)
                      if (details.primaryVelocity! > 0) {
                        _prevPage();
                      }
                      // details.primaryVelocity < 0: swipe w lewo (forward) - ignorujemy
                    },
                    child: PageView(
                      controller: _controller,
                      // całkowicie blokujemy wewnętrzne przewijanie
                      physics: const NeverScrollableScrollPhysics(),
                      children: _steps,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _loading
                    ? const CircularProgressIndicator()
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Row(
                          children: [
                            if (_currentPage > 0)
                              ElevatedButton(
                                onPressed: _prevPage,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text("Back"),
                              ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: _nextPage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(_currentPage < 3 ? "Next" : "Finish"),
                            ),
                          ],
                        ),
                      ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int currentStep;
  const _ProgressBar({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final totalSteps = 4;
    final progress = (currentStep + 1) / totalSteps;
    final labels = ['Bio', 'Location', 'Guide', 'Goal'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Step ${currentStep + 1} of $totalSteps: ${labels[currentStep]}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 10,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: MediaQuery.of(context).size.width * progress,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
