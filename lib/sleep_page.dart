import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class SleepPage extends StatefulWidget {
  const SleepPage({super.key});

  @override
  State<SleepPage> createState() => _SleepPageState();
}

class _SleepPageState extends State<SleepPage> {
  String selectedSound = "Rain";
  int sleepTimer = 30; // default in minutes

  final List<Map<String, dynamic>> sounds = [
    {'name': 'Rain', 'icon': Icons.water_drop},
    {'name': 'Forest', 'icon': Icons.park},
    {'name': 'Waves', 'icon': Icons.waves},
    {'name': 'Wind', 'icon': Icons.air},
    {'name': 'Fire', 'icon': Icons.local_fire_department},
  ];

  void _showTimerPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => SizedBox(
        height: 200,
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text("Set Sleep Timer",
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 18)),
            Slider(
              value: sleepTimer.toDouble(),
              min: 10,
              max: 120,
              divisions: 11,
              label: "$sleepTimer mins",
              activeColor: Colors.deepPurpleAccent,
              onChanged: (value) {
                setState(() {
                  sleepTimer = value.round();
                });
              },
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent),
              child: Text("Done", style: GoogleFonts.poppins()),
            )
          ],
        ),
      ),
    );
  }

  Widget _soundOption(String name, IconData icon) {
    final bool isSelected = selectedSound == name;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSound = name;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 14),
        width: 90,
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurpleAccent : Colors.white10,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.deepPurpleAccent.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: Colors.white),
            const SizedBox(height: 6),
            Text(name,
                style:
                    GoogleFonts.poppins(fontSize: 13, color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E2C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text("Sleep Mode",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            )),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 🌙 Lottie Animation
            Lottie.asset(
              'assets/animations/moon_sleep.json',
              height: 250,
              fit: BoxFit.cover,
              repeat: true,
            ),

            Text('"Let the day melt away..."',
                style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                    fontSize: 14)),

            const SizedBox(height: 20),

            // 🔊 Sound Options
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: sounds.length,
                itemBuilder: (context, index) {
                  return _soundOption(
                    sounds[index]['name'],
                    sounds[index]['icon'],
                  );
                },
              ),
            ),

            const SizedBox(height: 40),

            // 🕓 Timer + 🌌 Start Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: _showTimerPicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.timer, color: Colors.white70),
                        const SizedBox(width: 6),
                        Text("$sleepTimer min",
                            style: GoogleFonts.poppins(
                                fontSize: 15, color: Colors.white70)),
                      ],
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Start Sleep logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  icon: const Icon(Icons.nightlight_round),
                  label: Text("Start Sleep",
                      style: GoogleFonts.poppins(fontSize: 16)),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
