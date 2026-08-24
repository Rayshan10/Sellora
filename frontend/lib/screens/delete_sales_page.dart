import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/sale.dart';
import '../services/sales_service.dart';

class DeleteSalesPage extends StatefulWidget {
  const DeleteSalesPage({Key? key}) : super(key: key);

  @override
  State<DeleteSalesPage> createState() => _DeleteSalesPageState();
}

class _DeleteSalesPageState extends State<DeleteSalesPage> {
  List<Sale> _sales = [];

  bool _isLoading = true;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  Future<void> _loadSales() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final sales = await SalesService.getSales();

      if (!mounted) return;

      setState(() {
        _sales = sales;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(_cleanError(error));
    }
  }

  String _cleanError(Object error) {
    String message = error.toString();

    if (message.startsWith('Exception: ')) {
      message = message.substring('Exception: '.length);
    }

    return message;
  }

  Future<void> _confirmDelete(Sale sale) async {
    if (_isDeleting) return;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFDC2626),
                size: 28,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Hapus Data?',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Apakah kamu yakin ingin menghapus transaksi '
            '${sale.invoiceNumber}?\n\n'
            'Data yang sudah dihapus tidak dapat dikembalikan.',
            style: const TextStyle(
              color: Color(0xFF475569),
              height: 1.5,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(
            20,
            0,
            20,
            20,
          ),
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0F172A),
                side: const BorderSide(
                  color: Color(0xFFE2E8F0),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await _deleteSale(sale);
  }

  Future<void> _deleteSale(Sale sale) async {
    if (_isDeleting) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      await SalesService.deleteSale(
        id: sale.id,
      );

      if (!mounted) return;

      setState(() {
        _sales.removeWhere(
          (item) => item.id == sale.id,
        );
        _isDeleting = false;
      });

      _showMessage(
        'Data penjualan berhasil dihapus',
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isDeleting = false;
      });

      _showMessage(_cleanError(error));
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _formatCurrency(double value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
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
                  color: Colors.white.withValues(
                    alpha: 0.12,
                  ),
                ),
              ),
              Positioned(
                bottom: 80,
                left: -50,
                child: _BackgroundOrb(
                  size: 180,
                  color: Colors.white.withValues(
                    alpha: 0.08,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // =========================
                    // HEADER
                    // =========================
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: 0.14,
                        ),
                        borderRadius:
                            BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withValues(
                            alpha: 0.18,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(
                                alpha: 0.18,
                              ),
                              borderRadius:
                                  BorderRadius.circular(18),
                            ),
                            child: const Icon(
                              Icons.delete_outline_rounded,
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
                                  'Hapus Data Penjualan',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight:
                                        FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Pilih transaksi yang ingin dihapus.',
                                  style: TextStyle(
                                    color: Colors.white
                                        .withValues(
                                      alpha: 0.82,
                                    ),
                                    fontSize: 13,
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
                    // CONTENT
                    // =========================
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(
                            alpha: 0.95,
                          ),
                          borderRadius:
                              BorderRadius.circular(30),
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
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Data Penjualan',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight:
                                          FontWeight.w800,
                                      color:
                                          Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: _isDeleting
                                      ? null
                                      : _loadSales,
                                  icon: const Icon(
                                    Icons.refresh_rounded,
                                    color:
                                        Color(0xFF2563EB),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            Expanded(
                              child: _buildContent(),
                            ),

                            const SizedBox(height: 12),

                            SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _isDeleting
                                    ? null
                                    : () {
                                        Navigator
                                            .pushReplacementNamed(
                                          context,
                                          '/home',
                                        );
                                      },
                                style:
                                    ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color(
                                    0xFF0F172A,
                                  ),
                                  foregroundColor:
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_sales.isEmpty) {
      return Center(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
            ),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 48,
                color: Color(0xFF94A3B8),
              ),
              SizedBox(height: 12),
              Text(
                'Belum ada data penjualan',
                style: TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: _sales.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final sale = _sales[index];

        return _SaleCard(
          sale: sale,
          isDeleting: _isDeleting,
          formattedDate: _formatDate(sale.saleDate),
          formattedTotal: _formatCurrency(
            sale.totalSale,
          ),
          onDelete: () => _confirmDelete(sale),
        );
      },
    );
  }
}

class _SaleCard extends StatelessWidget {
  const _SaleCard({
    required this.sale,
    required this.isDeleting,
    required this.formattedDate,
    required this.formattedTotal,
    required this.onDelete,
  });

  final Sale sale;
  final bool isDeleting;
  final String formattedDate;
  final String formattedTotal;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: Color(0xFFDC2626),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  sale.invoiceNumber,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  sale.customerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$formattedDate • ${sale.itemQuantity} barang',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formattedTotal,
                  style: const TextStyle(
                    color: Color(0xFF2563EB),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          IconButton(
            tooltip: 'Hapus transaksi',
            onPressed: isDeleting ? null : onDelete,
            style: IconButton.styleFrom(
              backgroundColor:
                  const Color(0xFFFEE2E2),
              foregroundColor:
                  const Color(0xFFDC2626),
            ),
            icon: const Icon(
              Icons.delete_outline_rounded,
            ),
          ),
        ],
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