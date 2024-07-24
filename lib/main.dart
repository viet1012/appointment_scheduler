import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'appointment_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final userId = await getUserId();
  runApp(MyApp(userId: userId));
}

Future<String> getUserId() async {
  final prefs = await SharedPreferences.getInstance();
  String? userId = prefs.getString('userId');

  if (userId == null) {
    userId = Uuid().v4(); // Tạo userId mới nếu chưa có
    await prefs.setString('userId', userId);
  }

  return userId;
}

class MyApp extends StatelessWidget {
  final String userId;

  MyApp({required this.userId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AppointmentList(userId: userId),
    );
  }
}
