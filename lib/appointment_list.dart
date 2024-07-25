import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

import 'appointment_form.dart';
import 'appointment_model.dart';
import 'database_helper.dart';
import 'main.dart';

class AppointmentList extends StatefulWidget {
  final String userId;

  AppointmentList({required this.userId});

  @override
  _AppointmentListState createState() => _AppointmentListState();
}

class _AppointmentListState extends State<AppointmentList> {
  List<Appointment> _appointments = [];

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  void _fetchAppointments() async {
    final dbHelper = DatabaseHelper();
    final appointments = await dbHelper.getAppointments(userId: widget.userId);
    setState(() {
      _appointments = appointments;
    });
  }

  Future<void> _scheduleNotification(Appointment appointment) async {
    final scheduledNotificationDateTime = DateTime(
      appointment.date.year,
      appointment.date.month,
      appointment.date.day,
      appointment.startTime.hour,
      appointment.startTime.minute,
    );

    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'appointment_reminders_channel',
      'Appointment Reminders',
      channelDescription: 'Notifications for appointment reminders',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.schedule(
      appointment.id.hashCode,
      'Appointment Reminder',
      'You have an appointment: ${appointment.note}',
      scheduledNotificationDateTime,
      platformChannelSpecifics,
      payload: appointment.id,
    );
  }

  void _addAppointment(Appointment appointment) async {
    final dbHelper = DatabaseHelper();
    await dbHelper.insertAppointment(appointment);
    _scheduleNotification(appointment);
    _fetchAppointments();
  }

  void _editAppointment(Appointment updatedAppointment) async {
    final dbHelper = DatabaseHelper();
    await dbHelper.insertAppointment(updatedAppointment);
    _scheduleNotification(updatedAppointment);
    _fetchAppointments();
  }

  void _deleteAppointment(String id) async {
    final dbHelper = DatabaseHelper();
    await dbHelper.deleteAppointment(id);
    _fetchAppointments();
  }

  Future<bool?> _confirmDeleteAppointment(String id, String note) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            "Xác nhận xóa",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Bạn có chắc chắn muốn xóa lịch hẹn "$note"?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Hủy'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  void _showForm({Appointment? appointment}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AppointmentForm(
          appointment: appointment,
          onSave: appointment == null ? _addAppointment : _editAppointment,
          userId: widget.userId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/Vicon.webp',
              height: 30,
            ),
            SizedBox(width: 10),
            const Text(
              'Danh sách lịch hẹn',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.white,
              ),
            ),
            // Spacer(),
            // IconButton(
            //   icon: Icon(Icons.account_circle),
            //   onPressed: () {
            //     // Hành động khi nhấn vào biểu tượng người dùng
            //   },
            // ),
          ],
        ),
        centerTitle: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 10,
        shadowColor: Colors.black.withOpacity(0.5),
      ),
      body: ListView.builder(
        itemCount: _appointments.length,
        itemBuilder: (context, index) {
          final appointment = _appointments[index];
          final note = appointment.note ?? 'No note';
          final DateFormat formatter = DateFormat('dd/MM/yyyy');
          final formattedDate = formatter.format(appointment.date);

          return Dismissible(
            key: Key(appointment.id),
            direction: DismissDirection.horizontal,
            confirmDismiss: (direction) async {
              final bool? confirm =
                  await _confirmDeleteAppointment(appointment.id, note);
              if (confirm == true) {
                _deleteAppointment(appointment.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$note đã bị xóa')),
                );
                return true;
              } else {
                return false;
              }
            },
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: Text(
                    (note.isNotEmpty) ? note[0] : 'V',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  'Hẹn: $note',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Địa điểm: ${appointment.location}\nNgày hẹn: $formattedDate',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
                onTap: () => _showForm(appointment: appointment),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(),
        backgroundColor: Colors.teal,
        icon: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
        label: const Text(
          "Tạo mới",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
