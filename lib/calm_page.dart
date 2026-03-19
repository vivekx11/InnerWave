import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'dart:async';

//follow up code 

class DailyTask {
  String task;
  TimeOfDay time;
  int durationMinutes;
  bool completed;
  DateTime? startTime;

  DailyTask({
    required this.task,
    required this.time,
    required this.durationMinutes,
    this.completed = false,
    this.startTime,
  });

  Map<String, dynamic> toMap() => {
        'task': task,
        'hour': time.hour,
        'minute': time.minute,
        'durationMinutes': durationMinutes,
        'completed': completed,
        'startTime': startTime?.toIso8601String(),
      };
// static 
  static DailyTask fromMap(Map<dynamic, dynamic> map) => DailyTask(
        task: map['task'],
        time: TimeOfDay(hour: map['hour'], minute: map['minute']),
        durationMinutes: map['durationMinutes'] ?? 1,
        completed: map['completed'] ?? false,
        startTime:
            map['startTime'] != null ? DateTime.parse(map['startTime']) : null,
      );
}

class CalmPage extends StatefulWidget {
  const CalmPage({super.key});

  @override
  State<CalmPage> createState() => _CalmPageState();
}

class _CalmPageState extends State<CalmPage> with WidgetsBindingObserver {
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _minuteController = TextEditingController();

  TimeOfDay? _selectedTime;
  List<DailyTask> _tasks = [];
  Timer? _timer;

