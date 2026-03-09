import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'profile.dart';
import 'daily_diary.dart';
import 'setting.dart';
import 'home_page.dart';

class NavigationWrapper extends StatefulWidget {
  const NavigationWrapper({super.key});

  @override
  State<NavigationWrapper> createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<NavigationWrapper> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const ProfilePage(moodEntries: []),
    const DailyDiaryPage(),
    const SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Consistent background across all pages
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
          // Background decorative elements
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
          // Main content
          _pages[_selectedIndex],
        ],
      ),
      bottomNavigationBar: _GlassmorphismBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class _GlassmorphismBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const _GlassmorphismBottomNavBar({
    required this.selectedIndex,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<BottomNavItem> navItems = [
      BottomNavItem(
        icon: Icons.home_rounded,
        label: 'Home',
        activeColor: const Color(0xFF8A88FF),
        inactiveColor: const Color(0xFF8A88FF).withOpacity(0.4),
      ),
      BottomNavItem(
        icon: Icons.person_rounded,
        label: 'Profile',
        activeColor: const Color(0xFFF691C7),
        inactiveColor: const Color(0xFFF691C7).withOpacity(0.4),
      ),
      BottomNavItem(
        icon: Icons.book_rounded,
        label: 'Diary',
        activeColor: const Color(0xFF7ADCB8),
        inactiveColor: const Color(0xFF7ADCB8).withOpacity(0.4),
      ),
      BottomNavItem(
        icon: Icons.settings_rounded,
        label: 'Settings',
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
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.85),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
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
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.white.withOpacity(0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isActive
                              ? Colors.white.withOpacity(0.2)
                              : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? Colors.white.withOpacity(0.2)
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isActive
                                    ? Colors.white.withOpacity(0.3)
                                    : Colors.white.withOpacity(0.1),
                                width: isActive ? 2 : 1,
                              ),
                              boxShadow: isActive
                                  ? [
                                      BoxShadow(
                                        color:
                                            Colors.white.withOpacity(0.2),
                                        blurRadius: 15,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: AnimatedScale(
                              scale: isActive ? 1.15 : 1.0,
                              duration: const Duration(milliseconds: 300),
                              child: Icon(
                                item.icon,
                                color: isActive
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.5),
                                size: isActive ? 26 : 22,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight:
                                  isActive ? FontWeight.w600 : FontWeight.w400,
                              color: isActive
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.5),
                            ),
                            child: Text(item.label),
                          ),
                        ],
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
  final String label;
  final Color activeColor;
  final Color inactiveColor;

  const BottomNavItem({
    required this.icon,
    required this.label,
    required this.activeColor,
    required this.inactiveColor,
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
