import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/sales_data.dart';

class UpdateSalesPage extends StatefulWidget {
  const UpdateSalesPage({Key? key}) : super(key: key);

  @override
  State<UpdateSalesPage> createState() => _UpdateSalesPageState();
}

class _UpdateSalesPageState extends State<UpdateSalesPage> {
  String? _selectedInvoice;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _customerController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _customerController.dispose();
    _quantityController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), Color(0xFF1D4ED8), Color(0xFF38BDF8)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: -40,
                right: -30,
                child: _BackgroundOrb(
                  size: 140,
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
              Positioned(
                bottom: 80,
                left: -50,
                child: _BackgroundOrb(
                  size: 180,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 30,
                        offset: Offset(0, 18),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1D4ED8)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.edit_note_rounded,
                                  color: Color(0xFF1D4ED8), size: 28),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Update Data Penjualan',
                                    style: TextStyle(
                                      color: Color(0xFF0F172A),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Pilih faktur lalu perbarui detail transaksi yang diperlukan.',
                                    style: TextStyle(
                                      color: Color(0xFF475569),
                                      fontSize: 13,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      DropdownButtonFormField<String>(
                        decoration: _fieldDecoration(
                            'No Faktur', Icons.receipt_long_rounded),
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
                            if (_selectedInvoice != null) {
                              final selectedData = salesDataList.firstWhere(
                                (data) =>
                                    data.invoiceNumber == _selectedInvoice,
                              );
                              _selectedDate = selectedData.saleDate;
                              _customerController.text =
                                  selectedData.customerName;
                              _quantityController.text =
                                  selectedData.itemQuantity.toString();
                              _totalController.text =
                                  selectedData.totalSale.toString();
                            }
                          });
                        },
                        hint: const Text('Pilih No Faktur'),
                      ),
                      const SizedBox(height: 18),
                      Expanded(
                        child: _selectedInvoice == null
                            ? const Center(
                                child: Text(
                                  'Pilih No Faktur terlebih dahulu',
                                  style: TextStyle(color: Color(0xFF475569)),
                                ),
                              )
                            : Form(
                                key: _formKey,
                                child: ListView(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                            color: const Color(0xFFE2E8F0)),
                                      ),
                                      child: Text(
                                        'Update Data untuk Faktur: $_selectedInvoice',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    InkWell(
                                      borderRadius: BorderRadius.circular(18),
                                      onTap: () async {
                                        final DateTime? picked =
                                            await showDatePicker(
                                          context: context,
                                          initialDate: _selectedDate,
                                          firstDate: DateTime(2020),
                                          lastDate: DateTime(2030),
                                        );
                                        if (picked != null &&
                                            picked != _selectedDate) {
                                          setState(() {
                                            _selectedDate = picked;
                                          });
                                        }
                                      },
                                      child: InputDecorator(
                                        decoration: _fieldDecoration(
                                            'Tanggal Penjualan',
                                            Icons.calendar_month_rounded),
                                        child: Text(DateFormat('dd/MM/yyyy')
                                            .format(_selectedDate)),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _customerController,
                                      decoration: _fieldDecoration(
                                          'Nama Customer',
                                          Icons.person_outline_rounded),
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
                                      decoration: _fieldDecoration(
                                          'Jumlah Barang',
                                          Icons.inventory_2_outlined),
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
                                      decoration: _fieldDecoration(
                                          'Total Penjualan',
                                          Icons.payments_outlined),
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
                                    SizedBox(
                                      height: 54,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            final index =
                                                salesDataList.indexWhere(
                                              (data) =>
                                                  data.invoiceNumber ==
                                                  _selectedInvoice,
                                            );
                                            if (index != -1) {
                                              salesDataList[index] = SalesData(
                                                invoiceNumber:
                                                    _selectedInvoice!,
                                                saleDate: _selectedDate,
                                                customerName:
                                                    _customerController.text,
                                                itemQuantity: int.parse(
                                                    _quantityController.text),
                                                totalSale: double.parse(
                                                    _totalController.text),
                                              );
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Data penjualan berhasil diupdate'),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF0F172A),
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(18),
                                          ),
                                        ),
                                        child: const Text(
                                          'Update Data',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      height: 52,
                                      child: OutlinedButton(
                                        onPressed: () {
                                          Navigator.pushReplacementNamed(
                                              context, '/home');
                                        },
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor:
                                              const Color(0xFF0F172A),
                                          side: const BorderSide(
                                              color: Color(0xFFE2E8F0)),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(18),
                                          ),
                                        ),
                                        child: const Text(
                                          'Kembali',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.4),
      ),
    );
  }
}

class _BackgroundOrb extends StatelessWidget {
  const _BackgroundOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
