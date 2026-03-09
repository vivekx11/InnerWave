import 'package:hive_flutter/hive_flutter.dart';

class UserInsights {
  static const String _boxName = 'userInsights';

  static Future<void> recordActivity(
      String activity, int durationInSeconds) async {
    final box = await Hive.openBox(_boxName);
    final today = DateTime.now();
    final todayKey = _formatDateKey(today);

    print('Recording activity: $activity for $durationInSeconds seconds');
    print('Date key: $todayKey');

    // Get today's activities
    final todayActivities = box.get(todayKey, defaultValue: <dynamic>[]);
    print('Current activities for today: ${todayActivities.length}');

    // Add new activity
    todayActivities.add({
      'activity': activity,
      'duration': durationInSeconds,
      'timestamp': today.toIso8601String(),
    });

    await box.put(todayKey, todayActivities);
    print('Activity saved. Total activities now: ${todayActivities.length}');

    // Update total stats
    await _updateTotalStats(activity, durationInSeconds);
  }

  static Future<void> _updateTotalStats(
      String activity, int durationInSeconds) async {
    final box = await Hive.openBox(_boxName);
    final stats = box.get('totalStats', defaultValue: <dynamic, dynamic>{});

    if (stats[activity] == null) {
      stats[activity] = {
        'totalTime': 0,
        'sessionCount': 0,
        'firstSession': DateTime.now().toIso8601String(),
      };
    }

    stats[activity]['totalTime'] += durationInSeconds;
    stats[activity]['sessionCount'] += 1;
    stats[activity]['lastSession'] = DateTime.now().toIso8601String();

    await box.put('totalStats', stats);
  }

  static Future<Map<String, dynamic>> getTodayStats() async {
    final box = await Hive.openBox(_boxName);
    final today = DateTime.now();
    final todayKey = _formatDateKey(today);

    final todayActivities = box.get(todayKey, defaultValue: <dynamic>[]);
    final stats = <String, dynamic>{};

    for (final activity in todayActivities) {
      final activityName = activity['activity'];
      if (stats[activityName] == null) {
        stats[activityName] = {
          'totalTime': 0,
          'sessionCount': 0,
        };
      }
      stats[activityName]['totalTime'] += (activity['duration'] as int);
      stats[activityName]['sessionCount'] += 1;
    }

    return stats;
  }

  static Future<Map<String, dynamic>> getTotalStats() async {
    final box = await Hive.openBox(_boxName);
    return box.get('totalStats', defaultValue: <dynamic, dynamic>{});
  }

  static Future<List<Map<String, dynamic>>> getWeeklyStats() async {
    final box = await Hive.openBox(_boxName);
    final now = DateTime.now();
    final weeklyStats = <Map<String, dynamic>>[];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = _formatDateKey(date);
      final dayActivities = box.get(dateKey, defaultValue: <dynamic>[]);

      int totalTime = 0;
      final activityBreakdown = <String, int>{};

      for (final activity in dayActivities) {
        totalTime += (activity['duration'] as int);
        final activityName = activity['activity'];
        activityBreakdown[activityName] =
            (activityBreakdown[activityName] ?? 0) +
                (activity['duration'] as int);
      }

      weeklyStats.add({
        'date': date,
        'totalTime': totalTime,
        'activities': activityBreakdown,
      });
    }

    return weeklyStats;
  }

  static Future<Map<String, dynamic>> getMonthlyStats() async {
    final box = await Hive.openBox(_boxName);
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);
    final nextMonth = DateTime(now.year, now.month + 1, 1);

    final monthlyStats = <String, int>{};
    int totalMonthlyTime = 0;

    // Iterate through all keys in the box
    for (final key in box.keys) {
      if (key.toString().length == 8) {
        // Date key format: YYYYMMDD
        try {
          final keyDate = DateTime.parse(
              '${key.toString().substring(0, 4)}-${key.toString().substring(4, 6)}-${key.toString().substring(6, 8)}');
          if (keyDate.isAfter(currentMonth.subtract(const Duration(days: 1))) &&
              keyDate.isBefore(nextMonth)) {
            final dayActivities = box.get(key, defaultValue: <dynamic>[]);
            for (final activity in dayActivities) {
              final activityName = activity['activity'];
              monthlyStats[activityName] = (monthlyStats[activityName] ?? 0) +
                  (activity['duration'] as int);
              totalMonthlyTime += (activity['duration'] as int);
            }
          }
        } catch (e) {
          // Skip invalid date keys
        }
      }
    }

    return {
      'monthlyStats': monthlyStats,
      'totalMonthlyTime': totalMonthlyTime,
    };
  }

  static Future<List<Map<String, dynamic>>> getSessionHistory() async {
    final box = await Hive.openBox(_boxName);
    final allSessions = <Map<String, dynamic>>[];

    // Get all date keys and sort them
    final dateKeys = box.keys
        .where((key) => key.toString().length == 8)
        .toList()
      ..sort((a, b) => b.toString().compareTo(a.toString()));

    for (final key in dateKeys) {
      final dayActivities = box.get(key, defaultValue: <dynamic>[]);
      for (final activity in dayActivities) {
        allSessions.add({
          'activity': activity['activity'],
          'duration': activity['duration'],
          'timestamp': DateTime.parse(activity['timestamp']),
        });
      }
    }

    // Sort by timestamp descending (newest first)
    allSessions.sort((a, b) => (b['timestamp'] as DateTime)
        .compareTo(a['timestamp'] as DateTime));

    return allSessions;
  }

  static Future<Map<String, dynamic>> getDailyHistory() async {
    final box = await Hive.openBox(_boxName);
    final dailyHistory = <String, List<Map<String, dynamic>>>{};

    // Get all date keys and sort them
    final dateKeys = box.keys
        .where((key) => key.toString().length == 8)
        .toList()
      ..sort((a, b) => b.toString().compareTo(a.toString()));

    for (final key in dateKeys) {
      final dayActivities = box.get(key, defaultValue: <dynamic>[]);
      final dateStr = _formatDateKey(DateTime.parse(
          '${key.toString().substring(0, 4)}-${key.toString().substring(4, 6)}-${key.toString().substring(6, 8)}'));
      
      dailyHistory[dateStr] = [];
      for (final activity in dayActivities) {
        dailyHistory[dateStr]!.add({
          'activity': activity['activity'],
          'duration': activity['duration'],
          'timestamp': DateTime.parse(activity['timestamp']),
        });
      }
    }

    return dailyHistory;
  }

  static String _formatDateKey(DateTime date) {
    return '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
  }

  static String formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  static Future<void> clearAllData() async {
    final box = await Hive.openBox(_boxName);
    await box.clear();
  }
}
