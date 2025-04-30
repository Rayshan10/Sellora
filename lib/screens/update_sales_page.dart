import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/sales_data.dart';

class UpdateSalesPage extends StatefulWidget {
  const UpdateSalesPage({Key? key}) : super(key: key);

  @override
  _UpdateSalesPageState createState() => _UpdateSalesPageState();
}

class _UpdateSalesPageState extends State<UpdateSalesPage> {
  String? _selectedInvoice;
  
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _customerController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Data Penjualan'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih No Faktur untuk Update:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              value: _selectedInvoice,
              items: salesDataList.map((data) {
                return DropdownMenuItem<String>(
                  value: data.invoiceNumber,
                  child: Text(data.invoiceNumber),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedInvoice = value;
                  
                  // Populate form if invoice is selected
                  if (_selectedInvoice != null) {
                    final selectedData = salesDataList.firstWhere(
                      (data) => data.invoiceNumber == _selectedInvoice,
                    );
                    
                    _selectedDate = selectedData.saleDate;
                    _customerController.text = selectedData.customerName;
                    _quantityController.text = selectedData.itemQuantity.toString();
                    _totalController.text = selectedData.totalSale.toString();
                  }
                });
              },
              hint: const Text('Pilih No Faktur'),
            ),
            const SizedBox(height: 24),
            
            Expanded(
              child: _selectedInvoice == null
                  ? const Center(
                      child: Text('Pilih No Faktur terlebih dahulu'),
                    )
                  : Form(
                      key: _formKey,
                      child: ListView(
                        children: [
                          Text(
                            'Update Data untuk Faktur: $_selectedInvoice',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          InkWell(
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null && picked != _selectedDate) {
                                setState(() {
                                  _selectedDate = picked;
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Tanggal Penjualan',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                DateFormat('dd/MM/yyyy').format(_selectedDate),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _customerController,
                            decoration: const InputDecoration(
                              labelText: 'Nama Customer',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Harap isi nama customer';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _quantityController,
                            decoration: const InputDecoration(
                              labelText: 'Jumlah Barang',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Harap isi jumlah barang';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Masukkan angka yang valid';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _totalController,
                            decoration: const InputDecoration(
                              labelText: 'Total Penjualan',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Harap isi total penjualan';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Masukkan angka yang valid';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                // Update sales data
                                final index = salesDataList.indexWhere(
                                  (data) => data.invoiceNumber == _selectedInvoice,
                                );
                                
                                if (index != -1) {
                                  salesDataList[index] = SalesData(
                                    invoiceNumber: _selectedInvoice!,
                                    saleDate: _selectedDate,
                                    customerName: _customerController.text,
                                    itemQuantity: int.parse(_quantityController.text),
                                    totalSale: double.parse(_totalController.text),
                                  );
                                  
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Data penjualan berhasil diupdate'),
                                    ),
                                  );
                                }
                              }
                            },
                            child: const Text('Update Data'),
                          ),
                        ],
                      ),
                    ),
            ),
            Center(
              child: OutlinedButton(
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