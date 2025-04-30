import 'package:intl/intl.dart';

class SalesData {
  final String invoiceNumber;
  final DateTime saleDate;
  final String customerName;
  final int itemQuantity;
  final double totalSale;

  SalesData({
    required this.invoiceNumber,
    required this.saleDate,
    required this.customerName,
    required this.itemQuantity,
    required this.totalSale,
  });
}

// Global list to store sales data
List<SalesData> salesDataList = [
  SalesData(
    invoiceNumber: 'INV-001',
    saleDate: DateTime(2025, 4, 25),
    customerName: 'PT. Maju Jaya',
    itemQuantity: 10,
    totalSale: 5000000,
  ),
  SalesData(
    invoiceNumber: 'INV-002',
    saleDate: DateTime(2025, 4, 27),
    customerName: 'CV. Sukses Abadi',
    itemQuantity: 5,
    totalSale: 2500000,
  ),
  SalesData(
    invoiceNumber: 'INV-003',
    saleDate: DateTime(2025, 4, 30),
    customerName: 'Toko Makmur',
    itemQuantity: 8,
    totalSale: 4000000,
  ),
];

// Currency formatter
final currencyFormat = NumberFormat.currency(
  locale: 'id',
  symbol: 'Rp',
  decimalDigits: 0,
);