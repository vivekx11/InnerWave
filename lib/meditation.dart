import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'time_tracking_mixin.dart';
import 'user_insights.dart';

// --- Session model (inside file!) -----
class MeditationSession extends ChangeNotifier {
  int selectedMinutes;
  int remainingSeconds;
  bool isMeditating;
  Timer? _timer;

  MeditationSession({this.selectedMinutes = 10})
      : remainingSeconds = 0,
        isMeditating = false;

  void startSession() {
    remainingSeconds = selectedMinutes * 60;
    isMeditating = true;
    _startTimer();
    notifyListeners();
  }

  void startSessionWithTracking() {
    startSession();
  }

  void stopSession() {
    isMeditating = false;
    remainingSeconds = 0;
    _timer?.cancel();
    notifyListeners();
  }

  Future<void> stopSessionWithTracking() async {
    stopSession();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0 && isMeditating) {
        remainingSeconds--;
        notifyListeners();
      } else {
        timer.cancel();
        isMeditating = false;
        _onSessionComplete();
        notifyListeners();
      }
    });
  }

  void setMinutes(int min) {
    selectedMinutes = min;
    notifyListeners();
  }

  void _onSessionComplete() {
    // This will be overridden in the UI to handle time tracking
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// ------------ Main Meditation Page Widget -------------
class MeditationPage extends StatefulWidget {
  const MeditationPage({Key? key}) : super(key: key);

  @override
  State<MeditationPage> createState() => _MeditationPageState();
}

class _MeditationPageState extends State<MeditationPage>
    with TickerProviderStateMixin, TimeTrackingMixin {
  late AudioPlayer _audioPlayer;
  late FlutterLocalNotificationsPlugin _notificationsPlugin;
  late AnimationController _breathController;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initNotifications();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
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

  Future<void> _playCompletionSound() async {
    try {
      await _audioPlayer.play(AssetSource('chime.wav'));
    } catch (e) {
      debugPrint("Error playing sound: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _breathController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  Widget _pastelBackground({required Widget child}) {
    return SizedBox.expand(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE0BBE4),
              Color(0xFFB5EAD7),
              Color(0xFFFFDAC1),
              Color(0xFFF3E1DD),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 80,
              left: 40,
              child: _BlurryCircle(
                color: Colors.yellow.withOpacity(0.16),
                size: 100,
              ),
            ),
            Positioned(
              top: 180,
              right: 60,
              child: Icon(
                Icons.cloud,
                size: 90,
                color: Colors.white.withOpacity(0.18),
              ),
            ),
            Positioned(
              bottom: 120,
              left: 40,
              child: Container(
                width: 110,
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.lightGreenAccent.withOpacity(0.14),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                  ),
                ),
              ),
            ),
            Positioned(
              top: -70,
              left: -60,
              child: _BlurryCircle(
                color: Colors.purpleAccent.withOpacity(0.15),
                size: 160,
              ),
            ),
            Positioned(
              bottom: -50,
              right: -50,
              child: _BlurryCircle(
                color: Colors.blueAccent.withOpacity(0.13),
                size: 140,
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                    iconSize: 30,
                    splashRadius: 24,
                  ),
                ),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }

  Widget _minutePillSelector(MeditationSession session) {
    final presets = [3, 5, 10, 15, 20, 30, 45];
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: presets.map((m) {
              final selected = session.selectedMinutes == m;
              return GestureDetector(
                onTap: () => session.setMinutes(m),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 210),
                  margin: const EdgeInsets.symmetric(horizontal: 7),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: selected
                        ? const LinearGradient(
                            colors: [Color(0xFF7F53AC), Color(0xFF647DEE)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.10),
                              Colors.white.withOpacity(0.05)
                            ],
                          ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                                color: Colors.purpleAccent.withOpacity(0.13),
                                blurRadius: 18,
                                offset: const Offset(0, 4))
                          ]
                        : [],
                    border: selected
                        ? Border.all(
                            color: Colors.white.withOpacity(0.7), width: 2)
                        : Border.all(color: Colors.white12, width: 1),
                  ),
                  child: Column(
                    children: [
                      Text('$m',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          )),
                      Text('min',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                Colors.black.withOpacity(selected ? 0.7 : 0.43),
                          )),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        _customMinuteField(session),
      ],
    );
  }

  Widget _customMinuteField(MeditationSession session) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.timer_outlined, color: Colors.white54, size: 18),
        const SizedBox(width: 6),
        Container(
          width: 56,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(11),
          ),
          child: TextField(
            keyboardType: TextInputType.number,
            maxLength: 2,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: Colors.black, fontSize: 17),
            decoration: InputDecoration(
              border: InputBorder.none,
              counterText: '',
              hintText: '${session.selectedMinutes}',
              hintStyle: GoogleFonts.poppins(
                color: Colors.black54,
              ),
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            onSubmitted: (v) {
              final input = int.tryParse(v);
              if (input != null && input > 0 && input <= 60) {
                session.setMinutes(input);
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        Text(
          "minutes",
          style: GoogleFonts.poppins(
              color: Colors.black, fontSize: 15, fontWeight: FontWeight.w400),
        ),
      ],
    );
  }

  Widget _buildSetupScreen(MeditationSession session) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _glassCard(
              child: Text(
                "Select Meditation Length",
                style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 26),
            _minutePillSelector(session),
            const SizedBox(height: 35),
            _purpleGradientButton(
              icon: Icons.spa_rounded,
              text: 'Start Meditation',
              onPressed: () {
                session.startSession();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _glassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.white12, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.09),
            blurRadius: 7,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildMeditationScreen(MeditationSession session) {
    final progress = (session.selectedMinutes * 60 - session.remainingSeconds) /
        (session.selectedMinutes * 60);
    final breath = (0.88 + 0.13 * _breathController.value);

    // completion callback
    if (session.remainingSeconds == 0 && session.isMeditating) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _playCompletionSound();
        await _showCompletionNotification();
        HapticFeedback.mediumImpact();

        // Track the completed session
        await UserInsights.recordActivity(
            'Meditation', session.selectedMinutes * 60);

        session.stopSession();
      });
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _breathController,
            builder: (context, child) {
              return Transform.scale(scale: breath, child: child);
            },
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.purpleAccent
                        .withOpacity(0.18 + 0.12 * _breathController.value),
                    blurRadius: 44,
                    spreadRadius: 10,
                  ),
                ],
                gradient: RadialGradient(
                  colors: [
                    Colors.deepPurpleAccent.withOpacity(0.26),
                    Colors.transparent,
                  ],
                  radius: 0.99,
                ),
              ),
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 14,
                      backgroundColor: Colors.white12,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.purpleAccent),
                    ),
                    Text(
                      _formatTime(session.remainingSeconds),
                      style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 38,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 35),
          Text(
            _breathController.value < 0.5 ? "Inhale..." : "Exhale...",
            style: GoogleFonts.poppins(
                color: Colors.black, fontSize: 22, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 45),
          _purpleGradientButton(
              icon: Icons.stop,
              text: "Stop",
              onPressed: () {
                session.stopSession();
              },
              gradientColors: [Colors.deepPurple, Colors.purple]),
        ],
      ),
    );
  }

  Widget _purpleGradientButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
    List<Color>? gradientColors,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 38, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: gradientColors ??
                [Colors.purpleAccent, Colors.deepPurpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
                color: (gradientColors?.first ?? Colors.purpleAccent)
                    .withOpacity(0.21),
                blurRadius: 14,
                spreadRadius: 2,
                offset: const Offset(0, 5))
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 25),
            const SizedBox(width: 11),
            Text(text,
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MeditationSession>.value(
      value: meditationSessionSingleton,
      child: Scaffold(
        body: Consumer<MeditationSession>(
          builder: (context, session, _) => _pastelBackground(
            child: SafeArea(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: session.isMeditating
                    ? _buildMeditationScreen(session)
                    : _buildSetupScreen(session),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Keep singleton so state persists across navigation/pop/push (must be global)
final meditationSessionSingleton = MeditationSession();

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
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
    );
  }
}
