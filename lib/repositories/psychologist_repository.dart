import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:psyconnect/models/psychologist.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class PsychologistRepository {
  Future<List<PsychologistModel>> getAllPsychologist();
}

class PsychologistRepositoryImpl implements PsychologistRepository {
  final http.Client client;
  final String baseUrl;

  PsychologistRepositoryImpl(
      {required this.client, this.baseUrl = 'https://psy-backend-production.up.railway.app/api/v1'});

  @override
  Future<List<PsychologistModel>> getAllPsychologist() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await client.get(
      Uri.parse('$baseUrl/psychologists'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      final List<dynamic> data = responseBody['data'];

      return data
          .map((psychJson) => PsychologistModel.fromJson(psychJson))
          .toList();
    }
    throw Exception('Failed to load consultations');
  }
}
