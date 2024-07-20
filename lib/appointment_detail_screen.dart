import 'package:flutter/material.dart';

import 'appointment_model.dart';

class AppointmentDetailScreen extends StatelessWidget {
  final Appointment appointment;

  AppointmentDetailScreen({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết lịch hẹn'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Ngày: ${appointment.date.toLocal().toString().split(' ')[0]}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8.0),
            Text(
              'Giờ bắt đầu: ${appointment.startTime.toLocal().toString().split(' ')[1].substring(0, 5)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8.0),
            Text(
              'Giờ kết thúc: ${appointment.endTime.toLocal().toString().split(' ')[1].substring(0, 5)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8.0),
            Text(
              'Địa điểm: ${appointment.location}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8.0),
            Text(
              'Ghi chú: ${appointment.note}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8.0),
            Text(
              'Loại lịch hẹn: ${appointment.type}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8.0),
            Text(
              'Màu sắc/biểu tượng: ${appointment.color}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            // Hiển thị đính kèm nếu có
            if (appointment.attachments.isNotEmpty) ...[
              SizedBox(height: 16.0),
              Text('Đính kèm:', style: Theme.of(context).textTheme.titleMedium),
              ...appointment.attachments.map((attachment) => ListTile(
                    title: Text(attachment),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}
