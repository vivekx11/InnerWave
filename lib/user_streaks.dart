import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class UserStreaksPage extends StatefulWidget {
  const UserStreaksPage({Key? key}) : super(key: key);

  @override
  State<UserStreaksPage> createState() => _UserStreaksPageState();
}

class _UserStreaksPageState extends State<UserStreaksPage> {
  late Box _box;
  final TextEditingController _controller = TextEditingController();

  bool _loading = true;
  int currentStreak = 0;
  String? lastDiaryDate;
  Map<String, String> diaryEntries = {};

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _initBox();
  }

  Future<void> _initBox() async {
    if (!Hive.isBoxOpen('diaryBox')) {
      _box = await Hive.openBox('diaryBox');
    } else {
      _box = Hive.box('diaryBox');
    }

    lastDiaryDate = _box.get('lastDiaryDate');
    currentStreak = _box.get('streak', defaultValue: 0);
    diaryEntries =
        Map<String, String>.from(_box.get('entries', defaultValue: {}));

    setState(() {
      _loading = false;
      _selectedDay = DateTime.now();
      _controller.text = _getEntry(DateTime.now());
    });
  }

  Future<void> _saveDiary() async {
    String diaryText = _controller.text.trim();
    if (diaryText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Diary cannot be empty!")),
      );
      return;
    }

    final todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (lastDiaryDate == todayDate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You've already written today's diary!")),
      );
      return;
    }

    if (lastDiaryDate != null) {
      final prev = DateTime.parse(lastDiaryDate!);
      final now = DateTime.parse(todayDate);
      final diff = now.difference(prev).inDays;
      if (diff == 1) {
        currentStreak += 1;
      } else {
        currentStreak = 1;
      }
    } else {
      currentStreak = 1;
    }

    lastDiaryDate = todayDate;
    await _box.put('lastDiaryDate', todayDate);
    await _box.put('streak', currentStreak);

    diaryEntries[todayDate] = diaryText;
    await _box.put('entries', diaryEntries);

    setState(() {
      _controller.text = _getEntry(DateTime.now());
      _selectedDay = DateTime.now();
    });

    _controller.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Diary saved!")),
    );
  }

  String _getEntry(DateTime day) {
    final key = DateFormat('yyyy-MM-dd').format(day);
    return diaryEntries[key] ?? "";
  }

  bool _isToday(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _hasEntry(DateTime day) => _getEntry(day).isNotEmpty;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _diaryEntryWidget() {
    if (_selectedDay == null) {
      return Text(
        "Pick a day",
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: Colors.blueGrey,
        ),
      );
    }
    final isToday = _isToday(_selectedDay);
    final hasEntry = _hasEntry(_selectedDay!);

    if (isToday && !hasEntry) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Your entry for today:",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 17,
              color: Colors.teal.shade900,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            minLines: 3,
            maxLines: 5,
            enabled: true,
            decoration: InputDecoration(
              hintText: "Write your diary...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              fillColor: Colors.white.withOpacity(0.8),
              filled: true,
            ),
          ),
          const SizedBox(height: 11),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveDiary,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Save Diary Entry",
                style: GoogleFonts.poppins(fontSize: 18),
              ),
            ),
          ),
        ],
      );
    }

    if (hasEntry) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isToday)
            Text(
              "Read-only entry for ${DateFormat.yMMMd().format(_selectedDay!)}:",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 17,
                color: Colors.teal.shade900,
              ),
            ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.teal.shade200, width: 1.2),
            ),
            padding: const EdgeInsets.all(12),
            child: Text(
              _getEntry(_selectedDay!),
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      );
    }

    return Text(
      "No diary for this day.",
      style: GoogleFonts.poppins(
        color: Colors.black54,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const black = Color(0xFF0E0F14);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
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
              Center(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: _loading
                      ? const CircularProgressIndicator()
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Daily Diary",
                              style: GoogleFonts.poppins(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                color: Colors.orange.shade50,
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.white54,
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                              child: Text(
                                "🔥 Current streak: $currentStreak days",
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: Colors.orange.shade900,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 22),

                            // Calendar in a Container box with decoration
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.15),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  )
                                ],
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Transform.scale(
                                scale: 0.85, // Reduce size by 15%
                                child: TableCalendar(
                                  focusedDay: _focusedDay,
                                  firstDay: DateTime(DateTime.now().year - 2),
                                  lastDay: DateTime(DateTime.now().year + 2),
                                  calendarFormat: CalendarFormat.month,
                                  availableGestures: AvailableGestures.all,
                                  calendarStyle: CalendarStyle(
                                    todayDecoration: BoxDecoration(
                                      color: Colors.teal.shade100,
                                      shape: BoxShape.circle,
                                    ),
                                    selectedDecoration: BoxDecoration(
                                      color: Colors.orange.shade300,
                                      shape: BoxShape.circle,
                                    ),
                                    markersAlignment: Alignment.bottomCenter,
                                  ),
                                  selectedDayPredicate: (day) =>
                                      _selectedDay != null &&
                                      isSameDay(_selectedDay, day),
                                  eventLoader: (day) {
                                    final hasEntry = _getEntry(day).isNotEmpty;
                                    return hasEntry ? ["diary"] : [];
                                  },
                                  calendarBuilders: CalendarBuilders(
                                    defaultBuilder: (context, date, _) {
                                      final hasEntry =
                                          _getEntry(date).isNotEmpty;

                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedDay = date;
                                            _focusedDay = date;
                                            _controller.text = _getEntry(date);
                                          });
                                          if (hasEntry) {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text(
                                                  'Diary Entry for ${DateFormat.yMMMd().format(date)}',
                                                  style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                                content: SingleChildScrollView(
                                                  child: Text(
                                                    _getEntry(date),
                                                    style:
                                                        GoogleFonts.poppins(),
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .pop(),
                                                    child: const Text('Close'),
                                                  )
                                                ],
                                              ),
                                            );
                                          }
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isSameDay(_selectedDay, date)
                                                ? Colors.orange.shade300
                                                : Colors.transparent,
                                          ),
                                          alignment: Alignment.center,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Text(
                                                '${date.day}',
                                                style: GoogleFonts.poppins(
                                                  color: hasEntry
                                                      ? Colors.orange.shade900
                                                      : Colors.black87,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              if (hasEntry)
                                                Positioned(
                                                  bottom: 4,
                                                  child: Container(
                                                    width: 6,
                                                    height: 6,
                                                    decoration: BoxDecoration(
                                                      color: Colors.orange,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    todayBuilder: (context, date, _) {
                                      final hasEntry =
                                          _getEntry(date).isNotEmpty;

                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedDay = date;
                                            _focusedDay = date;
                                            _controller.text = _getEntry(date);
                                          });
                                          if (hasEntry) {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text(
                                                  'Diary Entry for ${DateFormat.yMMMd().format(date)}',
                                                  style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                                content: SingleChildScrollView(
                                                  child: Text(
                                                    _getEntry(date),
                                                    style:
                                                        GoogleFonts.poppins(),
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .pop(),
                                                    child: const Text('Close'),
                                                  )
                                                ],
                                              ),
                                            );
                                          }
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.teal.shade100,
                                            border: Border.all(
                                                color: Colors.teal.shade700,
                                                width: 1.5),
                                          ),
                                          alignment: Alignment.center,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Text(
                                                '${date.day}',
                                                style: GoogleFonts.poppins(
                                                  color: hasEntry
                                                      ? Colors.orange.shade900
                                                      : Colors.teal.shade900,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              if (hasEntry)
                                                Positioned(
                                                  bottom: 4,
                                                  child: Container(
                                                    width: 6,
                                                    height: 6,
                                                    decoration: BoxDecoration(
                                                      color: Colors.orange,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 18),
                            _diaryEntryWidget(),
                          ],
                        ),
                ),
              ),
            ],
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
        boxShadow: [BoxShadow(color: color, blurRadius: 40, spreadRadius: 8)],
      ),
    );
  }
}
