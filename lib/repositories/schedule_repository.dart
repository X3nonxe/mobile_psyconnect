import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:psyconnect/models/schedule_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ScheduleRepository {
  Future<List<Schedule>> getSchedules(String psychologistId);
  Future<void> saveSchedules(List<Schedule> schedules);
  Future<void> updateSchedule(String scheduleId, Schedule updatedSchedule);
  Future<void> deleteSchedule(String scheduleId);
}

class ScheduleRepositoryImpl implements ScheduleRepository {
  final http.Client client;
  final String baseUrl;

  ScheduleRepositoryImpl(
      {required this.client, this.baseUrl = 'https://psy-backend-production.up.railway.app/api/v1'});

  @override
  Future<List<Schedule>> getSchedules(String psychologistId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final validPsychologistId = prefs.getString('id') ?? psychologistId;

    if (token == null) {
      throw Exception('Token tidak ditemukan');
    }

    if (validPsychologistId.isEmpty) {
      throw Exception('Psychologist ID tidak valid');
    }

    final response = await client.get(
      Uri.parse(
          '$baseUrl/schedules/psychologists/$validPsychologistId/schedules'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'] as List;
      return data.map((json) => Schedule.fromJson(json)).toList();
    }
    throw Exception('Failed to load schedules');
  }

  @override
  Future<void> saveSchedules(List<Schedule> schedules) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token tidak ditemukan');
    }

    final response = await client.post(
      Uri.parse('$baseUrl/schedules/psychologists/schedules'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: json.encode(schedules.map((s) => s.toJson()).toList()),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to save schedules');
    }
  }

  @override
  Future<void> updateSchedule(
      String scheduleId, Schedule updatedSchedule) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token not found');
    }

    if (scheduleId.trim().isEmpty) {
      throw Exception('Invalid Schedule ID');
    }

    try {
      // Buat request dengan PUT
      final response = await client.put(
        Uri.parse('$baseUrl/schedules/psychologists/schedules/$scheduleId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(updatedSchedule.toJson()),
      );

      // Log respons untuk debugging
      print('Update Schedule Response Status: ${response.statusCode}');
      print('Update Schedule Response Body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to update schedule: ${response.body}');
      }
    } catch (e) {
      print('Error updating schedule: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteSchedule(String scheduleId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token not found');
    }

    if (scheduleId.trim().isEmpty) {
      throw Exception('Invalid Schedule ID');
    }

    final response = await client.delete(
      Uri.parse('$baseUrl/schedules/psychologists/schedules/$scheduleId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete schedule');
    }
  }
}
