import 'dart:convert';
import 'package:http/http.dart' as http;

class PsychologistService {
  final String apiUrl = 'http://192.168.105.116:3000/api/users';
  final String token;

  PsychologistService(this.token);

  Future<List<dynamic>> fetchPsychologists() async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/all-psikolog'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> searchPsychologist(String name) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/search-psikolog/$name'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
