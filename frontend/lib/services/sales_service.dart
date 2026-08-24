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

  static Future<Sale> createSale({
    required String invoiceNumber,
    required DateTime saleDate,
    required String customerName,
    required int itemQuantity,
    required double totalSale,
  }) async {
    final token = await TokenStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Sesi login tidak ditemukan');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/sales'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'invoiceNumber': invoiceNumber,
        'saleDate': saleDate.toIso8601String(),
        'customerName': customerName,
        'itemQuantity': itemQuantity,
        'totalSale': totalSale,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return Sale.fromJson(data['data']);
    }

    throw Exception(
      data['message'] ?? 'Gagal menambahkan data penjualan',
    );
  }

  static Future<Sale> updateSale({
    required String id,
    required DateTime saleDate,
    required String customerName,
    required int itemQuantity,
    required double totalSale,
  }) async {
    final token = await TokenStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Sesi login tidak ditemukan');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/sales/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'saleDate': saleDate.toIso8601String(),
        'customerName': customerName,
        'itemQuantity': itemQuantity,
        'totalSale': totalSale,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Sale.fromJson(data['data']);
    }

    throw Exception(
      data['message'] ?? 'Gagal memperbarui data penjualan',
    );
  }

  static Future<void> deleteSale({
    required String id,
  }) async {
    final token = await TokenStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Sesi login tidak ditemukan');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/sales/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return;
    }

    throw Exception(
      data['message'] ?? 'Gagal menghapus data penjualan',
    );
  }
}