import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String apiUrl = 'https://psy-backend-production.up.railway.app/api/v1/auth';

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/login'),
        body: json.encode({'email': email, 'password': password}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String token = data['data']['token'];
        String roleName = data['data']['role_name'];
        String username = data['data']['username'];

        final prefs = await SharedPreferences.getInstance();
        prefs.setString('token', token);
        prefs.setString('role_name', roleName);
        prefs.setString('username', username);

        return {
          'message': data['message'],
          'token': token,
          'role_name': roleName,
          'username': username,
        };
      } else {
        return {
          'message': json.decode(response.body)['message'],
        };
      }
    } catch (e) {
      return {'message': 'Login failed. Error: $e'};
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<String?> getRoleName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role_name');
  }

  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    prefs.remove('role_name');
    prefs.remove('username');
  }

  Future<Map<String, dynamic>> register(String email, String password,
      String fullName, String phoneNumber, String dateOfBirth) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/register/client'),
        body: json.encode({
          'email': email,
          'password': password,
          'full_name': fullName,
          'phone_number': phoneNumber,
          'date_of_birth': dateOfBirth,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'message': data['message'],
        };
      } else {
        return {
          'message': json.decode(response.body)['message'],
        };
      }
    } catch (e) {
      return {'message': 'Register failed. Error: $e'};
    }
  }
}
