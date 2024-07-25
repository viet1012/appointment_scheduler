import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'appointment_model.dart';

class AppointmentForm extends StatefulWidget {
  final Function(Appointment) onSave;
  final Appointment? appointment;
  final String userId;

  AppointmentForm({
    required this.onSave,
    this.appointment,
    required this.userId,
  });

  @override
  _AppointmentFormState createState() => _AppointmentFormState();
}

class _AppointmentFormState extends State<AppointmentForm> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String _location = '';
  String _note = '';
  String _type = '';
  String _color = '';
  List<String> _attachments = [];

  @override
  void initState() {
    super.initState();
    if (widget.appointment != null) {
      _selectedDate = widget.appointment!.date as DateTime?;
      _startTime = TimeOfDay.fromDateTime(widget.appointment!.startTime);
      _endTime = TimeOfDay.fromDateTime(widget.appointment!.endTime);
      _location = widget.appointment!.location;
      _note = widget.appointment!.note;
      _type = widget.appointment!.type;
      _color = widget.appointment!.color;
      _attachments = widget.appointment!.attachments;
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  Future<void> _selectTime({required bool isStartTime}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newAppointment = Appointment(
        id: widget.appointment?.id ?? DateTime.now().toString(),
        date: _selectedDate!,
        startTime: DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _startTime!.hour,
          _startTime!.minute,
        ),
        endTime: DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _endTime!.hour,
          _endTime!.minute,
        ),
        location: _location,
        note: _note,
        type: _type,
        color: _color,
        attachments: _attachments,
        userId: widget.userId,
      );

      widget.onSave(newAppointment);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.appointment == null
              ? 'Tạo mới lịch hẹn'
              : 'Chỉnh sửa lịch hẹn',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ListTile(
                  title: Text(
                      'Chọn ngày: ${_selectedDate != null ? DateFormat('dd/MM/yyyy').format(_selectedDate!) : 'Chưa chọn'}'),
                  trailing: Icon(Icons.calendar_today),
                  onTap: _selectDate,
                ),
                ListTile(
                  title: Text(
                      'Giờ bắt đầu: ${_startTime?.format(context) ?? 'Chưa chọn'}'),
                  trailing: Icon(Icons.access_time),
                  onTap: () => _selectTime(isStartTime: true),
                ),
                ListTile(
                  title: Text(
                      'Giờ kết thúc: ${_endTime?.format(context) ?? 'Chưa chọn'}'),
                  trailing: Icon(Icons.access_time),
                  onTap: () => _selectTime(isStartTime: false),
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Địa điểm',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: _location,
                  onSaved: (value) => _location = value!,
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Ghi chú',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: _note,
                  onSaved: (value) => _note = value!,
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Loại lịch hẹn',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: _type,
                  onSaved: (value) => _type = value!,
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Màu sắc/biểu tượng',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: _color,
                  onSaved: (value) => _color = value!,
                ),
                SizedBox(height: 20),
                // Đính kèm tệp tin, hình ảnh, âm thanh có thể làm sau
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveForm,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.teal, // Background color
                      foregroundColor: Colors.white, // Text color
                      textStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 8, // Shadow depth
                    ),
                    child: Text('Lưu'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
