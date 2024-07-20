import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'appointment_detail_screen.dart';
import 'appointment_form.dart';
import 'appointment_model.dart';

class AppointmentList extends StatefulWidget {
  @override
  _AppointmentListState createState() => _AppointmentListState();
}

class _AppointmentListState extends State<AppointmentList> {
  final List<Appointment> _appointments = [];
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  void _addAppointment(Appointment appointment) {
    setState(() {
      final existingAppointmentIndex =
          _appointments.indexWhere((appt) => appt.id == appointment.id);
      if (existingAppointmentIndex >= 0) {
        _appointments[existingAppointmentIndex] = appointment;
      } else {
        _appointments.add(appointment);
      }
    });
  }

  void _editAppointment(Appointment updatedAppointment) {
    setState(() {
      final index =
          _appointments.indexWhere((appt) => appt.id == updatedAppointment.id);
      if (index >= 0) {
        _appointments[index] = updatedAppointment;
      }
    });
  }

  void _deleteAppointment(String id) {
    setState(() {
      _appointments.removeWhere((appt) => appt.id == id);
    });
  }

  void _showForm({Appointment? appointment}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AppointmentForm(
          appointment: appointment,
          onSave: (appointment == null) ? _addAppointment : _editAppointment,
        ),
      ),
    );
  }

  void _showDetail(Appointment appointment) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AppointmentDetailScreen(appointment: appointment),
      ),
    );
  }

  Map<DateTime, List<Appointment>> _groupAppointmentsByDate() {
    Map<DateTime, List<Appointment>> data = {};
    for (var appointment in _appointments) {
      DateTime date = DateTime(
        appointment.date.year,
        appointment.date.month,
        appointment.date.day,
      );
      if (data[date] == null) data[date] = [];
      data[date]!.add(appointment);
    }
    return data;
  }

  List<Appointment> _getAppointmentsForSelectedDay() {
    return _groupAppointmentsByDate()[_selectedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    Map<DateTime, List<Appointment>> groupedAppointments =
        _groupAppointmentsByDate();

    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách lịch hẹn'),
      ),
      body: Column(
        children: [
          // TableCalendar(
          //   focusedDay: _focusedDay,
          //   firstDay: DateTime(2020),
          //   lastDay: DateTime(2030),
          //   selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          //   calendarFormat: _calendarFormat,
          //   eventLoader: (date) {
          //     return groupedAppointments[date] ?? [];
          //   },
          //   onDaySelected: (selectedDay, focusedDay) {
          //     setState(() {
          //       _selectedDay = selectedDay;
          //       _focusedDay = focusedDay;
          //     });
          //   },
          //   onFormatChanged: (format) {
          //     setState(() {
          //       _calendarFormat = format;
          //     });
          //   },
          //   onPageChanged: (focusedDay) {
          //     _focusedDay = focusedDay;
          //   },
          // ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ListView.builder(
              itemCount: _getAppointmentsForSelectedDay().length,
              itemBuilder: (context, index) {
                final appointment = _getAppointmentsForSelectedDay()[index];
                return ListTile(
                  title: Text('Hẹn: ${appointment.note}'),
                  subtitle: Text('Địa điểm: ${appointment.location}'),
                  onTap: () => _showDetail(appointment),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deleteAppointment(appointment.id),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showForm(),
      ),
    );
  }
}
