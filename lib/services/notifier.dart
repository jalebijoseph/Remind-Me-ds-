import 'package:flutter/material.dart';
import '../globals.dart';

/// Web-safe "notifier". Schedules are no-op on web but we still show in-app banners.
class Notifier {
  static Future<void> init() async {}

  static Future<void> scheduleOnce({
    required String id,
    required DateTime when,
    required String title,
    String? body,
  }) async {
    // no-op on web; ReminderWatcher uses timers for in-app pings
  }

  /// Show a non-blocking banner in-app.
  static void inApp(String message) {
    final s = scaffoldMessengerKey.currentState;
    s?.showSnackBar(SnackBar(content: Text(message)));
  }
}
