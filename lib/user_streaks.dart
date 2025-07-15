import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserStreakPage extends StatefulWidget {
  const UserStreakPage({super.key});

  @override
  State<UserStreakPage> createState() => _UserStreakPageState();
}

class _UserStreakPageState extends State<UserStreakPage> {
  int totalSessions = 0;
  int currentStreak = 0;
  int longestStreak = 0;
  String lastMeditationDate = "";

  @override
  void initState() {
    super.initState();
    _loadStreakData();
  }

  Future<void> _loadStreakData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      totalSessions = prefs.getInt('totalSessions') ?? 0;
      currentStreak = prefs.getInt('currentStreak') ?? 0;
      longestStreak = prefs.getInt('longestStreak') ?? 0;
      lastMeditationDate = prefs.getString('lastDate') ?? 'N/A';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E2C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Your Streaks',
            style: GoogleFonts.poppins(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadStreakData,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatCard("Total Sessions", totalSessions),
            _buildStatCard("Current Streak", currentStreak),
            _buildStatCard("Longest Streak", longestStreak),
            _buildStatCard("Last Meditation Date", lastMeditationDate),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, dynamic value) {
    return Card(
      color: Colors.deepPurpleAccent.withOpacity(0.3),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        title: Text(title,
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 18)),
        trailing: Text('$value',
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 20)),
      ),
    );
  }
}
