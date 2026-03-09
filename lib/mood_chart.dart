// mood_chart.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'stress_page.dart'; // Import to access MoodEntry class

class MoodLineChart extends StatelessWidget {
  final List<MoodEntry> moodEntries;

  const MoodLineChart({Key? key, required this.moodEntries}) : super(key: key);

  List<FlSpot> get _weeklyMoodSpots {
    final moodScores = {
      'Happy': 5.0,
      'Content': 4.0,
      'Neutral': 3.0,
      'Anxious': 2.0,
      'Sad': 1.0,
      'Angry': 0.0,
    };
    DateTime today = DateTime.now().toUtc();
    List<FlSpot> spots = [];
    for (int i = 6; i >= 0; i--) {
      final d = today.subtract(Duration(days: i));
      final entries = moodEntries.where((e) =>
          e.timestamp.year == d.year &&
          e.timestamp.month == d.month &&
          e.timestamp.day == d.day);
      double y = entries.isEmpty
          ? 3.0
          : entries
                  .map((e) => moodScores[e.label] ?? 3.0)
                  .reduce((a, b) => a + b) /
              entries.length;
      spots.add(FlSpot(6 - i.toDouble(), y));
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    final spots = _weeklyMoodSpots;
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 5,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, _) => Text(
                [
                  'Angry',
                  'Sad',
                  'Anxious',
                  'Neutral',
                  'Content',
                  'Happy'
                ][value.toInt()],
                style: const TextStyle(fontSize: 9, color: Colors.teal),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final today = DateTime.now().toUtc();
                final weekday =
                    today.subtract(Duration(days: 6 - value.toInt()));
                return Text(
                  DateFormat.E().format(weekday),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.teal,
            barWidth: 3,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.teal.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }
}
