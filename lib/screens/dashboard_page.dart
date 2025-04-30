import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/sales_data.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Penjualan'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data Penjualan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 20,
                  columns: const [
                    DataColumn(label: Text('No Faktur')),
                    DataColumn(label: Text('Tanggal')),
                    DataColumn(label: Text('Customer')),
                    DataColumn(label: Text('Jumlah Barang')),
                    DataColumn(label: Text('Total Penjualan')),
                  ],
                  rows: salesDataList.map((data) {
                    return DataRow(
                      cells: [
                        DataCell(Text(data.invoiceNumber)),
                        DataCell(Text(DateFormat('dd/MM/yyyy').format(data.saleDate))),
                        DataCell(Text(data.customerName)),
                        DataCell(Text(data.itemQuantity.toString())),
                        DataCell(Text(currencyFormat.format(data.totalSale))),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Kembali'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}