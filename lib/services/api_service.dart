import 'package:http/http.dart' as http;
import 'package:psyconnect/services/auth_service.dart';

class ApiService {
  static const String apiUrl = 'http://localhost:3000/api';  // Sesuaikan dengan URL API Anda

  // Menggunakan token untuk request API yang memerlukan autentikasi
  Future<http.Response> fetchData() async {
    final token = await AuthService().getToken();
    
    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse('$apiUrl/some-protected-endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Failed to load data');
    }
  }
}
