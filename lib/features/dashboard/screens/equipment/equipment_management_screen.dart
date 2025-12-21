import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

// Equipment
import '../../../equipment/models/equipment.dart';
import '../../../equipment/services/equipment_service.dart';

// Shared Widgets
import '../../widgets/dashboard_stats.dart';
import '../../widgets/admin_toolbar.dart';
import '../../widgets/admin_filter_dialog.dart';
import '../../widgets/pagination_bar.dart';

// Screens
import 'equipment_form_screen.dart';

// Components
import 'components/equipment_table.dart';

class EquipmentManagementScreen extends StatefulWidget {
  const EquipmentManagementScreen({super.key});

  @override
  State<EquipmentManagementScreen> createState() =>
      _EquipmentManagementScreenState();
}

class _EquipmentManagementScreenState extends State<EquipmentManagementScreen> {
  final _service = EquipmentService();

  List<Equipment> _equipments = [];
  bool _isLoading = true;

  // Pagination & Meta
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalData = 0;
  int _perPage = 10;
  final List<int> _pageSizeList = [5, 10, 20, 50];

  // Stats
  double _avgPrice = 0.0;
  int _totalQty = 0;

  // Filter State
  int? _filterMinPrice;
  int? _filterMaxPrice;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData({int page = 1}) async {
    setState(() => _isLoading = true);

    final request = context.read<CookieRequest>();
    try {
      final result = await _service.fetchEquipments(
        request,
        page: page,
        perPage: _perPage,
        minPrice: _filterMinPrice,
        maxPrice: _filterMaxPrice,
      );

      if (!mounted) return;

      setState(() {
        _equipments = result['data'];
        final meta = result['meta'];
        _totalData = meta['total_data'];
        _totalPages = meta['total_pages'];
        _currentPage = meta['current_page'];
        _avgPrice = meta['avg_price'];
        _totalQty = meta['total_qty'];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // Navigasi ke Form (Create / Edit)
  void _openForm({Equipment? equipment}) async {
    final bool? refresh = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EquipmentFormScreen(equipment: equipment),
      ),
    );

    // Jika berhasil simpan (return true), refresh data
    if (refresh == true) {
      _fetchData(page: _currentPage);
    }
  }

  void _showFilterDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AdminFilterDialog(
        currentMin: _filterMinPrice,
        currentMax: _filterMaxPrice,
        categories: null, // Equipment tidak pakai kategori
      ),
    );

    if (result != null) {
      setState(() {
        _filterMinPrice = result['minPrice'];
        _filterMaxPrice = result['maxPrice'];
        _currentPage = 1;
      });
      _fetchData(page: 1);
    }
  }

  void _onDelete(Equipment item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Hapus alat "${item.fields.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              final request = context.read<CookieRequest>();
              bool success = await _service.deleteEquipment(request, item.pk);
              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Berhasil dihapus")),
                  );
                  _fetchData(page: _currentPage);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Gagal menghapus")),
                  );
                }
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _equipments.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () async => await _fetchData(page: 1),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Equipment Dashboard",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 24),

                // Stats
                DashboardStats(
                  // Kartu 1: Equipments
                  totalLabel: "Total Equipments",
                  icon1: Icons.sports_tennis,
                  totalData: _totalData,

                  // Kartu 2: Price
                  avgPrice: _avgPrice,
                  avgPriceLabel: "Average Price/Hour",
                  isCurrency: true,
                  icon2: Icons.attach_money,

                  // Kartu 3: Quatity
                  avgRating: _totalQty.toDouble(),
                  avgRatingLabel: "Total Quantity",
                  icon3: Icons.inventory_2,
                  isCard3Int: true,
                ),

                const SizedBox(height: 32),
                const Text(
                  "Daftar Alat Olahraga",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Toolbar
                AdminToolbar(
                  onAddPressed: () => _openForm(),
                  onFilterPressed: _showFilterDialog,
                  totalData: _totalData,
                  currentPage: _currentPage,
                  perPage: _perPage,
                  pageSizeList: _pageSizeList,
                  addButtonLabel: "Tambah Alat",
                  onPerPageChanged: (val) {
                    setState(() {
                      _perPage = val;
                      _currentPage = 1;
                    });
                    _fetchData(page: 1);
                  },
                ),

                const SizedBox(height: 16),

                // Table
                EquipmentTable(
                  equipments: _equipments,
                  onEdit: (item) => _openForm(equipment: item),
                  onDelete: _onDelete,
                ),

                const SizedBox(height: 24),

                // Pagination
                if (_totalPages > 1)
                  PaginationBar(
                    currentPage: _currentPage,
                    totalPages: _totalPages,
                    onPageChanged: (page) => _fetchData(page: page),
                  ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
