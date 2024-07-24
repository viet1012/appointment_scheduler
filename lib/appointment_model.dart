class Appointment {
  final String id;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final String note;
  final String type;
  final String color;
  final List<String> attachments;
  final String userId;

  Appointment({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.note,
    required this.type,
    required this.color,
    required this.attachments,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'location': location,
      'note': note,
      'type': type,
      'color': color,
      'attachments': attachments.join(','),
      'userId': userId,
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'],
      date: DateTime.parse(map['date']),
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      location: map['location'],
      note: map['note'],
      type: map['type'],
      color: map['color'],
      attachments: List<String>.from(map['attachments'].split(',')),
      userId: map['userId'],
    );
  }
}
