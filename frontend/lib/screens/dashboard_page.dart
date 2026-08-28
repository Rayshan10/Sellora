import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/sale.dart';
import '../services/sales_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<List<Sale>> _salesFuture;

  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  DateTime? _selectedDate;

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Pilih tanggal penjualan',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );

    if (pickedDate == null) return;

    setState(() {
      _selectedDate = pickedDate;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSales();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadSales() {
    _salesFuture = SalesService.getSales();
  }

  Future<void> _refreshSales() async {
    setState(() {
      _loadSales();
    });

    await _salesFuture;
  }

  List<Sale> _filterSales(List<Sale> sales) {
    return sales.where((sale) {
      final invoiceNumber = sale.invoiceNumber.toLowerCase();
      final customerName = sale.customerName.toLowerCase();

      // Filter berdasarkan pencarian
      final matchesSearch =
          _searchQuery.isEmpty ||
          invoiceNumber.contains(_searchQuery) ||
          customerName.contains(_searchQuery);

      // Filter berdasarkan tanggal
      final matchesDate = _selectedDate == null ||
          (sale.saleDate.year == _selectedDate!.year &&
              sale.saleDate.month == _selectedDate!.month &&
              sale.saleDate.day == _selectedDate!.day);

      return matchesSearch && matchesDate;
    }).toList();
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
          child: FutureBuilder<List<Sale>>(
            future: _salesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return _ErrorState(
                  message: snapshot.error.toString(),
                  onRetry: () {
                    setState(() {
                      _loadSales();
                    });
                  },
                );
              }

              final sales = snapshot.data ?? [];
              final filteredSales = _filterSales(sales);

              final int totalTransactions = filteredSales.length;

              final double totalRevenue = filteredSales.fold(
                0,
                (sum, data) => sum + data.totalSale,
              );

              return Stack(
                children: [
                  Positioned(
                    top: -40,
                    right: -30,
                    child: _BackgroundOrb(
                      size: 150,
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  Positioned(
                    bottom: 70,
                    left: -55,
                    child: _BackgroundOrb(
                      size: 190,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          20,
                          20,
                          20,
                          12,
                        ),
                        child: Container(
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
                                  color:
                                      Colors.white.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Icon(
                                  Icons.analytics_rounded,
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
                                      'Dashboard Penjualan',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Ringkasan transaksi, pelanggan, dan total penjualan.',
                                      style: TextStyle(
                                        color: Colors.white
                                            .withValues(alpha: 0.8),
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
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                label: 'Transaksi',
                                value: totalTransactions.toString(),
                                icon: Icons.receipt_long_rounded,
                                accentColor:
                                    const Color(0xFF1D4ED8),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                label: 'Omzet',
                                value: _currencyFormat.format(
                                  totalRevenue,
                                ),
                                icon: Icons.payments_rounded,
                                accentColor:
                                    const Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      Expanded(
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.fromLTRB(
                            0,
                            8,
                            0,
                            0,
                          ),
                          padding: const EdgeInsets.fromLTRB(
                            20,
                            18,
                            20,
                            16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(32),
                              topRight: Radius.circular(32),
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 30,
                                offset: Offset(0, -8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Data Penjualan',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const Spacer(),

                                  IconButton(
                                    onPressed: _refreshSales,
                                    tooltip: 'Refresh data',
                                    icon: const Icon(
                                      Icons.refresh_rounded,
                                      color: Color(0xFF1D4ED8),
                                    ),
                                  ),

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFF6FF),
                                      borderRadius:
                                          BorderRadius.circular(999),
                                    ),
                                    child: const Text(
                                      'Live Table',
                                      style: TextStyle(
                                        color: Color(0xFF1D4ED8),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 14),

                              // ==============================
                              // SEARCH
                              // ==============================
                              TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText:
                                      'Cari no faktur atau customer...',
                                  prefixIcon: const Icon(
                                    Icons.search_rounded,
                                  ),
                                  suffixIcon: _searchQuery.isNotEmpty
                                      ? IconButton(
                                          onPressed: () {
                                            _searchController.clear();
                                          },
                                          icon: const Icon(
                                            Icons.clear_rounded,
                                          ),
                                          tooltip: 'Hapus pencarian',
                                        )
                                      : null,
                                  filled: true,
                                  fillColor:
                                      const Color(0xFFF8FAFC),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(18),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(18),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(18),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF2563EB),
                                      width: 1.4,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: _selectDate,
                                      icon: const Icon(
                                        Icons.calendar_month_rounded,
                                        size: 20,
                                      ),
                                      label: Text(
                                        _selectedDate == null
                                            ? 'Semua tanggal'
                                            : DateFormat(
                                                'dd/MM/yyyy',
                                              ).format(_selectedDate!),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(0xFF1D4ED8),
                                        side: const BorderSide(
                                          color: Color(0xFFE2E8F0),
                                        ),
                                        backgroundColor: const Color(0xFFF8FAFC),
                                        minimumSize: const Size(
                                          0,
                                          50,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(18),
                                        ),
                                      ),
                                    ),
                                  ),

                                  if (_selectedDate != null) ...[
                                    const SizedBox(width: 10),
                                    SizedBox(
                                      height: 50,
                                      width: 50,
                                      child: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _selectedDate = null;
                                          });
                                        },
                                        tooltip: 'Reset tanggal',
                                        style: IconButton.styleFrom(
                                          backgroundColor: const Color(0xFFFEE2E2),
                                          foregroundColor: const Color(0xFFDC2626),
                                        ),
                                        icon: const Icon(
                                          Icons.close_rounded,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),

                              const SizedBox(height: 14),

                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      border: Border.all(
                                        color: const Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    child: filteredSales.isEmpty
                                        ? Center(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.search_off_rounded,
                                                  size: 44,
                                                  color: Color(0xFF94A3B8),
                                                ),
                                                const SizedBox(height: 12),
                                                Text(
                                                  _searchQuery.isEmpty && _selectedDate == null
                                                      ? 'Belum ada data penjualan'
                                                      : 'Data tidak ditemukan',
                                                  style: const TextStyle(
                                                    color: Color(0xFF64748B),
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : SingleChildScrollView(
                                            scrollDirection: Axis.vertical,
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: DataTable(
                                                headingRowColor: WidgetStateProperty.all(
                                                  const Color(0xFF0F172A),
                                                ),
                                                headingTextStyle: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                                dataTextStyle: const TextStyle(
                                                  color: Color(0xFF0F172A),
                                                  fontSize: 13,
                                                ),
                                                columnSpacing: 24,
                                                horizontalMargin: 18,
                                                columns: const [
                                                  DataColumn(
                                                    label: Text('No Faktur'),
                                                  ),
                                                  DataColumn(
                                                    label: Text('Tanggal'),
                                                  ),
                                                  DataColumn(
                                                    label: Text('Customer'),
                                                  ),
                                                  DataColumn(
                                                    label: Text('Jumlah Barang'),
                                                  ),
                                                  DataColumn(
                                                    label: Text('Total Penjualan'),
                                                  ),
                                                ],
                                                rows: filteredSales.map((data) {
                                                  return DataRow(
                                                    cells: [
                                                      DataCell(
                                                        Text(data.invoiceNumber),
                                                      ),
                                                      DataCell(
                                                        Text(
                                                          DateFormat('dd/MM/yyyy').format(
                                                            data.saleDate,
                                                          ),
                                                        ),
                                                      ),
                                                      DataCell(
                                                        Text(data.customerName),
                                                      ),
                                                      DataCell(
                                                        Text(
                                                          data.itemQuantity.toString(),
                                                        ),
                                                      ),
                                                      DataCell(
                                                        Text(
                                                          _currencyFormat.format(
                                                            data.totalSale,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 14),

                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/home',
                                    );
                                  },
                                  style:
                                      ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xFF0F172A),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(18),
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
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: Colors.white,
              size: 50,
            ),
            const SizedBox(height: 16),
            const Text(
              'Gagal mengambil data',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
            ),
          ],
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.16),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color:
                        Colors.white.withValues(alpha: 0.82),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}