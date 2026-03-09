import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class DailyDiaryPage extends StatefulWidget {
  const DailyDiaryPage({super.key});

  @override
  State<DailyDiaryPage> createState() => _DailyDiaryPageState();
}

class _DailyDiaryPageState extends State<DailyDiaryPage> {
  final TextEditingController _noteController = TextEditingController();
  final List<DiaryEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final box = await Hive.openBox('diaryBox');
    final entries = box.get('entries', defaultValue: <dynamic>[]);

    setState(() {
      _entries.clear();
      for (final entry in entries) {
        _entries.add(DiaryEntry(
          id: entry['id'],
          title: entry['title'],
          content: entry['content'],
          timestamp: DateTime.parse(entry['timestamp']),
          mood: entry['mood'],
        ));
      }
      _entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    });
  }

  Future<void> _saveEntry() async {
    if (_noteController.text.trim().isEmpty) return;

    final entry = DiaryEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Entry ${_entries.length + 1}',
      content: _noteController.text.trim(),
      timestamp: DateTime.now(),
      mood: 'neutral', // You can expand this with mood selection
    );

    final box = await Hive.openBox('diaryBox');
    final entries = box.get('entries', defaultValue: <dynamic>[]);
    entries.add({
      'id': entry.id,
      'title': entry.title,
      'content': entry.content,
      'timestamp': entry.timestamp.toIso8601String(),
      'mood': entry.mood,
    });
    await box.put('entries', entries);

    setState(() {
      _entries.insert(0, entry);
    });

    _noteController.clear();
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Entry saved successfully!'),
        backgroundColor: const Color(0xFF7ADCB8),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _deleteEntry(String id) async {
    final box = await Hive.openBox('diaryBox');
    final entries = box.get('entries', defaultValue: <dynamic>[]);
    entries.removeWhere((entry) => entry['id'] == id);
    await box.put('entries', entries);

    setState(() {
      _entries.removeWhere((entry) => entry.id == id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Entry deleted'),
        backgroundColor: const Color(0xFFFF6B6B),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAddEntryDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFFE6F3FF), Color(0xFFFFF1DB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'New Diary Entry',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0E0F14),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _noteController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Write your thoughts...',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      _noteController.clear();
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _saveEntry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7ADCB8),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Save',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
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

  @override
  Widget build(BuildContext context) {
    // Group entries by date
    Map<String, List<DiaryEntry>> groupedEntries = {};
    for (var entry in _entries) {
      String dateKey = DateFormat.yMMMd().format(entry.timestamp);
      if (!groupedEntries.containsKey(dateKey)) {
        groupedEntries[dateKey] = [];
      }
      groupedEntries[dateKey]!.add(entry);
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Diary',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0E0F14),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_entries.length} entries',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF0E0F14).withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7ADCB8), Color(0xFF5B7CFA)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7ADCB8).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _showAddEntryDialog,
                      borderRadius: BorderRadius.circular(16),
                      child: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Icon(Icons.add, color: Colors.white, size: 28),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Record your thoughts and feelings',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: const Color(0xFF0E0F14).withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),

            // Entries List
            Expanded(
              child: _entries.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: const Color(0xFF7ADCB8).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.book_outlined,
                              size: 60,
                              color: const Color(0xFF7ADCB8).withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'No entries yet',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0E0F14),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap the + button to add your first entry',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: groupedEntries.length,
                      itemBuilder: (context, index) {
                        String dateKey = groupedEntries.keys.elementAt(index);
                        List<DiaryEntry> dayEntries = groupedEntries[dateKey]!;
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date Header
                            Padding(
                              padding: const EdgeInsets.only(left: 8, bottom: 12, top: 8),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF8A88FF), Color(0xFF7ADCB8)],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      dateKey,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${dayEntries.length} ${dayEntries.length == 1 ? 'entry' : 'entries'}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Entries for this date
                            ...dayEntries.map((entry) => Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFF7ADCB8).withOpacity(0.2),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _showEntryDetails(entry),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF7ADCB8).withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Icon(
                                                Icons.edit_note,
                                                color: const Color(0xFF7ADCB8),
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    entry.title,
                                                    style: GoogleFonts.poppins(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                      color: const Color(0xFF0E0F14),
                                                    ),
                                                  ),
                                                  Text(
                                                    DateFormat.jm().format(entry.timestamp),
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            PopupMenuButton(
                                              icon: Icon(Icons.more_vert,
                                                  color: Colors.grey[600], size: 20),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              itemBuilder: (context) => [
                                                PopupMenuItem(
                                                  value: 'delete',
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.delete,
                                                          color: Colors.red[400], size: 20),
                                                      const SizedBox(width: 8),
                                                      Text('Delete',
                                                          style: GoogleFonts.poppins()),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                              onSelected: (value) {
                                                if (value == 'delete') {
                                                  _deleteEntry(entry.id);
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          entry.content,
                                          style: GoogleFonts.poppins(
                                            color: const Color(0xFF0E0F14)
                                                .withOpacity(0.7),
                                            height: 1.5,
                                            fontSize: 14,
                                          ),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEntryDetails(DiaryEntry entry) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFFE6F3FF), Color(0xFFFFF1DB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.title,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0E0F14),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat.yMMMd().add_jm().format(entry.timestamp),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                entry.content,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: const Color(0xFF0E0F14),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Close',
                    style: GoogleFonts.poppins(color: const Color(0xFF7ADCB8)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }
}

class DiaryEntry {
  final String id;
  final String title;
  final String content;
  final DateTime timestamp;
  final String mood;

  DiaryEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.timestamp,
    required this.mood,
  });
}
