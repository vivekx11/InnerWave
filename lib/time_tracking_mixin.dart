import 'dart:async';
import 'package:flutter/material.dart';
import 'user_insights.dart';

mixin TimeTrackingMixin<T extends StatefulWidget> on State<T> {
  Timer? _trackingTimer;
  DateTime? _sessionStartTime;
  String _activityName = '';

  void startTimeTracking(String activityName) {
    _activityName = activityName;
    _sessionStartTime = DateTime.now();

    // Record activity every minute
    _trackingTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      // Periodic tracking - actual recording happens when session ends
    });
  }

  Future<void> stopTimeTracking() async {
    if (_sessionStartTime != null && _trackingTimer != null) {
      _trackingTimer?.cancel();

      final duration = DateTime.now().difference(_sessionStartTime!).inSeconds;
      if (duration > 0) {
        await UserInsights.recordActivity(_activityName, duration);
      }

      _sessionStartTime = null;
      _trackingTimer = null;
    }
  }

  @override
  void dispose() {
    _trackingTimer?.cancel();
    super.dispose();
  }
}

class TimeTrackingWidget extends StatefulWidget {
  final Widget child;
  final String activityName;
  final bool isTracking;

  const TimeTrackingWidget({
    Key? key,
    required this.child,
    required this.activityName,
    this.isTracking = false,
  }) : super(key: key);

  @override
  State<TimeTrackingWidget> createState() => _TimeTrackingWidgetState();
}

class _TimeTrackingWidgetState extends State<TimeTrackingWidget> {
  DateTime? _sessionStartTime;
  Timer? _trackingTimer;

  @override
  void didUpdateWidget(TimeTrackingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isTracking && !oldWidget.isTracking) {
      _startTracking();
    } else if (!widget.isTracking && oldWidget.isTracking) {
      _stopTracking();
    }
  }

  void _startTracking() {
    _sessionStartTime = DateTime.now();
    _trackingTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      // Update UI or perform periodic tasks if needed
    });
  }

  Future<void> _stopTracking() async {
    if (_sessionStartTime != null && _trackingTimer != null) {
      _trackingTimer?.cancel();

      final duration = DateTime.now().difference(_sessionStartTime!).inSeconds;
      if (duration > 0) {
        await UserInsights.recordActivity(widget.activityName, duration);
      }

      _sessionStartTime = null;
      _trackingTimer = null;
    }
  }

  @override
  void dispose() {
    _trackingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
