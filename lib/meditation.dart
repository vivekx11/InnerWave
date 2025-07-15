import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';

class MeditationPage extends StatefulWidget {
  const MeditationPage({super.key});

  @override
  State<MeditationPage> createState() => _MeditationPageState();
}

class _MeditationPageState extends State<MeditationPage>
    with TickerProviderStateMixin {
  int _selectedMinutes = 5;
  int _remainingSeconds = 0;
  bool _isMeditating = false;

  late AudioPlayer _audioPlayer;
  late FlutterLocalNotificationsPlugin _notificationsPlugin;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initNotifications();
    _progressController = AnimationController(vsync: this);
  }

  Future<void> _initNotifications() async {
    _notificationsPlugin = FlutterLocalNotificationsPlugin();
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(initSettings);
  }

  Future<void> _showCompletionNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'meditation_channel',
      'Meditation Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);
    await _notificationsPlugin.show(
      0,
      '🧘 Meditation Complete',
      'Great job finishing your session!',
      notificationDetails,
    );
  }

  void _startMeditation() {
    setState(() {
      _remainingSeconds = _selectedMinutes * 60;
      _isMeditating = true;
    });

    _progressController.duration = Duration(seconds: _remainingSeconds);
    _progressController.forward(from: 0);
    _countdown();
  }

  void _stopMeditation() {
    setState(() {
      _isMeditating = false;
      _remainingSeconds = 0;
    });
    _progressController.reset();
    _audioPlayer.stop();
  }

  void _countdown() async {
    while (_remainingSeconds > 0 && _isMeditating) {
      await Future.delayed(const Duration(seconds: 1));
      if (!_isMeditating) break;
      setState(() {
        _remainingSeconds--;
      });
    }

    if (_remainingSeconds == 0 && _isMeditating) {
      await _playCompletionSound();
      await _showCompletionNotification();
      HapticFeedback.mediumImpact();
      setState(() => _isMeditating = false);
    }
  }

  Future<void> _playCompletionSound() async {
    try {
      await _audioPlayer.play(AssetSource('chime.wav'));
    } catch (e) {
      debugPrint("Error playing sound: $e");
    }
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E2C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Meditation",
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 20)),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _isMeditating ? _buildMeditationScreen() : _buildSetupScreen(),
        ),
      ),
    );
  }

  Widget _buildSetupScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("🧘 Choose Your Meditation Time",
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 22)),
        const SizedBox(height: 30),
        Slider(
          value: _selectedMinutes.toDouble(),
          min: 1,
          max: 60,
          divisions: 59,
          label: "$_selectedMinutes min",
          onChanged: (value) {
            setState(() {
              _selectedMinutes = value.toInt();
            });
          },
          activeColor: Colors.deepPurpleAccent,
          inactiveColor: Colors.white30,
        ),
        Text("$_selectedMinutes Minutes",
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 18)),
        const SizedBox(height: 40),
        ElevatedButton.icon(
          onPressed: _startMeditation,
          icon: const Icon(Icons.play_arrow),
          label: Text("Start Meditation",
              style: GoogleFonts.poppins(fontSize: 16)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildMeditationScreen() {
    double progress =
        (_selectedMinutes * 60 - _remainingSeconds) / (_selectedMinutes * 60);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Breathe in... Breathe out...",
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 20)),
        const SizedBox(height: 40),
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.deepPurpleAccent.withOpacity(0.3),
                    Colors.transparent
                  ],
                  radius: 0.9,
                ),
              ),
            ),
            SizedBox(
              width: 200,
              height: 200,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 10,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            Text(
              _formatTime(_remainingSeconds),
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 36),
            ),
          ],
        ),
        const SizedBox(height: 50),
        ElevatedButton.icon(
          onPressed: _stopMeditation,
          icon: const Icon(Icons.stop),
          label: Text("Stop", style: GoogleFonts.poppins(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 6,
          ),
        ),
      ],
    );
  }
}
