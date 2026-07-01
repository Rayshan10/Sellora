import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/sales_data.dart';

class AddSalesPage extends StatefulWidget {
  const AddSalesPage({Key? key}) : super(key: key);

  @override
  State<AddSalesPage> createState() => _AddSalesPageState();
}

class _AddSalesPageState extends State<AddSalesPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _invoiceController = TextEditingController();
  final TextEditingController _customerController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _invoiceController.dispose();
    _customerController.dispose();
    _quantityController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.18)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(
                              Icons.add_chart_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tambah Data Penjualan',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Masukkan transaksi baru ke dalam daftar penjualan.',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.82),
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
                    const SizedBox(height: 12),
                    Expanded(
                      child: Container(
                        width: double.infinity,
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
                        child: Form(
                          key: _formKey,
                          child: ListView(
                            children: [
                              const Text(
                                'Form Transaksi',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 18),
                              TextFormField(
                                controller: _invoiceController,
                                decoration: _fieldDecoration(
                                  label: 'No Faktur Penjualan',
                                  icon: Icons.receipt_long_rounded,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Harap isi nomor faktur';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: () => _selectDate(context),
                                child: InputDecorator(
                                  decoration: _fieldDecoration(
                                    label: 'Tanggal Penjualan',
                                    icon: Icons.calendar_month_rounded,
                                  ),
                                  child: Text(
                                    DateFormat('dd/MM/yyyy')
                                        .format(_selectedDate),
                                    style: const TextStyle(
                                      color: Color(0xFF0F172A),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _customerController,
                                decoration: _fieldDecoration(
                                  label: 'Nama Customer',
                                  icon: Icons.person_outline_rounded,
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
                                decoration: _fieldDecoration(
                                  label: 'Jumlah Barang',
                                  icon: Icons.inventory_2_outlined,
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
                                decoration: _fieldDecoration(
                                  label: 'Total Penjualan',
                                  icon: Icons.payments_outlined,
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
                              SizedBox(
                                height: 54,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      salesDataList.add(
                                        SalesData(
                                          invoiceNumber:
                                              _invoiceController.text,
                                          saleDate: _selectedDate,
                                          customerName:
                                              _customerController.text,
                                          itemQuantity: int.parse(
                                              _quantityController.text),
                                          totalSale: double.parse(
                                              _totalController.text),
                                        ),
                                      );

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Data penjualan berhasil ditambahkan'),
                                        ),
                                      );

                                      _invoiceController.clear();
                                      _customerController.clear();
                                      _quantityController.clear();
                                      _totalController.clear();
                                      setState(() {
                                        _selectedDate = DateTime.now();
                                      });
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0F172A),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                  child: const Text(
                                    'Simpan Data',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 52,
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF0F172A),
                                    side: const BorderSide(
                                        color: Color(0xFFE2E8F0)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                  child: const Text(
                                    'Kembali',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(
      {required String label, required IconData icon}) {
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
