import 'package:flutter/material.dart';

class FocusModePage extends StatelessWidget {
  const FocusModePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade800,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text("Focus Mode"),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          "Time to focus and stay productive 🎯",
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
    );
  }
}
