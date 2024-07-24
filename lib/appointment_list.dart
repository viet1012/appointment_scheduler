import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'appointment_form.dart';
import 'appointment_model.dart';
import 'database_helper.dart';

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

  void _addAppointment(Appointment appointment) async {
    final dbHelper = DatabaseHelper();
    await dbHelper.insertAppointment(appointment);
    _fetchAppointments(); // Reload the appointments after adding
  }

  void _editAppointment(Appointment updatedAppointment) async {
    final dbHelper = DatabaseHelper();
    await dbHelper.insertAppointment(updatedAppointment);
    _fetchAppointments(); // Reload the appointments after editing
  }

  void _deleteAppointment(String id) async {
    final dbHelper = DatabaseHelper();
    await dbHelper.deleteAppointment(id);
    _fetchAppointments(); // Reload the appointments after deleting
  }

  Future<bool?> _confirmDeleteAppointment(String id, String note) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Xác nhận xóa"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Bạn có chắc chắn muốn xóa lịch hẹn "$note"?'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(false); // Return false to cancel deletion
              },
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(true); // Return true to confirm deletion
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
                fontSize: 24,
                color: Colors.white,
              ),
            ),
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
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: Text(
                    (note.isNotEmpty) ? note[0] : 'N',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text('Hẹn: $note'),
                subtitle: Text(
                    'Địa điểm: ${appointment.location}\nNgày hẹn: $formattedDate'),
                onTap: () => _showForm(appointment: appointment),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(),
      ),
    );
  }
}
