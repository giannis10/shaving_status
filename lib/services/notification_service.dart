import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import '../models/models.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.requestNotificationsPermission();
    await androidImplementation?.requestExactAlarmsPermission();
  }

  Future<void> scheduleShaveReminder({
    required Zone zone,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final int notificationId = zone.id.hashCode;

    // Calculate when the notification should fire
    final now = DateTime.now();
    
    // We schedule it at the specific hour and minute on the target day.
    var scheduledDate = now.add(Duration(days: zone.maxDaysThreshold));
    scheduledDate = DateTime(scheduledDate.year, scheduledDate.month, scheduledDate.day, hour, minute);

    // If somehow it's in the past, add a day
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final tz.TZDateTime tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'shaving_reminders',
      'Shaving Reminders',
      channelDescription: 'Notifications for when it is time to shave',
      importance: Importance.max,
      priority: Priority.high,
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    debugPrint('Scheduling notification ID \$notificationId for \$tzScheduledDate');

    await _notificationsPlugin.zonedSchedule(
      notificationId,
      title,
      body,
      tzScheduledDate,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelReminder(String zoneId) async {
    await _notificationsPlugin.cancel(zoneId.hashCode);
  }
}
