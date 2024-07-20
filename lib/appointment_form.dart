import 'package:flutter/material.dart';

import 'appointment_model.dart';

class AppointmentForm extends StatefulWidget {
  final Function(Appointment) onSave;
  final Appointment? appointment;

  AppointmentForm({required this.onSave, this.appointment});

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
      _selectedDate = widget.appointment!.date;
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
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      if (picked.isBefore(DateTime.now())) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể chọn thời gian đã qua'),
          ),
        );
      } else {
        setState(() {
          _selectedDate = picked;
        });
      }
    }
  }

  Future<void> _selectTime({required bool isStartTime}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final now = DateTime.now();
      final selectedDateTime = DateTime(
        _selectedDate?.year ?? now.year,
        _selectedDate?.month ?? now.month,
        _selectedDate?.day ?? now.day,
        picked.hour,
        picked.minute,
      );
      if (selectedDateTime.isBefore(now)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể chọn thời gian đã qua'),
          ),
        );
      } else {
        setState(() {
          if (isStartTime) {
            _startTime = picked;
          } else {
            _endTime = picked;
          }
        });
      }
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
      );
      widget.onSave(newAppointment);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appointment == null
            ? 'Tạo mới lịch hẹn'
            : 'Chỉnh sửa lịch hẹn'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                ListTile(
                  title: Text(
                      'Chọn ngày: ${_selectedDate?.toString() ?? 'Chưa chọn'}'),
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
                TextFormField(
                  decoration: InputDecoration(labelText: 'Địa điểm'),
                  initialValue: _location,
                  onSaved: (value) => _location = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Ghi chú'),
                  initialValue: _note,
                  onSaved: (value) => _note = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Loại lịch hẹn'),
                  initialValue: _type,
                  onSaved: (value) => _type = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Màu sắc/biểu tượng'),
                  initialValue: _color,
                  onSaved: (value) => _color = value!,
                ),
// Đính kèm tệp tin, hình ảnh, âm thanh có thể làm sau
                ElevatedButton(
                  onPressed: _saveForm,
                  child: Text('Lưu'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
