import 'dart:convert';

import 'package:http/http.dart' as http;

import '../storage/token_storage.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:5000/api';

  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final token = data['token'];

      if (token != null) {
        await TokenStorage.saveToken(token);
      }

      return data;
    }

    throw Exception(
      data['message'] ?? 'Login gagal',
    );
  }

  static Future<void> logout() async {
    await TokenStorage.removeToken();
  }
}