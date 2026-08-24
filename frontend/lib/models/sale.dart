class Sale {
  final String id;
  final String invoiceNumber;
  final DateTime saleDate;
  final String customerName;
  final int itemQuantity;
  final double totalSale;

  Sale({
    required this.id,
    required this.invoiceNumber,
    required this.saleDate,
    required this.customerName,
    required this.itemQuantity,
    required this.totalSale,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['_id']?.toString() ?? '',
      invoiceNumber: json['invoiceNumber']?.toString() ?? '',
      saleDate: DateTime.parse(json['saleDate']).toLocal(),
      customerName: json['customerName']?.toString() ?? '',
      itemQuantity: (json['itemQuantity'] as num?)?.toInt() ?? 0,
      totalSale: (json['totalSale'] as num?)?.toDouble() ?? 0,
    );
  }
}