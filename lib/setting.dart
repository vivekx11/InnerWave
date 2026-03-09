import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not launch ${url.toString()}',
              style: GoogleFonts.poppins(),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const black = Color(0xFF0E0F14);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE6F3FF),
              Color(0xFFB3E5FC),
              Color(0xFF7ADCB8),
              Color(0xFFFFF1DB),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Text(
                      'Settings',
                      style: GoogleFonts.poppins(
                        color: black,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      children: [
                        Center(
                          child: Text(
                            "About Us",
                            style: GoogleFonts.poppins(
                              color: black,
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Meditation is an ancient practice used for mental clarity, emotional calm, and self-awareness. Medtion guides you on this journey with proven techniques and supportive tools.",
                          style: GoogleFonts.poppins(
                            color: black.withOpacity(0.86),
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Key Sections
                        _sectionTitle("1. Guided Meditation", black),
                        _sectionDescription(
                            "Guided meditations help you find relaxation and mindfulness, suitable for all experience levels.",
                            black),
                        _sectionTitle("2. Sleep", black),
                        _sectionDescription(
                            "Tools and sessions to help you achieve deep, restful sleep and improve your sleep patterns.",
                            black),
                        _sectionTitle("3. Focus", black),
                        _sectionDescription(
                            "Techniques and audios to boost concentration and productivity throughout your day.",
                            black),
                        _sectionTitle("4. Meditation", black),
                        _sectionDescription(
                            "Discover daily meditation routines designed to foster peace, clarity, and emotional balance.",
                            black),
                        _sectionTitle("5. Daily Feel", black),
                        _sectionDescription(
                            "Track your mood and emotions to understand yourself better and improve your daily wellbeing.",
                            black),
                        _sectionTitle("6. Daily Task", black),
                        _sectionDescription(
                            "Set and organize your daily goals to stay on track and achieve more each day.",
                            black),
                        _sectionTitle("7. AI Bot", black),
                        _sectionDescription(
                            "Interact with the AI Bot for motivation, reminders, and personalized support anytime.",
                            black),
                        const SizedBox(height: 32),
                        Text(
                          'Preferences',
                          style: GoogleFonts.poppins(
                            color: black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: Text('Enable Notifications',
                              style: GoogleFonts.poppins(
                                  color: black, fontSize: 16)),
                          activeColor: const Color(0xFF5B7CFA),
                          value: _notificationsEnabled,
                          onChanged: (value) {
                            setState(() {
                              _notificationsEnabled = value;
                            });
                          },
                        ),
                        SwitchListTile(
                          title: Text('Enable Dark Mode',
                              style: GoogleFonts.poppins(
                                  color: black, fontSize: 16)),
                          activeColor: const Color(0xFF5B7CFA),
                          value: _darkModeEnabled,
                          onChanged: (value) {
                            setState(() {
                              _darkModeEnabled = value;
                            });
                          },
                        ),
                        const SizedBox(height: 40),
                        Divider(thickness: 2, color: Color(0xFFB08CFF)),
                        const SizedBox(height: 30),
                        // Profile Footer
                        Center(
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 36,
                                backgroundColor: const Color(0xFFB08CFF),
                                child: const Icon(Icons.person,
                                    color: Colors.white, size: 40),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "Your Name",
                                style: GoogleFonts.poppins(
                                  color: black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              Text(
                                "Flutter Developer • Designer",
                                style: GoogleFonts.poppins(
                                  color: black.withOpacity(0.6),
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Building beautiful, user-focused digital experiences that blend design and technology. Always learning. Always improving.",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  color: black.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.code,
                                        color: Color(0xFFB08CFF)),
                                    tooltip: 'GitHub',
                                    onPressed: () => _launchUrl(Uri.parse(
                                        "https://github.com/vivekx11")),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.launch,
                                        color: Color(0xFFB08CFF)),
                                    tooltip: 'Portfolio',
                                    onPressed: () => _launchUrl(
                                        Uri.parse("https://yourportfolio.com")),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.email,
                                        color: Color(0xFFB08CFF)),
                                    tooltip: 'Email',
                                    onPressed: () => _launchUrl(Uri.parse(
                                        "mailto:viveksawji@email.com")),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                        // Footer Socials
                        Center(
                          child: Column(
                            children: [
                              Text(
                                '© 2025 InnerWave',
                                style: GoogleFonts.poppins(
                                  color: black.withOpacity(0.6),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.email,
                                        color: Color(0xFFB08CFF)),
                                    tooltip: 'Email',
                                    onPressed: () => _launchUrl(Uri.parse(
                                        "mailto:viveksawji@gamil.com")),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.camera_alt,
                                        color: Color(0xFFB08CFF)),
                                    tooltip: 'Instagram',
                                    onPressed: () => _launchUrl(Uri.parse(
                                        "https://instagram.com/vivekx___")),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.alternate_email,
                                        color: Color(0xFFB08CFF)),
                                    tooltip: 'X',
                                    onPressed: () => _launchUrl(
                                        Uri.parse("https://x.com/viveksawji")),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.code,
                                        color: Color(0xFFB08CFF)),
                                    tooltip: 'GitHub',
                                    onPressed: () => _launchUrl(Uri.parse(
                                        "https://github.com/vivekx11")),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _sectionDescription(String desc, Color color) {
    return Column(
      children: [
        Text(
          desc,
          style: GoogleFonts.poppins(
            color: color.withOpacity(0.85),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 24),
      ],
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
