import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'navigation_wrapper.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // ✅ Open all boxes you’ll need in the app
  await Hive.openBox('tasksBox');
  await Hive.openBox('userStreaks');

  // Initialize Timezone
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Kolkata')); // IST

  runApp(const MeditationApp());
}

class MeditationApp extends StatelessWidget {
  const MeditationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meditation App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor:
            const Color(0xFFFFF1DB), // warm light background
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ).apply(
          bodyColor: const Color(0xFF0E0F14), // dark text color
          displayColor: const Color(0xFF0E0F14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5B7CFA),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
            elevation: 8,
            shadowColor: const Color(0xFF5B7CFA).withOpacity(0.5),
          ),
        ),
      ),
      home: const WelcomePage(),
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  void _startApp(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const NavigationWrapper()),
    );
  }

  @override
  Widget build(BuildContext context) {
    const black = Color(0xFF0E0F14);
    final secondaryTextColor = black.withOpacity(0.6);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE6F3FF), // Ice
              Color(0xFFB3E5FC), // Sky
              Color(0xFF7ADCB8), // Mint
              Color(0xFFFFF1DB), // Warm light
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0),
                      Colors.white.withOpacity(0.12),
                    ],
                    radius: 1.2,
                    center: const Alignment(0.1, -0.2),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 80,
              left: 40,
              child: _BlurryCircle(
                color: const Color(0xFFFFD166).withOpacity(0.18),
                size: 100,
              ),
            ),
            Positioned(
              top: 180,
              right: 60,
              child: Icon(
                Icons.cloud,
                size: 90,
                color: Colors.white.withOpacity(0.16),
              ),
            ),
            Positioned(
              top: -70,
              left: -60,
              child: _BlurryCircle(
                color: const Color(0xFFB08CFF).withOpacity(0.16),
                size: 160,
              ),
            ),
            Positioned(
              bottom: -50,
              right: -50,
              child: _BlurryCircle(
                color: const Color(0xFF5B7CFA).withOpacity(0.14),
                size: 140,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/animations/meditation.json',
                  height: 320,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 40),
                Text(
                  'Find Your Inner Peace',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: black,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Color(0xFF5B7CFA).withOpacity(0.4),
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Take a deep breath and begin your journey to calmness.',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: secondaryTextColor,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(40),
                    onTap: () => _startApp(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 48, vertical: 18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF5B7CFA),
                            Color(0xFF4E5DFA),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF5B7CFA).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 12),
                          Text(
                            'Get Started',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Developed & Designed by VivekSawji',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BlurryCircle extends StatelessWidget {
  final Color color;
  final double size;

  const _BlurryCircle({required this.color, required this.size, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color, blurRadius: 40, spreadRadius: 8)],
      ),
    );
  }
}
