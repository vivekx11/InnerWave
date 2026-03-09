import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'meditation.dart';
import 'focus.dart';
import 'sleep_page.dart';
import 'stress_page.dart';
import 'calm_page.dart';
import 'guid_meditation.dart';
import 'focus_mode_page.dart';
import 'assistant.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Welcome Back',
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0E0F14),
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: const Color(0xFF5B7CFA).withOpacity(0.4),
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'How are you feeling today?',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: const Color(0xFF0E0F14).withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),

            // Bento Grid
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0,
                ),
                itemCount: 6,
                itemBuilder: (context, index) {
                  return _buildBentoItem(context, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBentoItem(BuildContext context, int index) {
    final items = [
      {
        'title': 'Meditation',
        'subtitle': 'Find inner peace',
        'icon': Icons.self_improvement,
        'color': const Color(0xFF8A88FF),
        'page': const MeditationPage(),
      },
      {
        'title': 'Sleep',
        'subtitle': 'Rest better',
        'icon': Icons.bedtime,
        'color': const Color(0xFF7ADCB8),
        'page': const SleepPage(),
      },
      {
        'title': 'Stress Relief',
        'subtitle': 'Calm your mind',
        'icon': Icons.spa,
        'color': const Color(0xFFFFD166),
        'page': const StressPage(),
      },
      {
        'title': 'Calm',
        'subtitle': 'Relax & unwind',
        'icon': Icons.air,
        'color': const Color(0xFFB08CFF),
        'page': const CalmPage(),
      },
      {
        'title': 'Guided',
        'subtitle': 'Expert sessions',
        'icon': Icons.headphones,
        'color': const Color(0xFF5B7CFA),
        'page': const GuidedMeditationPage(),
      },
      {
        'title': 'Assistant',
        'subtitle': 'AI guidance',
        'icon': Icons.chat,
        'color': const Color(0xFFFF6B6B),
        'page': const AssistantPage(),
      },
    ];

    final item = items[index];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => item['page'] as Widget),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              item['color'] as Color,
              (item['color'] as Color).withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: (item['color'] as Color).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            // Content with Icon Logo
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon Logo
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Text content
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          item['title'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['subtitle'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
