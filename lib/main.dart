import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'appointment_form.dart';
import 'appointment_list.dart';
import 'database_helper.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> onSelectNotification(String? payload) async {
  if (payload != null) {
    final dbHelper = DatabaseHelper();
    final appointment = await dbHelper.getAppointmentById(payload);
    if (appointment != null) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => AppointmentForm(
            appointment: appointment,
            onSave: (updatedAppointment) async {
              await dbHelper.insertAppointment(updatedAppointment);
              // Có thể thêm logic cập nhật UI tại đây nếu cần
            },
            userId: appointment.userId,
          ),
        ),
      );
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings =
      const InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
    onSelectNotification(response.payload);
  });

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: AppointmentList(userId: 'user_id_here'),
    );
  }
}
