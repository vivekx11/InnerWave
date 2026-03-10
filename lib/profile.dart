import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'stress_page.dart';
import 'user_insights.dart';

class ProfilePage extends StatefulWidget {
  final List<MoodEntry> moodEntries;

  const ProfilePage({Key? key, required this.moodEntries}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic> todayStats = {};
  Map<String, dynamic> totalStats = {};
  List<Map<String, dynamic>> weeklyStats = [];
  Map<String, dynamic> monthlyStats = {};
  List<Map<String, dynamic>> sessionHistory = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadUserInsights();
  }

  Future<void> _loadUserInsights() async {
    setState(() => isLoading = true);

    try {
      final today = await UserInsights.getTodayStats();
      final total = await UserInsights.getTotalStats();
      final weekly = await UserInsights.getWeeklyStats();
      final monthly = await UserInsights.getMonthlyStats();
      final history = await UserInsights.getSessionHistory();

      print('Today Stats: $today');
      print('Total Stats: $total');
      print('Session History: ${history.length} sessions');

      setState(() {
        todayStats = today;
        totalStats = total;
        weeklyStats = weekly;
        monthlyStats = monthly;
        sessionHistory = history;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading insights: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate quick stats....
    int totalSessions = sessionHistory.length;
    int totalMinutes = sessionHistory.fold<int>(
      0,
      (sum, session) => sum + ((session['duration'] as int) ~/ 60),
    );

    return SafeArea(
      child: Column(
        children: [
          // Clean Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Progress',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0E0F14),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Track your meditation journey',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF7ADCB8).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: _loadUserInsights,
                    icon: const Icon(Icons.refresh_rounded),
                    color: const Color(0xFF7ADCB8),
                    iconSize: 24,
                  ),
                ),
              ],
            ),
          ),

          // Quick Stats Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: _buildQuickStatCard(
                    icon: Icons.check_circle_outline,
                    value: totalSessions.toString(),
                    label: 'Sessions',
                    color: const Color(0xFF8A88FF),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickStatCard(
                    icon: Icons.access_time,
                    value: '${totalMinutes}m',
                    label: 'Total Time',
                    color: const Color(0xFF7ADCB8),
                  ),
                ),
              ],
            ),
          ),

          // Simple Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              labelColor: const Color(0xFF0E0F14),
              unselectedLabelColor: Colors.grey[600],
              labelStyle: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Today'),
                Tab(text: 'History'),
                Tab(text: 'Weekly'),
                Tab(text: 'All Time'),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTodayView(),
                _buildHistoryView(),
                _buildWeeklyView(),
                _buildAllTimeView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0E0F14),
                ),
              ),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodayView() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF7ADCB8),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (todayStats.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.self_improvement_outlined,
                      size: 50,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No activities today',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0E0F14),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start your meditation journey now',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          else
            ...todayStats.entries.map((entry) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _getActivityColor(entry.key).withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _getActivityColor(entry.key).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getActivityIcon(entry.key),
                          color: _getActivityColor(entry.key),
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.key,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF0E0F14),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${entry.value['sessionCount']} ${entry.value['sessionCount'] == 1 ? 'session' : 'sessions'}',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _getActivityColor(entry.key).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          UserInsights.formatDuration(entry.value['totalTime']),
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: _getActivityColor(entry.key),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildHistoryView() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (sessionHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF8A88FF).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history,
                size: 60,
                color: const Color(0xFF8A88FF).withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No session history yet',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0E0F14),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start using the app to see your history',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    // Group sessions by date
    Map<String, List<Map<String, dynamic>>> groupedSessions = {};
    for (var session in sessionHistory) {
      final date = session['timestamp'] as DateTime;
      final dateKey = DateFormat.yMMMd().format(date);
      
      if (!groupedSessions.containsKey(dateKey)) {
        groupedSessions[dateKey] = [];
      }
      groupedSessions[dateKey]!.add(session);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6B6B).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      sessionHistory.length.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Total Sessions',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 2,
                  height: 50,
                  color: Colors.white.withOpacity(0.3),
                ),
                Column(
                  children: [
                    Text(
                      UserInsights.formatDuration(
                        sessionHistory.fold<int>(
                          0,
                          (sum, session) => sum + (session['duration'] as int),
                        ),
                      ),
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Total Time',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Session History by Date
          Text(
            'Session History',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0E0F14),
            ),
          ),
          const SizedBox(height: 16),

          ...groupedSessions.entries.map((dateGroup) {
            final dateKey = dateGroup.key;
            final sessions = dateGroup.value;
            final totalDayTime = sessions.fold<int>(
              0,
              (sum, session) => sum + (session['duration'] as int),
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Header
                Container(
                  margin: const EdgeInsets.only(bottom: 12, top: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8A88FF), Color(0xFF7ADCB8)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        dateKey,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${sessions.length} sessions • ${UserInsights.formatDuration(totalDayTime)}',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Sessions for this date
                ...sessions.map((session) {
                  final timestamp = session['timestamp'] as DateTime;
                  final activity = session['activity'] as String;
                  final duration = session['duration'] as int;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _getActivityColor(activity).withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _getActivityColor(activity).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getActivityIcon(activity),
                            color: _getActivityColor(activity),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activity,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF0E0F14),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat.jm().format(timestamp),
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getActivityColor(activity).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            UserInsights.formatDuration(duration),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _getActivityColor(activity),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 8),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildWeeklyView() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weekly Chart
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekly Activity',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0E0F14),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: weeklyStats.isEmpty
                          ? 10
                          : (weeklyStats
                                          .map((e) => e['totalTime'] as int)
                                          .reduce((a, b) => a > b ? a : b) /
                                      60)
                                  .ceilToDouble() +
                              5,
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: const Color(0xFF7ADCB8),
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final day = weeklyStats[group.x.toInt()];
                            return BarTooltipItem(
                              '${DateFormat.E().format(day['date'])}\n${UserInsights.formatDuration(day['totalTime'])}',
                              const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() < weeklyStats.length) {
                                final day = weeklyStats[value.toInt()];
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    DateFormat.E()
                                        .format(day['date'])
                                        .substring(0, 3),
                                    style: GoogleFonts.poppins(fontSize: 10),
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toInt()}m',
                                style: GoogleFonts.poppins(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: weeklyStats.asMap().entries.map((entry) {
                        final index = entry.key;
                        final day = entry.value;
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: (day['totalTime'] as int) / 60.0,
                              color: const Color(0xFF7ADCB8),
                              width: 12,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Weekly Summary
          Text(
            'Weekly Summary',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0E0F14),
            ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF691C7), Color(0xFFFFD166)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Time',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      UserInsights.formatDuration(weeklyStats.fold<int>(
                          0, (sum, day) => sum + (day['totalTime'] as int))),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Active Days',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${weeklyStats.where((day) => (day['totalTime'] as int) > 0).length}/7',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllTimeView() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // All Time Stats Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.0,
            children: [
              _buildStatCard(
                'Total Sessions',
                totalStats.entries
                    .fold<int>(
                        0,
                        (sum, entry) =>
                            sum + (entry.value['sessionCount'] as int))
                    .toString(),
                Icons.timer,
                const Color(0xFF8A88FF),
              ),
              _buildStatCard(
                'Total Time',
                UserInsights.formatDuration(totalStats.entries.fold<int>(0,
                    (sum, entry) => sum + (entry.value['totalTime'] as int))),
                Icons.schedule,
                const Color(0xFF7ADCB8),
              ),
              _buildStatCard(
                'Activities',
                totalStats.length.toString(),
                Icons.category,
                const Color(0xFFF691C7),
              ),
              _buildStatCard(
                'Monthly Time',
                UserInsights.formatDuration(
                    monthlyStats['totalMonthlyTime'] ?? 0),
                Icons.calendar_month,
                const Color(0xFFFFD166),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // All Activities Breakdown
          Text(
            'All Activities',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0E0F14),
            ),
          ),
          const SizedBox(height: 16),

          if (totalStats.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  'No activities recorded yet',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            )
          else
            ...totalStats.entries.map((entry) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color:
                                  _getActivityColor(entry.key).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getActivityIcon(entry.key),
                              color: _getActivityColor(entry.key),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              entry.key,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF0E0F14),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Time',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                UserInsights.formatDuration(
                                    entry.value['totalTime']),
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: _getActivityColor(entry.key),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Sessions',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                entry.value['sessionCount'].toString(),
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: _getActivityColor(entry.key),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getActivityColor(String activity) {
    switch (activity.toLowerCase()) {
      case 'meditation':
        return const Color(0xFF8A88FF);
      case 'focus':
        return const Color(0xFFF691C7);
      case 'sleep':
        return const Color(0xFF7ADCB8);
      case 'stress relief':
        return const Color(0xFFFFD166);
      case 'calm':
        return const Color(0xFFB08CFF);
      case 'guided':
        return const Color(0xFF5B7CFA);
      case 'focus mode':
        return const Color(0xFF4CAF50);
      case 'assistant':
        return const Color(0xFFFF6B6B);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  IconData _getActivityIcon(String activity) {
    switch (activity.toLowerCase()) {
      case 'meditation':
        return Icons.self_improvement;
      case 'focus':
        return Icons.psychology;
      case 'sleep':
        return Icons.bedtime;
      case 'stress relief':
        return Icons.spa;
      case 'calm':
        return Icons.air;
      case 'guided':
        return Icons.headphones;
      case 'focus mode':
        return Icons.timer;
      case 'assistant':
        return Icons.chat;
      default:
        return Icons.circle;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
