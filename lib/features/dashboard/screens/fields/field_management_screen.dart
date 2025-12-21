import 'package:flutter/material.dart';
import '../../../fields/models/field.dart';
import '../../../fields/services/field_service.dart';
import 'field_form_screen.dart';

// Components
import 'components/dashboard_stats.dart';
import 'components/field_table.dart';
import 'components/pagination_bar.dart';
import 'components/field_filter_dialog.dart';
import 'components/field_toolbar.dart';

class FieldManagementScreen extends StatefulWidget {
  const FieldManagementScreen({super.key});

  @override
  State<FieldManagementScreen> createState() => _FieldManagementScreenState();
}

class _FieldManagementScreenState extends State<FieldManagementScreen> {
  final _service = FieldService();

  // Data State
  List<Field> _fields = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Pagination & Meta State
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalData = 0;
  int _perPage = 20;
  final List<int> _pageSizeList = [5, 10, 20, 50, 100];
  double _avgPrice = 0.0;
  double _avgRating = 0.0;

  // Filter State
  String? _filterCategory;
  int? _filterMinPrice;
  int? _filterMaxPrice;

  // Static Data untuk Dialog
  final List<Map<String, String>> _sportCategories = [
    {'value': 'badminton', 'label': 'Badminton'},
    {'value': 'basketball', 'label': 'Basketball'},
    {'value': 'billiard', 'label': 'Billiard'},
    {'value': 'e-sport', 'label': 'E-Sport'},
    {'value': 'futsal', 'label': 'Futsal'},
    {'value': 'golf', 'label': 'Golf'},
    {'value': 'mini soccer', 'label': 'Mini Soccer'},
    {'value': 'padel', 'label': 'Padel'},
    {'value': 'pickleball', 'label': 'Pickleball'},
    {'value': 'sepak bola', 'label': 'Sepak Bola'},
    {'value': 'squash', 'label': 'Squash'},
    {'value': 'tenis meja', 'label': 'Tenis Meja'},
    {'value': 'tennis', 'label': 'Tennis'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchFields();
  }

  // --- LOGIC SECTION ---

  Future<void> _fetchFields({int page = 1}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _service.fetchFields(
        page: page,
        perPage: _perPage,
        category: _filterCategory,
        minPrice: _filterMinPrice,
        maxPrice: _filterMaxPrice,
      );

      setState(() {
        _fields = response.fields;
        _currentPage = response.meta.currentPage;
        _totalPages = response.meta.totalPages;
        _totalData = response.meta.totalData;
        _avgPrice = response.meta.avgPrice;
        _avgRating = response.meta.avgRating;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _openAddForm() async {
    final bool? refresh = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FieldFormScreen()),
    );
    if (refresh == true) _fetchFields(page: _currentPage);
  }

  void _openEditForm(Field field) async {
    final bool? refresh = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FieldFormScreen(field: field)),
    );
    if (refresh == true) _fetchFields(page: _currentPage);
  }

  void _showFilterDialog() async {
    // Membuka Dialog yang sudah di-extract
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => FieldFilterDialog(
        currentCategory: _filterCategory,
        currentMinPrice: _filterMinPrice,
        currentMaxPrice: _filterMaxPrice,
        categories: _sportCategories,
      ),
    );

    // Jika user klik Apply (result tidak null)
    if (result != null) {
      setState(() {
        _filterCategory = result['category'];
        _filterMinPrice = result['minPrice'];
        _filterMaxPrice = result['maxPrice'];
        _currentPage = 1; // Reset halaman
      });
      _fetchFields(page: 1);
    }
  }

  void _onDeletePressed(Field field) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Yakin ingin menghapus "${field.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await _processDelete(field.id);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _processDelete(int id) async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Menghapus...')));
    try {
      final success = await _service.deleteField(id);
      if (success) {
        if (mounted) ScaffoldMessenger.of(context).hideCurrentSnackBar();
        _fetchFields(page: _currentPage);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  // --- UI SECTION ---

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _fields.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Error: $_errorMessage",
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _fetchFields(page: 1),
              child: const Text("Coba Lagi"),
            ),
          ],
        ),
      );
    }

    // Bungkus dengan RefreshIndicator agar user bisa tarik untuk refresh
    return RefreshIndicator(
      onRefresh: () async {
        await _fetchFields(page: 1);
      },
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: SingleChildScrollView(
            // Penting: AlwaysScrollableScrollPhysics agar RefreshIndicator bekerja
            // meskipun kontennya sedikit
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Sports Field Dashboard",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 24),

                // Stats
                DashboardStats(
                  totalData: _totalData,
                  avgPrice: _avgPrice,
                  avgRating: _avgRating,
                ),
                const SizedBox(height: 32),

                const Text(
                  "Daftar Lapangan",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                FieldToolbar(
                  onAddPressed: _openAddForm,
                  onFilterPressed: _showFilterDialog,
                  totalData: _totalData,
                  currentPage: _currentPage,
                  perPage: _perPage,
                  pageSizeList: _pageSizeList,
                  onPerPageChanged: (val) {
                    setState(() {
                      _perPage = val;
                      _currentPage = 1;
                    });
                    _fetchFields(page: 1);
                  },
                ),

                const SizedBox(height: 16),

                FieldTable(
                  fields: _fields,
                  onEdit: _openEditForm,
                  onDelete: _onDeletePressed,
                ),

                const SizedBox(height: 24),

                if (_totalPages > 1)
                  PaginationBar(
                    currentPage: _currentPage,
                    totalPages: _totalPages,
                    onPageChanged: (page) => _fetchFields(page: page),
                  ),

                // Tambahkan padding bawah agar tidak terlalu mepet
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
