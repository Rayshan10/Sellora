import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/sale.dart';
import '../services/sales_service.dart';
import '../theme/app_theme.dart';
import '../widgets/sidebar_widget.dart';
import '../widgets/stat_card_widget.dart';

class DashboardHomeScreen extends StatefulWidget {
  const DashboardHomeScreen({Key? key}) : super(key: key);

  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen> {
  int _selectedIndex = 0;

  late Future<List<Sale>> _salesFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  DateTime? _selectedDate;

  // Form controllers untuk Add/Edit
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _invoiceController = TextEditingController();
  final TextEditingController _customerController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();
  DateTime _selectedSaleDate = DateTime.now();
  bool _isFormLoading = false;

  // Edit/Delete state
  List<Sale> _sales = [];
  Sale? _selectedSale;
  bool _isLoadingSalesForEdit = false;

  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

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
    _invoiceController.dispose();
    _customerController.dispose();
    _quantityController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  void _loadSales() {
    _salesFuture = SalesService.getSales();
  }

  Future<void> _refreshSalesData() async {
    final sales = await SalesService.getSales();

    if (!mounted) return;

    setState(() {
      _sales = sales;
      _salesFuture = Future<List<Sale>>.value(sales);
    });
  }

  Future<void> _loadSalesForEdit() async {
    setState(() {
      _isLoadingSalesForEdit = true;
    });

    try {
      final sales = await SalesService.getSales();
      if (mounted) {
        setState(() {
          _sales = sales;
          _isLoadingSalesForEdit = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoadingSalesForEdit = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    }
  }

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

  Future<void> _selectSaleDateForForm() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedSaleDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null && picked != _selectedSaleDate) {
      setState(() {
        _selectedSaleDate = picked;
      });
    }
  }

  List<Sale> _filterSales(List<Sale> sales) {
    return sales.where((sale) {
      final invoiceNumber = sale.invoiceNumber.toLowerCase();
      final customerName = sale.customerName.toLowerCase();

      final matchesSearch = _searchQuery.isEmpty ||
          invoiceNumber.contains(_searchQuery) ||
          customerName.contains(_searchQuery);

      final matchesDate = _selectedDate == null ||
          (sale.saleDate.year == _selectedDate!.year &&
              sale.saleDate.month == _selectedDate!.month &&
              sale.saleDate.day == _selectedDate!.day);

      return matchesSearch && matchesDate;
    }).toList();
  }

  Future<void> _addSale() async {
    if (_isFormLoading) return;
    if (!_formKey.currentState!.validate()) return;

    final String invoiceNumber = _invoiceController.text.trim();
    final String customerName = _customerController.text.trim();
    final int? itemQuantity = int.tryParse(_quantityController.text.trim());
    final double? totalSale = double.tryParse(_totalController.text.trim());

    if (itemQuantity == null || totalSale == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jumlah barang atau total penjualan tidak valid'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isFormLoading = true;
    });

    try {
      await SalesService.createSale(
        invoiceNumber: invoiceNumber,
        saleDate: _selectedSaleDate,
        customerName: customerName,
        itemQuantity: itemQuantity,
        totalSale: totalSale,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data penjualan berhasil ditambahkan'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      _clearForm();
      await _refreshSalesData();
      if (!mounted) return;
      setState(() {
        _selectedIndex = 0;
      });
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
          _isFormLoading = false;
        });
      }
    }
  }

  void _clearForm() {
    _invoiceController.clear();
    _customerController.clear();
    _quantityController.clear();
    _totalController.clear();
    _selectedSaleDate = DateTime.now();
  }

  void _selectSale(Sale? sale) {
    if (sale == null) return;

    setState(() {
      _selectedSale = sale;
      _selectedSaleDate = sale.saleDate;
      _invoiceController.text = sale.invoiceNumber;
      _customerController.text = sale.customerName;
      _quantityController.text = sale.itemQuantity.toString();
      _totalController.text = sale.totalSale.toString();
    });
  }

  Future<void> _updateSale() async {
    if (_isFormLoading || _selectedSale == null) return;
    if (!_formKey.currentState!.validate()) return;

    final int? itemQuantity = int.tryParse(_quantityController.text.trim());
    final double? totalSale = double.tryParse(_totalController.text.trim());

    if (itemQuantity == null || totalSale == null) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isFormLoading = true;
    });

    try {
      await SalesService.updateSale(
        id: _selectedSale!.id,
        customerName: _customerController.text.trim(),
        saleDate: _selectedSaleDate,
        itemQuantity: itemQuantity,
        totalSale: totalSale,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data penjualan berhasil diperbarui'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      _clearForm();
      _selectedSale = null;
      await _refreshSalesData();
      if (!mounted) return;
      setState(() {
        _selectedIndex = 0;
      });
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
          _isFormLoading = false;
        });
      }
    }
  }

  Future<void> _deleteSale(Sale sale) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Data'),
        content: Text('Hapus transaksi ${sale.invoiceNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await SalesService.deleteSale(id: sale.id);

      if (!mounted) return;

      _clearForm();
      _selectedSale = null;
      await _refreshSalesData();

      if (!mounted) return;

      setState(() {
        _selectedIndex = 2;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data penjualan berhasil dihapus'),
          behavior: SnackBarBehavior.floating,
        ),
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
    }
  }

  void _onSidebarItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Clear form ketika pindah section
    if (index != 1 && index != 2) {
      _clearForm();
      _selectedSale = null;
    }

    // Load data untuk edit/delete
    if (index == 2) {
      _loadSalesForEdit();
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: const Text(
          'Sellora',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, size: 28, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        surfaceTintColor: Colors.transparent,
      ),
      drawer: SidebarWidget(
        currentIndex: _selectedIndex,
        onItemSelected: _onSidebarItemSelected,
      ),
      body: SafeArea(
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardView();
      case 1:
        return _buildAddSalesView();
      case 2:
        return _buildEditDeleteView();
      default:
        return _buildDashboardView();
    }
  }

  Widget _buildDashboardView() {
    return Container(
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
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: _buildHeaderCard(
              title: 'Dashboard Penjualan',
              subtitle: 'Ringkasan transaksi dan omzet penjualan',
              icon: Icons.analytics_rounded,
            ),
          ),

          // Content
          Expanded(
            child: FutureBuilder<List<Sale>>(
              future: _salesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: Colors.white.withValues(alpha: 0.7),
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Terjadi kesalahan',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final sales = snapshot.data ?? [];
                final filteredSales = _filterSales(sales);

                final int totalTransactions = filteredSales.length;
                final double totalRevenue = filteredSales.fold(
                  0,
                  (sum, data) => sum + data.totalSale,
                );

                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats Cards
                      Row(
                        children: [
                          Expanded(
                            child: StatCardWidget(
                              label: 'Transaksi',
                              value: totalTransactions.toString(),
                              icon: Icons.receipt_long_rounded,
                              accentColor: const Color(0xFF1D4ED8),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatCardWidget(
                              label: 'Omzet',
                              value: _currencyFormat.format(totalRevenue),
                              icon: Icons.payments_rounded,
                              accentColor: const Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Search and Filter
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Cari invoice atau pelanggan...',
                                prefixIcon: const Icon(Icons.search_rounded),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppTheme.borderColor,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppTheme.borderColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Material(
                            color: Colors.transparent,
                            child: Ink(
                              decoration: BoxDecoration(
                                color: AppTheme.lightBackground,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.borderColor,
                                ),
                              ),
                              child: InkWell(
                                onTap: _selectDate,
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Icon(
                                    Icons.calendar_month_rounded,
                                    color: _selectedDate != null
                                        ? const Color(0xFF1D4ED8)
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Material(
                            color: Colors.transparent,
                            child: Ink(
                              decoration: BoxDecoration(
                                color: AppTheme.lightBackground,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.borderColor,
                                ),
                              ),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedDate = null;
                                    _searchController.clear();
                                  });
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Icon(
                                    Icons.close_rounded,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Data Table
                      Expanded(
                        child: filteredSales.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.inbox_rounded,
                                      size: 48,
                                      color: Colors.grey.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Tidak ada data',
                                      style: TextStyle(
                                        color: Colors.grey.withValues(
                                          alpha: 0.7,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : SingleChildScrollView(
                                child: DataTable(
                                  headingRowColor: WidgetStateProperty.all(
                                    AppTheme.lightBackground,
                                  ),
                                  columns: const [
                                    DataColumn(label: Text('Invoice')),
                                    DataColumn(label: Text('Pelanggan')),
                                    DataColumn(label: Text('Jumlah')),
                                    DataColumn(label: Text('Total')),
                                  ],
                                  rows: filteredSales
                                      .map(
                                        (sale) => DataRow(
                                          cells: [
                                            DataCell(
                                              Text(
                                                sale.invoiceNumber,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Text(sale.customerName),
                                            ),
                                            DataCell(
                                              Text(
                                                '${sale.itemQuantity}',
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                _currencyFormat.format(
                                                  sale.totalSale,
                                                ),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF10B981),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddSalesView() {
    return Container(
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
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: _buildHeaderCard(
              title: 'Tambah Penjualan',
              subtitle: 'Masukkan data transaksi penjualan baru',
              icon: Icons.add_chart_rounded,
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(0, 8, 0, 0),
              padding: const EdgeInsets.all(20),
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
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    const Text(
                      'Form Transaksi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _invoiceController,
                      enabled: !_isFormLoading,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'No Faktur Penjualan',
                        prefixIcon: Icon(Icons.receipt_long_rounded),
                        hintText: 'Masukkan nomor faktur',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Harap isi nomor faktur';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: _isFormLoading
                          ? null
                          : () => _selectSaleDateForForm(),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Tanggal Penjualan',
                          prefixIcon: const Icon(
                            Icons.calendar_month_rounded,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppTheme.borderColor,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppTheme.borderColor,
                            ),
                          ),
                        ),
                        child: Text(
                          DateFormat('dd/MM/yyyy').format(
                            _selectedSaleDate,
                          ),
                          style: const TextStyle(
                            color: AppTheme.textDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _customerController,
                      enabled: !_isFormLoading,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Nama Pelanggan',
                        prefixIcon: Icon(Icons.person_rounded),
                        hintText: 'Masukkan nama pelanggan',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Harap isi nama pelanggan';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _quantityController,
                      enabled: !_isFormLoading,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Jumlah Barang',
                        prefixIcon: Icon(Icons.inventory_2_rounded),
                        hintText: 'Masukkan jumlah barang',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Harap isi jumlah barang';
                        }
                        if (int.tryParse(value.trim()) == null) {
                          return 'Jumlah harus berupa angka';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _totalController,
                      enabled: !_isFormLoading,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Total Penjualan (Rp)',
                        prefixIcon: Icon(Icons.payments_rounded),
                        hintText: 'Masukkan total penjualan',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Harap isi total penjualan';
                        }
                        if (double.tryParse(value.trim()) == null) {
                          return 'Total harus berupa angka';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isFormLoading ? null : _addSale,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D4ED8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isFormLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Simpan Data',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildEditDeleteView() {
    return Container(
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
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: _buildHeaderCard(
              title: 'Edit & Hapus Penjualan',
              subtitle: 'Perbarui atau hapus data transaksi penjualan',
              icon: Icons.edit_rounded,
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(0, 8, 0, 0),
              padding: const EdgeInsets.all(20),
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
              child: _isLoadingSalesForEdit
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_selectedSale == null) ...[
                            const Text(
                              'Pilih Data untuk Diubah',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _sales.isEmpty
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 24,
                                    ),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.inbox_rounded,
                                            size: 48,
                                            color: Colors.grey.withValues(
                                              alpha: 0.5,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          const Text('Tidak ada data'),
                                        ],
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: _sales.length,
                                    itemBuilder: (context, index) {
                                      final sale = _sales[index];
                                      return Card(
                                        color: Colors.white,
                                        child: ListTile(
                                          leading: const Icon(
                                            Icons.receipt_rounded,
                                            color: Colors.grey,
                                          ),
                                          title: Text(
                                            sale.invoiceNumber,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          subtitle: Text(
                                            '${sale.customerName} - ${_currencyFormat.format(sale.totalSale)}',
                                          ),
                                          onTap: () => _selectSale(sale),
                                        ),
                                      );
                                    },
                                  ),
                          ],
                          if (_selectedSale != null) ...[
                            const SizedBox(height: 4),
                            const Divider(),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Detail & Perubahan',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: _isFormLoading
                                      ? null
                                      : () {
                                          setState(() {
                                            _selectedSale = null;
                                            _clearForm();
                                          });
                                        },
                                  icon: const Icon(Icons.swap_horiz_rounded),
                                  label: const Text('Ganti Data'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Form(
                              key: _formKey,
                              child: ListView(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                children: [
                                  TextFormField(
                                    controller: _invoiceController,
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                      labelText: 'No Faktur',
                                      prefixIcon: Icon(Icons.receipt_rounded),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: _isFormLoading
                                        ? null
                                        : () => _selectSaleDateForForm(),
                                    child: InputDecorator(
                                      decoration: InputDecoration(
                                        labelText: 'Tanggal Penjualan',
                                        prefixIcon: const Icon(
                                          Icons.calendar_month_rounded,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: AppTheme.borderColor,
                                          ),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: AppTheme.borderColor,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        DateFormat('dd/MM/yyyy').format(
                                          _selectedSaleDate,
                                        ),
                                        style: const TextStyle(
                                          color: AppTheme.textDark,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _customerController,
                                    enabled: !_isFormLoading,
                                    decoration: const InputDecoration(
                                      labelText: 'Nama Pelanggan',
                                      prefixIcon: Icon(Icons.person_rounded),
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Wajib diisi';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _quantityController,
                                    enabled: !_isFormLoading,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Jumlah Barang',
                                      prefixIcon: Icon(
                                        Icons.inventory_2_rounded,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Wajib diisi';
                                      }
                                      if (int.tryParse(value.trim()) == null) {
                                        return 'Harus angka';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _totalController,
                                    enabled: !_isFormLoading,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Total Penjualan',
                                      prefixIcon: Icon(Icons.payments_rounded),
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Wajib diisi';
                                      }
                                      if (double.tryParse(value.trim()) ==
                                          null) {
                                        return 'Harus angka';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: _isFormLoading
                                              ? null
                                              : _updateSale,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF10B981,
                                            ),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Text(
                                            'Update',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: _isFormLoading
                                              ? null
                                              : () => _deleteSale(
                                                    _selectedSale!,
                                                  ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFFEF4444,
                                            ),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Text(
                                            'Hapus',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'v1.0',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