  late FlutterLocalNotificationsPlugin _notificationsPlugin;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initNotifications();
    _loadTasks();
    _startTimeCheck();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _taskController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _loadTasks();
  }

  Future<void> _initNotifications() async {
    _notificationsPlugin = FlutterLocalNotificationsPlugin();
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(initSettings);
  }

  Future<void> _showTaskNotification(String task) async {
    const androidDetails = AndroidNotificationDetails(
      'task_channel',
      'Task Reminder',
      importance: Importance.max,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);
    await _notificationsPlugin.show(
      0,
      '📋 Task Reminder',
      'Time to work on: $task',
      notificationDetails,
    );
  }

  Future<void> _showTaskOverNotification(String task) async {
    const androidDetails = AndroidNotificationDetails(
      'task_channel_over',
      'Task Completion',
      importance: Importance.max,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);
    await _notificationsPlugin.show(
      1,
      '✅ Task Completed',
      '$task is done! Great job!',
      notificationDetails,
    );
  }

  Future<void> _loadTasks() async {
    final box = Hive.box('tasksBox');
    List list = box.get('dailyTasks', defaultValue: []);
    setState(() {
      _tasks = list.isNotEmpty
          ? list
              .map((e) => DailyTask.fromMap(Map<String, dynamic>.from(e)))
              .toList()
          : [];
    });
  }

  Future<void> _saveTasks() async {
    final box = Hive.box('tasksBox');
    List list = _tasks.map((e) => e.toMap()).toList();
    await box.put('dailyTasks', list);
  }

  void _startTimeCheck() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      final now = TimeOfDay.now();
      final nowAbs = DateTime.now();
      // Start tasks when time matches.
      for (int i = 0; i < _tasks.length; i++) {
        var t = _tasks[i];
        if (!t.completed &&
            t.startTime == null &&
            now.hour == t.time.hour &&
            now.minute == t.time.minute) {
          await _showTaskNotification(t.task);
          HapticFeedback.lightImpact();
          setState(() {
            t.startTime = nowAbs;
          });
          await _saveTasks();
        }
      }
      // Mark as completed and show notification if time passed
      for (int i = 0; i < _tasks.length; i++) {
        var t = _tasks[i];
        if (!t.completed && t.startTime != null) {
          if (nowAbs.isAfter(
              t.startTime!.add(Duration(minutes: t.durationMinutes)))) {
            await _showTaskOverNotification(t.task);
            setState(() {
              t.completed = true;
            });
            await _saveTasks();
          }
        }
      }
    });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.tealAccent,
              surface: Color(0xFF20223A),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.tealAccent,
              ),
            ),
            dialogBackgroundColor: Colors.blueGrey[900],
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _addTask() {
    int? duration = int.tryParse(_minuteController.text);
    if (_taskController.text.isNotEmpty &&
        _selectedTime != null &&
        duration != null &&
        duration > 0) {
      setState(() {
        _tasks.add(DailyTask(
          task: _taskController.text,
          time: _selectedTime!,
          durationMinutes: duration,
        ));
        _taskController.clear();
        _minuteController.clear();
        _selectedTime = null;
      });
      _saveTasks();
    }
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
    _saveTasks();
  }

  void _markComplete(int index) {
    setState(() {
      _tasks[index].completed = true;
    });
    _saveTasks();
  }

  @override
  Widget build(BuildContext context) {
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
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'Back',
                    iconSize: 30,
                    splashRadius: 24,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: _buildTaskListScreen(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskListScreen(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: Center(
        child: SingleChildScrollView(
          child: Card(
            elevation: 12,
            color: Colors.black.withOpacity(0.23),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 30.0, horizontal: 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Today's Tasks 🎯",
                    style: GoogleFonts.poppins(
                      color: Colors.tealAccent,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 22),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      var t = _tasks[index];

                      Widget? timerWidget;
                      if (t.startTime != null && !t.completed) {
                        DateTime now = DateTime.now();
                        DateTime end = t.startTime!
                            .add(Duration(minutes: t.durationMinutes));
                        Duration remaining = end.difference(now);
                        int remainingSeconds =
                            remaining.inSeconds > 0 ? remaining.inSeconds : 0;

                        timerWidget = remainingSeconds > 0
                            ? TweenAnimationBuilder<int>(
                                key: ValueKey(t.startTime),
                                tween:
                                    IntTween(begin: remainingSeconds, end: 0),
                                duration: Duration(seconds: remainingSeconds),
                                builder: (context, value, child) {
                                  int min = value ~/ 60;
                                  int sec = value % 60;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 3.0),
                                    child: Text(
                                      "Timer: ${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}",
                                      style: GoogleFonts.poppins(
                                          color: Colors.amberAccent,
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  );
                                },
                              )
                            : Container();
                      }

                      return Card(
                        color: t.completed
                            ? Colors.tealAccent.withOpacity(0.19)
                            : Colors.white10,
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: ListTile(
                          leading: Icon(
                            t.completed
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: t.completed
                                ? Colors.tealAccent
                                : Colors.tealAccent.shade100,
                          ),
                          title: Text(
                            t.task,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 17,
                              decoration: t.completed
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "At ${t.time.format(context)}  |  ${t.durationMinutes} min",
                                style: GoogleFonts.poppins(
                                  color: Colors.tealAccent,
                                  fontSize: 15,
                                ),
                              ),
                              if (timerWidget != null) timerWidget,
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!t.completed)
                                IconButton(
                                  icon: const Icon(Icons.check),
                                  tooltip: "Mark as complete",
                                  color: Colors.green,
                                  onPressed: () => _markComplete(index),
                                ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                tooltip: "Delete",
                                color: Colors.red,
                                onPressed: () => _deleteTask(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  Divider(color: Colors.tealAccent.withOpacity(0.5)),
                  Text(
                    "Add a new task",
                    style: GoogleFonts.poppins(
                      color: Colors.tealAccent,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _taskController,
                    style:
                        GoogleFonts.poppins(color: Colors.white, fontSize: 17),
                    decoration: InputDecoration(
                      hintText: "What will you accomplish?",
                      hintStyle: GoogleFonts.poppins(
                          color: Colors.white54, fontSize: 15),
                      prefixIcon: Icon(
                        Icons.edit_note,
                        color: Colors.black.withOpacity(0.23),
                      ),
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _minuteController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "Minutes (ex: 5)",
                            hintStyle:
                                GoogleFonts.poppins(color: Colors.white54),
                            prefixIcon: Icon(
                              Icons.timer,
                              color: Colors.black.withOpacity(0.23),
                            ),
                            filled: true,
                            fillColor: Colors.white10,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text("min",
                          style: GoogleFonts.poppins(color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.teal.withOpacity(0.85),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      side: BorderSide.none,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 13),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.alarm, color: Colors.white),
                    label: Text(
                      _selectedTime == null
                          ? "Pick Time"
                          : _selectedTime!.format(context),
                      style: GoogleFonts.poppins(
                          fontSize: 16, color: Colors.white),
                    ),
                    onPressed: () => _selectTime(context),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 36, vertical: 14),
                      elevation: 10,
                    ),
                    icon: const Icon(Icons.add),
                    label: Text(
                      "Add Task",
                      style: GoogleFonts.poppins(
                          fontSize: 16, color: Colors.white),
                    ),
                    onPressed: _addTask,
                  ),
                ],
              ),
            ),
          ),
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
