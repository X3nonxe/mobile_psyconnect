import 'dart:convert';

import 'package:psyconnect/models/consultation_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

abstract class ConsultationRepository {
  Future<List<Consultation>> getConsultations(String psychologistId);
  Future<void> updateConsultationStatus(String consultationId, String status);
  Future<List<Consultation>> getClientConsultations();
  Future<Consultation> createClientConsultation({
    required String psychologistId,
    required DateTime scheduledTime,
    required int duration,
  });
}

class ConsultationRepositoryImpl implements ConsultationRepository {
  final http.Client client;
  final String baseUrl;

  ConsultationRepositoryImpl(
      {required this.client, this.baseUrl = 'https://psy-backend-production.up.railway.app/api/v1'});

  @override
  Future<List<Consultation>> getConsultations(String psychologistId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await client.get(
      Uri.parse('$baseUrl/consultations/psychologist'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Consultation.fromJson(json)).toList();
    }
    throw Exception('Failed to load consultations');
  }

  @override
  Future<void> updateConsultationStatus(
      String consultationId, String status) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await client.put(
      Uri.parse('$baseUrl/$consultationId/status'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: json.encode({'status': status}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update status');
    }
  }

  @override
  Future<List<Consultation>> getClientConsultations() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await client.get(
      Uri.parse('$baseUrl/consultations/client'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      print('Client consultations: $data');
      return data.map((json) => Consultation.fromJson(json)).toList();
    }
    throw Exception('Failed to load client consultations');
  }

  @override
  Future<Consultation> createClientConsultation({
    required String psychologistId,
    required DateTime scheduledTime,
    required int duration,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await client.post(
      Uri.parse('$baseUrl/consultations'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'psychologist_id': psychologistId,
        'scheduled_time': scheduledTime.toIso8601String(),
        'duration': duration,
      }),
    );

    if (response.statusCode == 201) {
      return Consultation.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to create consultation: ${response.body}');
  }
}
