import 'dart:convert';

import 'package:psyconnect/models/consultation_model.dart';
import 'package:http/http.dart' as http;
import 'package:psyconnect/models/psychologist.dart';
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
  Future<PsychologistModel> getPsychologistById(String psychologistId);
}

class ConsultationRepositoryImpl implements ConsultationRepository {
  final http.Client client;
  final String baseUrl;

  ConsultationRepositoryImpl(
      {required this.client,
      this.baseUrl = 'https://psy-backend-production.up.railway.app/api/v1'});

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
      Uri.parse('$baseUrl/consultations/$consultationId/status'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: json.encode({'status': status}),
    );

    print('Consultation Id: $consultationId, Status: $status');

    if (response.statusCode != 200) {
      // throw Exception('Failed to update status');
      print('Failed to update status: ${response.body}');
      throw Exception('Failed to update consultation status: ${response.body}');
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
      return data.map((json) => Consultation.fromJson(json)).toList();
    }
    throw Exception('Failed to load client consultations');
  }

  @override
  Future<PsychologistModel> getPsychologistById(String psychologistId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await client.get(
      Uri.parse('$baseUrl/psychologists/$psychologistId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      print('Psychologist data: ${response.body}');
      return PsychologistModel.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to load psychologist');
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
