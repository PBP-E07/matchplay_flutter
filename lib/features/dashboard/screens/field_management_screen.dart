import 'package:flutter/material.dart';
import '../../fields/models/field.dart';
import '../../fields/services/field_service.dart';
import 'field_form_screen.dart';
import 'package:matchplay_flutter/widgets/left_drawer.dart';

class FieldManagementScreen extends StatefulWidget {
  const FieldManagementScreen({super.key});

  @override
  State<FieldManagementScreen> createState() => _FieldManagementScreenState();
}

class _FieldManagementScreenState extends State<FieldManagementScreen> {
  final _service = FieldService();

  List<Field> _fields = [];
  bool _isLoading = true;
  String? _errorMessage;

  // State Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalData = 0;

  @override
  void initState() {
    super.initState();
    _fetchFields();
  }

  // 1. Mengambil Data dari Backend
  Future<void> _fetchFields({int page = 1}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _service.fetchFields(page: page);
      setState(() {
        _fields = response.fields;
        _currentPage = response.meta.currentPage;
        _totalPages = response.meta.totalPages;
        _totalData = response.meta.totalData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // 2. Navigasi ke Form (Create / Edit)
  // Menggunakan await untuk menunggu hasil: jika true (berhasil simpan), refresh list.
  void _openForm({Field? field}) async {
    final bool? refresh = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FieldFormScreen(field: field)),
    );

    if (refresh == true) {
      _fetchFields(page: _currentPage);
    }
  }

  // 3. Logika Delete
  void _confirmDelete(Field field) {
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
              Navigator.pop(context); // Tutup dialog dulu
              await _deleteField(field.id);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteField(int id) async {
    setState(() => _isLoading = true);
    try {
      final success = await _service.deleteField(id);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data berhasil dihapus')),
          );
        }
        // Refresh halaman
        _fetchFields(page: _currentPage);
      } else {
        throw Exception('Gagal menghapus data');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        actions: [
          // Tombol Refresh Manual
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _fetchFields(page: 1),
          ),
        ],
      ),

      drawer: const LeftDrawer(),

      // Tombol Tambah Data (+)
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(), // Tanpa parameter = Create Mode
        child: const Icon(Icons.add),
      ),
      body: _buildBody(),
      // Kontrol Pagination di Bawah
      bottomNavigationBar: _buildPaginationControls(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Terjadi Kesalahan:\n$_errorMessage',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _fetchFields(page: _currentPage),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_fields.isEmpty) {
      return const Center(child: Text('Belum ada data lapangan.'));
    }

    return ListView.builder(
      itemCount: _fields.length,
      padding: const EdgeInsets.only(
        bottom: 80,
      ), // Space agar tidak tertutup FAB
      itemBuilder: (context, index) {
        final field = _fields[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                field.image,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (ctx, error, stackTrace) => Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey,
                  child: const Icon(Icons.broken_image),
                ),
              ),
            ),
            title: Text(
              field.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${field.sport.toUpperCase()} • Rating: ${field.rating}'),
                Text(
                  'Rp ${field.price}',
                  style: const TextStyle(color: Colors.green),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tombol Edit
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _openForm(field: field),
                ),
                // Tombol Delete
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDelete(field),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaginationControls() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(blurRadius: 4, color: Colors.grey.withOpacity(0.2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Tombol Prev
          ElevatedButton(
            onPressed: _currentPage > 1
                ? () => _fetchFields(page: _currentPage - 1)
                : null,
            child: const Text('Prev'),
          ),

          // Info Halaman
          Text('Page $_currentPage of $_totalPages\n(Total: $_totalData)'),

          // Tombol Next
          ElevatedButton(
            onPressed: _currentPage < _totalPages
                ? () => _fetchFields(page: _currentPage + 1)
                : null,
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }
}
