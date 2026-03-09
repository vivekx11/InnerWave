import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

// ------------ Persistent Focus Session Model --------------
class FocusSession extends ChangeNotifier {
  int workDuration; // in seconds
  int breakDuration; // in seconds
  int secondsRemaining;
  bool isWorking;
  bool isRunning;
  Timer? _timer;

  FocusSession({
    this.workDuration = 25 * 60,
    this.breakDuration = 5 * 60,
  })  : secondsRemaining = 25 * 60,
        isWorking = true,
        isRunning = false;

  static final Int64List vibrationPattern =
      Int64List.fromList([0, 1000, 500, 1000]);

  void startTimer() {
    if (isRunning) return;
    isRunning = true;
    _startCountDown();
    notifyListeners();
  }

  void _startCountDown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining > 0 && isRunning) {
        secondsRemaining--;
        notifyListeners();
      } else {
        _timer?.cancel();
        isRunning = false;
        _toggleWorkBreak();
        notifyListeners();
      }
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    isRunning = false;
    notifyListeners();
  }

  void resetTimer() {
    _timer?.cancel();
    isRunning = false;
    secondsRemaining = isWorking ? workDuration : breakDuration;
    notifyListeners();
  }

  void _toggleWorkBreak() {
    isWorking = !isWorking;
    secondsRemaining = isWorking ? workDuration : breakDuration;
  }

  void updateDurations(int workMinutes, int breakMinutes) {
    workDuration = workMinutes * 60;
    breakDuration = breakMinutes * 60;
    if (!isRunning) {
      secondsRemaining = isWorking ? workDuration : breakDuration;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// ----------- Main Focus Mode Page -------------
class FocusModePage extends StatefulWidget {
  const FocusModePage({Key? key}) : super(key: key);

  @override
  State<FocusModePage> createState() => _FocusModePageState();
}

class _FocusModePageState extends State<FocusModePage> {
  late FlutterLocalNotificationsPlugin _notificationsPlugin;
  bool _showSettings = false;

  @override
  void initState() {
    super.initState();
    _notificationsPlugin = FlutterLocalNotificationsPlugin();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings =
        InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload == 'start_next') {
          final session = context.read<FocusSession>();
          setState(() {
            session.isRunning = false;
            session.isWorking = !session.isWorking;
            session.secondsRemaining = session.isWorking
                ? session.workDuration
                : session.breakDuration;
          });
          session.startTimer();
        }
      },
    );
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> _showNotification(String title, String body,
      {String? payload}) async {
    final androidDetails = AndroidNotificationDetails(
      'pomodoro_channel',
      'Pomodoro Notifications',
      channelDescription: 'Pomodoro Timer Alerts',
      importance: Importance.max,
      priority: Priority.high,
      vibrationPattern: FocusSession.vibrationPattern,
      playSound: true,
    );
    final notificationDetails = NotificationDetails(android: androidDetails);
    await _notificationsPlugin.show(0, title, body, notificationDetails,
        payload: payload);
  }

  String _formatTime(int seconds) {
    final minutesStr = (seconds ~/ 60).toString().padLeft(2, '0');
    final secondsStr = (seconds % 60).toString().padLeft(2, '0');
    return '$minutesStr:$secondsStr';
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FocusSession>.value(
      value: focusSessionSingleton,
      child: Consumer<FocusSession>(
        builder: (context, session, _) {
          // Show notifications for state changes
          if (session.secondsRemaining == 0 && !session.isRunning) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              await _showNotification(
                session.isWorking ? "Great job!" : "Break Over!",
                session.isWorking
                    ? "Focus session complete. Time for a break!"
                    : "Break is over! Ready for another session?",
                payload: 'start_next',
              );
            });
          }
          return Scaffold(
            body: Container(
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
                          icon: const Icon(Icons.arrow_back_ios,
                              color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                          tooltip: 'Back',
                          iconSize: 30,
                          splashRadius: 24,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Card(
                            color: Colors.grey[900],
                            elevation: 8,
                            shape: const CircleBorder(),
                            child: Container(
                              width: 220,
                              height: 220,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [Colors.black, Colors.grey],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    value: 1 -
                                        (session.secondsRemaining /
                                            (session.isWorking
                                                ? session.workDuration
                                                : session.breakDuration)),
                                    strokeWidth: 10,
                                    backgroundColor: Colors.grey[800],
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            Colors.tealAccent),
                                  ),
                                  Text(
                                    _formatTime(session.secondsRemaining),
                                    style: const TextStyle(
                                      fontSize: 48,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            session.isWorking
                                ? 'Stay productive and focused! 🎯'
                                : 'Relax and recharge! 😊',
                            style: const TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 36),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: session.isRunning
                                    ? null
                                    : () {
                                        session.startTimer();
                                        _showNotification(
                                          session.isWorking
                                              ? 'Focus Mode Started'
                                              : 'Break Started',
                                          session.isWorking
                                              ? 'Stay focused! Pomodoro timer started 🎯'
                                              : 'Time for a break 😊',
                                          payload: 'start_next',
                                        );
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 22, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(Icons.play_arrow,
                                    color: Colors.white),
                                label: const Text('Start',
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.white)),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton.icon(
                                onPressed: session.isRunning
                                    ? () {
                                        session.pauseTimer();
                                        _showNotification(
                                          'Timer Paused',
                                          'Paused at ${_formatTime(session.secondsRemaining)}. Resume when ready.',
                                        );
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 22, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(Icons.pause,
                                    color: Colors.white),
                                label: const Text('Pause',
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.white)),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton.icon(
                                onPressed: () {
                                  session.resetTimer();
                                  _showNotification(
                                    'Timer Reset',
                                    'Reset to ${_formatTime(session.secondsRemaining)}.',
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 22, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(Icons.refresh,
                                    color: Colors.white),
                                label: const Text('Reset',
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.white)),
                              ),
                            ],
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: _showSettings ? 170 : 0,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 16),
                            child: _showSettings
                                ? Column(
                                    children: [
                                      TextField(
                                        style: const TextStyle(
                                            color: Colors.white),
                                        decoration: const InputDecoration(
                                          labelText: 'Work Duration (minutes)',
                                          labelStyle:
                                              TextStyle(color: Colors.white),
                                          border: OutlineInputBorder(),
                                          isDense: true,
                                        ),
                                        keyboardType: TextInputType.number,
                                        onChanged: (value) {
                                          final minutes = int.tryParse(value) ??
                                              (session.workDuration ~/ 60);
                                          session.updateDurations(minutes,
                                              session.breakDuration ~/ 60);
                                        },
                                      ),
                                      const SizedBox(height: 10),
                                      TextField(
                                        style: const TextStyle(
                                            color: Colors.white),
                                        decoration: const InputDecoration(
                                          labelText: 'Break Duration (minutes)',
                                          labelStyle:
                                              TextStyle(color: Colors.white),
                                          border: OutlineInputBorder(),
                                          isDense: true,
                                        ),
                                        keyboardType: TextInputType.number,
                                        onChanged: (value) {
                                          final minutes = int.tryParse(value) ??
                                              (session.breakDuration ~/ 60);
                                          session.updateDurations(
                                              session.workDuration ~/ 60,
                                              minutes);
                                        },
                                      ),
                                    ],
                                  )
                                : const SizedBox.shrink(),
                          ),
                          if (_showSettings) const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: Icon(
                            _showSettings ? Icons.close : Icons.settings,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: () {
                            setState(() {
                              _showSettings = !_showSettings;
                            });
                          },
                          tooltip: 'Settings',
                          splashRadius: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Singleton instance for persistence
final FocusSession focusSessionSingleton = FocusSession();

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
        boxShadow: [BoxShadow(color: color, blurRadius: 40, spreadRadius: 10)],
      ),
    );
  }
}
