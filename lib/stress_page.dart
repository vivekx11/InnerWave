import 'package:flutter/material.dart';

class StressPage extends StatelessWidget {
  const StressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade700,
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: const Text("Stress Relief"),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          "Let’s breathe and reduce stress 🌬️",
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
    );
  }
}
