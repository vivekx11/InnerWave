import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'profile.dart';
import 'mood_chart.dart';

class StressPage extends StatefulWidget {
  const StressPage({Key? key}) : super(key: key);

  @override
  State<StressPage> createState() => _StressPageState();
}

class _StressPageState extends State<StressPage> {
  final List<Map<String, dynamic>> _moods = [
    {'emoji': '😄', 'label': 'Happy', 'color': Colors.green},
    {'emoji': '🙂', 'label': 'Content', 'color': Colors.lightGreen},
    {'emoji': '😐', 'label': 'Neutral', 'color': Colors.amber},
    {'emoji': '😟', 'label': 'Anxious', 'color': Colors.orange},
    {'emoji': '😢', 'label': 'Sad', 'color': Colors.red},
    {'emoji': '😡', 'label': 'Angry', 'color': Colors.deepOrange},
  ];

  String? _selectedMoodEmoji;
  String _customMoodLabel = '';
  List<MoodEntry> _moodEntries = [];
  final _customMoodController = TextEditingController();
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _loadMoodEntries();
  }

  @override
  void dispose() {
    _customMoodController.dispose();
    super.dispose();
  }

  Future<void> _loadMoodEntries() async {
    _prefs = await SharedPreferences.getInstance();
    final stored = _prefs.getString('mood_entries');
    if (stored != null) {
      final List<dynamic> decoded = jsonDecode(stored);
      setState(() {
        _moodEntries = decoded.map((e) => MoodEntry.fromJson(e)).toList();
      });
    }
  }

  Future<void> _saveMoodEntries() async {
    final String encoded =
        jsonEncode(_moodEntries.map((e) => e.toJson()).toList());
    await _prefs.setString('mood_entries', encoded);
  }

  int get _streak {
    if (_moodEntries.isEmpty) return 0;
    int streak = 0;
    DateTime today = DateTime.now().toUtc();
    DateTime current = DateTime(today.year, today.month, today.day);
    for (var e in _moodEntries) {
      final d = DateTime(e.timestamp.year, e.timestamp.month, e.timestamp.day);
      if (d == current) {
        streak++;
        current = current.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  void _selectMood(String emoji, String label) {
    setState(() {
      _selectedMoodEmoji = emoji;
      _customMoodLabel = label;
    });
  }

  void _addMoodEntry() {
    if (_selectedMoodEmoji == null || _customMoodLabel.isEmpty) return;
    final entry = MoodEntry(
      emoji: _selectedMoodEmoji!,
      label: _customMoodLabel,
      timestamp: DateTime.now().toUtc(),
    );
    setState(() {
      _moodEntries.insert(0, entry);
      _selectedMoodEmoji = null;
      _customMoodLabel = '';
    });
    _saveMoodEntries();
  }

  Future<void> _showCustomMoodSheet(BuildContext context) async {
    _customMoodController.clear();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Enter Custom Mood",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _customMoodController,
              decoration: InputDecoration(
                hintText: "e.g., Excited, Bored...",
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              autofocus: true,
              onSubmitted: (_) => _submitCustomMood(ctx),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () => _submitCustomMood(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child:
                  const Text("Add Mood", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _submitCustomMood(BuildContext ctx) {
    if (_customMoodController.text.trim().isEmpty) return;
    setState(() {
      _selectedMoodEmoji = '📝';
      _customMoodLabel = _customMoodController.text.trim();
    });
    Navigator.pop(ctx);
  }

  void _goToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfilePage(moodEntries: _moodEntries),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Mood Entry'),
            content:
                const Text('Are you sure you want to delete this mood entry?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child:
                    const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stress Tracker"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: _goToProfile,
          ),
        ],
      ),
      body: SizedBox.expand(
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.teal.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.teal.shade200),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.local_fire_department,
                                    color: Colors.redAccent, size: 22),
                                const SizedBox(width: 6),
                                Text(
                                  "Streak: $_streak",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.teal.shade800,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "How are you feeling today?",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 95,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _moods.length + 1,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            if (index < _moods.length) {
                              final mood = _moods[index];
                              return GestureDetector(
                                onTap: () =>
                                    _selectMood(mood['emoji'], mood['label']),
                                child: MoodCard(
                                  emoji: mood['emoji'],
                                  label: mood['label'],
                                  selected: _selectedMoodEmoji == mood['emoji'],
                                  accentColor: mood['color'],
                                ),
                              );
                            }
                            return GestureDetector(
                              onTap: () => _showCustomMoodSheet(context),
                              child: Container(
                                width: 80,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child:
                                    const Icon(Icons.edit, color: Colors.teal),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed:
                            (_selectedMoodEmoji != null) ? _addMoodEntry : null,
                        icon: const Icon(Icons.add_circle_outline,
                            color: Colors.white),
                        label: const Text("Log Mood",
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 28, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: _buildHistorySection(),
                      ),
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

  Widget _buildHistorySection() {
    if (_moodEntries.isEmpty) {
      return const Center(
        child: Text(
          'No mood entries yet.\nLog your mood to view your mood history.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mood History',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: _moodEntries.length,
            itemBuilder: (context, idx) {
              final e = _moodEntries[idx];
              return Dismissible(
                key: Key(e.timestamp.toIso8601String()),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                secondaryBackground: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  return await _confirmDelete(context);
                },
                onDismissed: (direction) {
                  setState(() {
                    _moodEntries.removeAt(idx);
                  });
                  _saveMoodEntries();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${e.label} entry deleted')),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal.shade100,
                      child:
                          Text(e.emoji, style: const TextStyle(fontSize: 20)),
                    ),
                    title: Text(
                      e.label,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      DateFormat.yMMMd().add_jm().format(e.timestamp),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Mood Chart (Past 7 Days)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 160,
          child: MoodLineChart(moodEntries: _moodEntries),
        ),
      ],
    );
  }
}

class MoodEntry {
  final String emoji;
  final String label;
  final DateTime timestamp;

  MoodEntry({
    required this.emoji,
    required this.label,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'emoji': emoji,
        'label': label,
        'timestamp': timestamp.toIso8601String(),
      };

  factory MoodEntry.fromJson(Map<String, dynamic> json) => MoodEntry(
        emoji: json['emoji'],
        label: json['label'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}

class MoodCard extends StatelessWidget {
  final String emoji;
  final String label;
  final bool selected;
  final Color accentColor;

  const MoodCard({
    Key? key,
    required this.emoji,
    required this.label,
    required this.selected,
    required this.accentColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: selected ? accentColor.withOpacity(0.3) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: selected ? accentColor : Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: selected ? accentColor : Colors.grey.shade800,
            ),
          ),
        ],
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
