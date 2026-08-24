import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/sale.dart';
import '../services/sales_service.dart';

class UpdateSalesPage extends StatefulWidget {
  const UpdateSalesPage({Key? key}) : super(key: key);

  @override
  State<UpdateSalesPage> createState() => _UpdateSalesPageState();
}

class _UpdateSalesPageState extends State<UpdateSalesPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _customerController =
      TextEditingController();

  final TextEditingController _quantityController =
      TextEditingController();

  final TextEditingController _totalController =
      TextEditingController();

  List<Sale> _sales = [];

  Sale? _selectedSale;

  DateTime _selectedDate = DateTime.now();

  bool _isLoadingSales = true;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  @override
  void dispose() {
    _customerController.dispose();
    _quantityController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  Future<void> _loadSales() async {
    setState(() {
      _isLoadingSales = true;
    });

    try {
      final sales = await SalesService.getSales();

      if (!mounted) return;

      setState(() {
        _sales = sales;
        _isLoadingSales = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoadingSales = false;
      });

      String message = error.toString();

      if (message.startsWith('Exception: ')) {
        message = message.substring('Exception: '.length);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _selectSale(Sale? sale) {
    if (sale == null) return;

    setState(() {
      _selectedSale = sale;
      _selectedDate = sale.saleDate;

      _customerController.text = sale.customerName;
      _quantityController.text = sale.itemQuantity.toString();
      _totalController.text = sale.totalSale.toString();
    });
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

  Future<void> _updateSale() async {
    if (_isUpdating) return;

    if (_selectedSale == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih nomor faktur terlebih dahulu'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final int? itemQuantity = int.tryParse(
      _quantityController.text.trim(),
    );

    final double? totalSale = double.tryParse(
      _totalController.text.trim(),
    );

    if (itemQuantity == null || totalSale == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Jumlah barang atau total penjualan tidak valid',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isUpdating = true;
    });

    try {
      await SalesService.updateSale(
        id: _selectedSale!.id,
        saleDate: _selectedDate,
        customerName: _customerController.text.trim(),
        itemQuantity: itemQuantity,
        totalSale: totalSale,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Data penjualan berhasil diperbarui',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pushReplacementNamed(
        context,
        '/dashboard',
      );
    } catch (error) {
      if (!mounted) return;

      String message = error.toString();

      if (message.startsWith('Exception: ')) {
        message = message.substring('Exception: '.length);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
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
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1D4ED8),
              Color(0xFF38BDF8),
            ],
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
                    // =========================
                    // HEADER
                    // =========================
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.18),
                        ),
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
                              Icons.edit_note_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Update Data Penjualan',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Pilih faktur lalu perbarui detail transaksi.',
                                  style: TextStyle(
                                    color: Colors.white.withValues(
                                      alpha: 0.82,
                                    ),
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

                    // =========================
                    // FORM CARD
                    // =========================
                    Expanded(
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
                          crossAxisAlignment:
                              CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Pilih Transaksi',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // =========================
                            // DROPDOWN INVOICE
                            // =========================
                            if (_isLoadingSales)
                              Container(
                                height: 56,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius:
                                      BorderRadius.circular(18),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                  ),
                                ),
                              )
                            else if (_sales.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF7ED),
                                  borderRadius:
                                      BorderRadius.circular(18),
                                  border: Border.all(
                                    color: const Color(0xFFFED7AA),
                                  ),
                                ),
                                child: const Text(
                                  'Belum ada data penjualan untuk diperbarui.',
                                  style: TextStyle(
                                    color: Color(0xFF9A3412),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            else
                              DropdownButtonFormField<Sale>(
                                decoration: _fieldDecoration(
                                  'No Faktur',
                                  Icons.receipt_long_rounded,
                                ),
                                value: _selectedSale,
                                items: _sales.map((sale) {
                                  return DropdownMenuItem<Sale>(
                                    value: sale,
                                    child: Text(
                                      sale.invoiceNumber,
                                    ),
                                  );
                                }).toList(),
                                onChanged: _isUpdating
                                    ? null
                                    : _selectSale,
                                hint: const Text(
                                  'Pilih No Faktur',
                                ),
                              ),

                            if (_selectedSale != null) ...[
                              const SizedBox(height: 18),

                              Expanded(
                                child: Form(
                                  key: _formKey,
                                  child: ListView(
                                    children: [
                                      Container(
                                        padding:
                                            const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color:
                                              const Color(0xFFF8FAFC),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                            color: const Color(
                                              0xFFE2E8F0,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          'Update Data untuk Faktur: ${_selectedSale!.invoiceNumber}',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight:
                                                FontWeight.w700,
                                            color:
                                                Color(0xFF0F172A),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 16),

                                      // =========================
                                      // TANGGAL
                                      // =========================
                                      InkWell(
                                        borderRadius:
                                            BorderRadius.circular(18),
                                        onTap: _isUpdating
                                            ? null
                                            : () =>
                                                _selectDate(context),
                                        child: InputDecorator(
                                          decoration:
                                              _fieldDecoration(
                                            'Tanggal Penjualan',
                                            Icons
                                                .calendar_month_rounded,
                                          ),
                                          child: Text(
                                            DateFormat('dd/MM/yyyy')
                                                .format(
                                              _selectedDate,
                                            ),
                                            style: const TextStyle(
                                              color:
                                                  Color(0xFF0F172A),
                                              fontWeight:
                                                  FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 16),

                                      // =========================
                                      // CUSTOMER
                                      // =========================
                                      TextFormField(
                                        controller:
                                            _customerController,
                                        enabled: !_isUpdating,
                                        decoration:
                                            _fieldDecoration(
                                          'Nama Customer',
                                          Icons
                                              .person_outline_rounded,
                                        ),
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'Harap isi nama customer';
                                          }

                                          return null;
                                        },
                                      ),

                                      const SizedBox(height: 16),

                                      // =========================
                                      // JUMLAH
                                      // =========================
                                      TextFormField(
                                        controller:
                                            _quantityController,
                                        enabled: !_isUpdating,
                                        keyboardType:
                                            TextInputType.number,
                                        decoration:
                                            _fieldDecoration(
                                          'Jumlah Barang',
                                          Icons
                                              .inventory_2_outlined,
                                        ),
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'Harap isi jumlah barang';
                                          }

                                          final quantity =
                                              int.tryParse(
                                            value.trim(),
                                          );

                                          if (quantity == null) {
                                            return 'Masukkan angka yang valid';
                                          }

                                          if (quantity <= 0) {
                                            return 'Jumlah barang harus lebih dari 0';
                                          }

                                          return null;
                                        },
                                      ),

                                      const SizedBox(height: 16),

                                      // =========================
                                      // TOTAL
                                      // =========================
                                      TextFormField(
                                        controller:
                                            _totalController,
                                        enabled: !_isUpdating,
                                        keyboardType:
                                            const TextInputType
                                                .numberWithOptions(
                                          decimal: true,
                                        ),
                                        decoration:
                                            _fieldDecoration(
                                          'Total Penjualan',
                                          Icons.payments_outlined,
                                        ),
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'Harap isi total penjualan';
                                          }

                                          final total =
                                              double.tryParse(
                                            value.trim(),
                                          );

                                          if (total == null) {
                                            return 'Masukkan angka yang valid';
                                          }

                                          if (total <= 0) {
                                            return 'Total penjualan harus lebih dari 0';
                                          }

                                          return null;
                                        },
                                      ),

                                      const SizedBox(height: 24),

                                      // =========================
                                      // UPDATE BUTTON
                                      // =========================
                                      SizedBox(
                                        height: 54,
                                        child: ElevatedButton(
                                          onPressed: _isUpdating
                                              ? null
                                              : _updateSale,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF0F172A),
                                            foregroundColor:
                                                Colors.white,
                                            disabledBackgroundColor:
                                                const Color(0xFF64748B),
                                            disabledForegroundColor:
                                                Colors.white,
                                            elevation: 0,
                                            shape:
                                                RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                18,
                                              ),
                                            ),
                                          ),
                                          child: _isUpdating
                                              ? const SizedBox(
                                                  width: 24,
                                                  height: 24,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2.5,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                            Color>(
                                                      Colors.white,
                                                    ),
                                                  ),
                                                )
                                              : const Text(
                                                  'Update Data',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w700,
                                                  ),
                                                ),
                                        ),
                                      ),

                                      const SizedBox(height: 12),

                                      // =========================
                                      // BACK BUTTON
                                      // =========================
                                      SizedBox(
                                        height: 52,
                                        child: OutlinedButton(
                                          onPressed: _isUpdating
                                              ? null
                                              : () {
                                                  Navigator
                                                      .pushReplacementNamed(
                                                    context,
                                                    '/home',
                                                  );
                                                },
                                          style:
                                              OutlinedButton.styleFrom(
                                            foregroundColor:
                                                const Color(0xFF0F172A),
                                            disabledForegroundColor:
                                                const Color(0xFF94A3B8),
                                            side: const BorderSide(
                                              color:
                                                  Color(0xFFE2E8F0),
                                            ),
                                            shape:
                                                RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                18,
                                              ),
                                            ),
                                          ),
                                          child: const Text(
                                            'Kembali',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight:
                                                  FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ] else if (!_isLoadingSales &&
                                _sales.isNotEmpty) ...[
                              const Expanded(
                                child: Center(
                                  child: Text(
                                    'Pilih No Faktur terlebih dahulu',
                                    style: TextStyle(
                                      color: Color(0xFF475569),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
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
    String label,
    IconData icon,
  ) {
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
        borderSide: const BorderSide(
          color: Color(0xFFE2E8F0),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Color(0xFF2563EB),
          width: 1.4,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Color(0xFFE2E8F0),
        ),
      ),
    );
  }
}

class _BackgroundOrb extends StatelessWidget {
  const _BackgroundOrb({
    required this.size,
    required this.color,
  });

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