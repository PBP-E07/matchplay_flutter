import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

// Imports Feature Blog
import '../../../../features/blog/models/blog_entry.dart';
import '../../../../features/blog/services/blog_service.dart';

// Import Screens
import 'blog_form_screen.dart';

// Imports Shared Widgets (Dashboard)
import '../../widgets/dashboard_stats.dart';
import '../../widgets/admin_toolbar.dart';
import '../../widgets/admin_filter_dialog.dart';
import '../../widgets/pagination_bar.dart';

// Local Component
import 'components/blog_table.dart';

class BlogManagementScreen extends StatefulWidget {
  const BlogManagementScreen({super.key});

  @override
  State<BlogManagementScreen> createState() => _BlogManagementScreenState();
}

class _BlogManagementScreenState extends State<BlogManagementScreen> {
  final _service = BlogService();

  List<Blog> _blogs = [];
  bool _isLoading = true;

  // Pagination & Meta
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalData = 0;
  int _perPage = 10;
  final List<int> _pageSizeList = [5, 10, 20];

  // Stats
  int _totalViews = 0;
  int _totalAuthors = 0;

  // Filter
  String? _filterCategory;
  int? _filterMinViews;
  int? _filterMaxViews;

  // Categories for Filter Dialog
  final List<Map<String, String>> _filterCategories = [
    {'value': 'padel', 'label': 'Padel'},
    {'value': 'basket', 'label': 'Basket'},
    {'value': 'futsal', 'label': 'Futsal'},
    {'value': 'badminton', 'label': 'Badminton'},
    {'value': 'Health & Fitness', 'label': 'Health & Fitness'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData({int page = 1}) async {
    setState(() => _isLoading = true);
    final request = context.read<CookieRequest>();

    try {
      final result = await _service.fetchBlogs(
        request,
        page: page,
        perPage: _perPage,
        category: _filterCategory,
        minViews: _filterMinViews,
        maxViews: _filterMaxViews,
      );

      if (!mounted) return;

      setState(() {
        _blogs = List<Blog>.from(result['data']);
        final meta = result['meta'];
        _totalData = meta['total_data'];
        _totalPages = meta['total_pages'];
        _currentPage = meta['current_page'];
        _totalViews = meta['total_views'];
        _totalAuthors = meta['total_authors'];
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

  void _showFilterDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AdminFilterDialog(
        currentCategory: _filterCategory,
        currentMin: _filterMinViews,
        currentMax: _filterMaxViews,
        categories: _filterCategories,
        rangeTitle: "Jumlah Views",
      ),
    );

    if (result != null) {
      setState(() {
        _filterCategory = result['category'];
        _filterMinViews = result['min'];
        _filterMaxViews = result['max'];
        _currentPage = 1;
      });
      _fetchData(page: 1);
    }
  }

  void _onDelete(Blog item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Artikel'),
        content: Text('Yakin ingin menghapus artikel "${item.title}"?'),
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
              bool success = await _service.deleteBlog(request, item.id);
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

  void _openForm({Blog? blog}) async {
    final bool? refresh = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BlogFormScreen(blog: blog)),
    );
    if (refresh == true) {
      _fetchData(page: _currentPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _blogs.isEmpty) {
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
                  "Blog Dashboard",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 24),

                // Stats Card
                DashboardStats(
                  // Kartu 1: Articles
                  icon1: Icons.article,
                  totalData: _totalData,
                  totalLabel: "Total Articles",

                  // Kartu 2: Authors
                  avgPrice: _totalAuthors.toDouble(),
                  avgPriceLabel: "Total Authors",
                  isCurrency: false,
                  icon2: Icons.people,

                  // Kartu 3: Views
                  avgRating: _totalViews.toDouble(),
                  avgRatingLabel: "Total Views",
                  icon3: Icons.visibility,
                  isCard3Int: true,
                ),

                const SizedBox(height: 32),
                const Text(
                  "Daftar Artikel",
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
                  addButtonLabel: "Tulis Artikel",
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
                BlogTable(
                  blogs: _blogs,
                  onEdit: (item) => _openForm(blog: item),
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
