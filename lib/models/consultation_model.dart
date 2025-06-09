class Consultation {
  final String id;
  final String clientId;
  final String psychologistId;
  final DateTime scheduledTime;
  final int duration;
  final String status;
  final String? clientName;
  final String? notes;

  Consultation({
    required this.id,
    required this.clientId,
    required this.psychologistId,
    required this.scheduledTime,
    required this.duration,
    required this.status,
    this.clientName,
    this.notes,
  });

  factory Consultation.fromJson(Map<String, dynamic> json) {
    return Consultation(
      id: json['id'],
      clientId: json['clientId'],
      psychologistId: json['psychologistId'],
      scheduledTime: DateTime.parse(json['scheduledTime']),
      duration: json['duration'],
      status: json['status'],
      clientName: json['client']?['full_name'],
      notes: json['notes'],
    );
  }
}
