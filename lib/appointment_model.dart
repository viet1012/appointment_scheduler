class Appointment {
  String id;
  DateTime date;
  DateTime startTime;
  DateTime endTime;
  String location;
  String note;
  String type;
  String color;
  List<String> attachments;

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
  });
}
