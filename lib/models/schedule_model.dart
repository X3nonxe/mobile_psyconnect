import 'package:flutter/material.dart';

class Schedule {
  final String id;
  final int dayOfWeek;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final bool isRecurring;
  final DateTime? validFrom;
  final DateTime? validTo;

  Schedule({
    required this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.isRecurring,
    this.validFrom,
    this.validTo,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      dayOfWeek: _parseDayOfWeek(json['day_of_week']),
      startTime: _parseTime(json['start_time']),
      endTime: _parseTime(json['end_time']),
      isRecurring: json['is_recurring'],
      validFrom: json['valid_from'] != null
          ? DateTime.parse(json['valid_from'])
          : null,
      validTo:
          json['valid_to'] != null ? DateTime.parse(json['valid_to']) : null,
    );
  }

  static int _parseDayOfWeek(dynamic value) {
    try {
      final day = int.parse(value.toString());
      if (day < 1 || day > 7) throw FormatException();
      return day;
    } catch (e) {
      debugPrint('⚠️ Invalid day_of_week value: $value');
      return 1; // Default ke Senin jika invalid
    }
  }

  static TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Schedule copyWith({
    String? id,
    int? dayOfWeek,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    bool? isRecurring,
    DateTime? validFrom,
    DateTime? validTo,
  }) {
    return Schedule(
      id: id ?? this.id,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isRecurring: isRecurring ?? this.isRecurring,
      validFrom: validFrom ?? this.validFrom,
      validTo: validTo ?? this.validTo,
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'dayOfWeek': dayOfWeek,
      'startTime': '${startTime.hour.toString().padLeft(2, '0')}:'
          '${startTime.minute.toString().padLeft(2, '0')}',
      'endTime': '${endTime.hour.toString().padLeft(2, '0')}:'
          '${endTime.minute.toString().padLeft(2, '0')}',
      'isRecurring': isRecurring,
    };

    // Hanya tambahkan validFrom/validTo jika tidak null
    if (validFrom != null) {
      data['validFrom'] = validFrom!.toIso8601String();
    }
    if (validTo != null) {
      data['validTo'] = validTo!.toIso8601String();
    }

    return data;
  }
}
