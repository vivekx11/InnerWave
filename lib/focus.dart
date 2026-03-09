import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'sleep_page.dart';
import 'stress_page.dart';
import 'focus_mode_page.dart';
import 'calm_page.dart';
import 'user_streaks.dart';
import 'meditation.dart';
import 'guid_meditation.dart';
import 'assistant.dart';
import 'setting.dart';
import 'profile.dart';

class FocusPage extends StatefulWidget {
  const FocusPage({Key? key}) : super(key: key);

  @override
  State<FocusPage> createState() => _FocusPageState();
}

class _FocusPageState extends State<FocusPage> {
  int _selectedIndex = 0;

  final List<_FocusOption> allOptions = const [
    _FocusOption(
      label: "Sleep",
      description: "Improve your rest",
      icon: Icons.nightlight_round,
      color: Color(0xFF8A88FF),
      page: SleepPage(),
    ),
    _FocusOption(
      label: "Daily Feels",
      description: "Track your feelings",
      icon: Icons.emoji_emotions_outlined,
      color: Color(0xFFF691C7),
      page: StressPage(),
    ),
    _FocusOption(
      label: "Focus",
      description: "Boost productivity",
      icon: Icons.center_focus_strong,
      color: Color(0xFFF691C7),
      page: FocusModePage(),
    ),
    _FocusOption(
      label: "Daily Task",
      description: "Achieve your goals",
      icon: Icons.checklist_rtl_sharp,
      color: Color(0xFF8A88FF),
      page: CalmPage(),
    ),
    _FocusOption(
      label: "Meditation",
      description: "Calm your mind",
      icon: Icons.self_improvement,
      color: Color(0xFF8A88FF),
      page: MeditationPage(),
    ),
    _FocusOption(
      label: "AI Assistant",
      description: "Get help instantly",
      icon: Icons.smart_toy_outlined,
      color: Color(0xFFF691C7),
      page: AssistantPage(),
    ),
  ];

  void _onNavTap(int index) {
    if (index == _selectedIndex) return;

    setState(() => _selectedIndex = index);

    if (index == 0) {
      // Already on home, do nothing.
    } else {
      Widget? page;
      switch (index) {
        case 1:
          page = ProfilePage(moodEntries: []);

          break;
        case 2:
          page =
              const UserStreaksPage(); // Assuming Daily Diary is Daily Feels (StressPage)
          break;
        case 3:
          page = const SettingsPage();
          break;
      }
      if (page != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page!),
        ).then((_) => setState(() => _selectedIndex = 0));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const black = Color(0xFF0E0F14);
    final secondaryTextColor = black.withOpacity(0.6);
    const double boxSize = 48.0; // Reduced container size for boxes
    return Scaffold(
      backgroundColor: const Color(0xFFB3E5FC), // Ice base color
      body: Stack(
        children: [
          // Decorative background with gradient and blurry circles
          Positioned.fill(
            child: Container(
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
          // Main UI content
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22.0, vertical: 8),
                  child: Center(
                    child: Text(
                      "InnerWave",
                      style: GoogleFonts.poppins(
                        color: black,
                        fontWeight: FontWeight.bold,
                        fontSize: 27,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // Lottie Animation, doubled size
                Center(
                  child: Lottie.asset(
                    'assets/animations/relax_bg.json',
                    width: 240,
                    height: 240,
                    fit: BoxFit.contain,
                  ),
                ),
                // Guided Meditation Card
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22.0, vertical: 6),
                  child: _GuidedMeditationCard(
                    titleColor: black,
                    subtitleColor: secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 12),
                // 3x2 grid of smaller boxes (containers reduced, font/icon unchanged)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      itemCount: allOptions.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        final option = allOptions[index];
                        return SizedBox(
                          width: boxSize,
                          height: boxSize,
                          child:
                              _FocusGlassCard(option: option, boxSize: boxSize),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _GlassmorphismBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

class _GuidedMeditationCard extends StatelessWidget {
  final Color titleColor;
  final Color subtitleColor;

  const _GuidedMeditationCard({
    Key? key,
    this.titleColor = const Color(0xFF0E0F14),
    this.subtitleColor = const Color(0xFF707070),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => GuidedMeditationPage())),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF9C27B0).withOpacity(0.17),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
              color: const Color(0xFF9C27B0).withOpacity(0.28), width: 1.7),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9C27B0).withOpacity(0.10),
              blurRadius: 10,
            )
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        child: Row(
          children: [
            Icon(Icons.self_improvement, color: titleColor, size: 36),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Guided Meditation",
                    style: GoogleFonts.poppins(
                      color: titleColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.5,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    "Start your journey to mindfulness",
                    style: GoogleFonts.poppins(
                      color: subtitleColor,
                      fontSize: 14.2,
                    ),
                  )
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.black38, size: 19),
          ],
        ),
      ),
    );
  }
}

class _FocusGlassCard extends StatelessWidget {
  final _FocusOption option;
  final double boxSize;

