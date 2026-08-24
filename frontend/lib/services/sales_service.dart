import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/sale.dart';
import '../storage/token_storage.dart';

class SalesService {
  static const String baseUrl = 'http://localhost:5000/api';

  static Future<List<Sale>> getSales() async {
    final token = await TokenStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Sesi login tidak ditemukan');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/sales'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final List<dynamic> salesData = data['data'] ?? [];

      return salesData
          .map((item) => Sale.fromJson(item))
          .toList();
    }

    throw Exception(
      data['message'] ?? 'Gagal mengambil data penjualan',
    );
  }
}