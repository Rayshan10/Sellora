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

  static Future<Map<String, dynamic>> getMe() async {
    final token = await TokenStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(data['user']);
    }

    throw Exception(
      data['message'] ?? 'Gagal mengambil data user',
    );
  }

  static Future<void> logout() async {
    await TokenStorage.removeToken();
  }
}