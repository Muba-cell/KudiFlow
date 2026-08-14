import 'package:flutter/material.dart';

enum NotificationSeverity { info, warning, critical }

class AppNotification {
  final String title;
  final String message;
  final IconData icon;
  final NotificationSeverity severity;

  AppNotification({
    required this.title,
    required this.message,
    required this.icon,
    required this.severity,
  });

  Color get color {
    switch (severity) {
      case NotificationSeverity.critical:
        return Colors.red;
      case NotificationSeverity.warning:
        return Colors.orange;
      case NotificationSeverity.info:
        return Colors.green;
    }
  }
}