  const _FocusGlassCard({required this.option, required this.boxSize, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => option.page)),
        child: Container(
          width: boxSize,
          height: boxSize,
          decoration: BoxDecoration(
            color: option.color.withOpacity(0.19),
            borderRadius: BorderRadius.circular(15),
            border:
                Border.all(color: option.color.withOpacity(0.28), width: 1.3),
            boxShadow: [
              BoxShadow(color: option.color.withOpacity(0.11), blurRadius: 8)
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 22, // icon size unchanged
                backgroundColor: option.color.withOpacity(0.21),
                child: Icon(option.icon, color: Colors.black87, size: 24),
              ),
              const SizedBox(height: 7),
              Text(
                option.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 13, // font size unchanged
                ),
              ),
              if (option.description != null) ...[
                const SizedBox(height: 2),
                Text(
                  option.description!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.black54,
                    fontSize: 10.2, // font size unchanged
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassmorphismBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const _GlassmorphismBottomNavBar(
      {required this.selectedIndex, required this.onTap, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<BottomNavItem> navItems = [
      BottomNavItem(
        icon: Icons.home_rounded,
        activeColor: const Color(0xFF8A88FF),
        inactiveColor: const Color(0xFF8A88FF).withOpacity(0.4),
      ),
      BottomNavItem(
        icon: Icons.person_rounded,
        activeColor: const Color(0xFFF691C7),
        inactiveColor: const Color(0xFFF691C7).withOpacity(0.4),
      ),
      BottomNavItem(
        icon: Icons.book_rounded,
        activeColor: const Color(0xFF7ADCB8),
        inactiveColor: const Color(0xFF7ADCB8).withOpacity(0.4),
      ),
      BottomNavItem(
        icon: Icons.settings_rounded,
        activeColor: const Color(0xFFFFD166),
        inactiveColor: const Color(0xFFFFD166).withOpacity(0.4),
      ),
    ];

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.25),
            border: Border.all(
              color: Colors.white.withOpacity(0.18),
              width: 1.0,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: navItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isActive = index == selectedIndex;

                  return GestureDetector(
                    onTap: () => onTap(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.white.withOpacity(0.1)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isActive
                              ? item.activeColor.withOpacity(0.3)
                              : Colors.white.withOpacity(0.1),
                          width: isActive ? 2 : 1,
                        ),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: item.activeColor.withOpacity(0.2),
                                  blurRadius: 15,
                                  spreadRadius: 1,
                                ),
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  spreadRadius: 0,
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5,
                                  spreadRadius: 0,
                                ),
                              ],
                      ),
                      child: AnimatedScale(
                        scale: isActive ? 1.15 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          item.icon,
                          color:
                              isActive ? item.activeColor : item.inactiveColor,
                          size: isActive ? 28 : 24,
                          shadows: isActive
                              ? [
                                  Shadow(
                                    color: item.activeColor.withOpacity(0.3),
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final Color activeColor;
  final Color inactiveColor;

  const BottomNavItem({
    required this.icon,
    required this.activeColor,
    required this.inactiveColor,
  });
}

class _FocusOption {
  final String label;
  final String? description;
  final IconData icon;
  final Color color;
  final Widget page;

  const _FocusOption({
    required this.label,
    this.description,
    required this.icon,
    required this.color,
    required this.page,
  });
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
