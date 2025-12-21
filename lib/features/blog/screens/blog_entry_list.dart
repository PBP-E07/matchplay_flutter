import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:matchplay_flutter/features/blog/models/blog_entry.dart';
import 'package:matchplay_flutter/features/blog/screens/blog_detail.dart';
import 'package:matchplay_flutter/features/blog/screens/blog_form.dart';
import 'package:matchplay_flutter/features/blog/widgets/blog_entry_card.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class BlogEntryListPage extends StatefulWidget {
  const BlogEntryListPage({super.key});

  @override
  State<BlogEntryListPage> createState() => _BlogEntryListPageState();
}

class _BlogEntryListPageState extends State<BlogEntryListPage> {
  late Future<List<Blog>> _blogsFuture;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _blogsFuture = fetchBlogs(context.read<CookieRequest>());
    _pageController.addListener(() {
      if (_pageController.hasClients && _pageController.page != null) {
        setState(() {
          _currentPage = _pageController.page!.round();
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _refreshBlogs() {
    setState(() {
      _blogsFuture = fetchBlogs(context.read<CookieRequest>());
    });
    return _blogsFuture;
  }

  Future<List<Blog>> fetchBlogs(CookieRequest request) async {
    final response = await request.get('http://localhost:8000/blog/json/');

    var data = response['blogs'];

    List<Blog> listBlog = [];
    for (var d in data) {
      if (d != null) {
        listBlog.add(Blog.fromJson(d));
      }
    }

    listBlog.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return listBlog;
  }

  void _editBlog(Blog blog) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlogFormPage(blog: blog),
      ),
    ).then((_) => _refreshBlogs());
  }

  Future<void> _deleteBlog(Blog blog) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete "${blog.title}"?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm == true && mounted) {
      final request = context.read<CookieRequest>();
      final response = await request.postJson(
        'http://localhost:8000/blog/delete-flutter/${blog.id}/',
        jsonEncode(<String, String>{'message': 'delete'}), // Body can be simple
      );
      if (mounted) {
        if (response['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Blog post deleted successfully!')),
          );
          _refreshBlogs();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete: ${response['message'] ?? 'Unknown error'}')),
          );
        }
      }
    }
  }

  Future<void> _handleCardTap(Blog blog) async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.post(
        'http://localhost:8000/blog/increment-view/${blog.id}/',
        {},
      );
      if (response['status'] == 'success') {
        setState(() {
          blog.blogViews++;
        });
      }
    } catch (e) {
      debugPrint('Error incrementing view count: $e');
    }

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlogDetailPage(blog: blog),
        ),
      );
    }
  }

  Widget _buildCarousel(List<Blog> blogs) {
    final carouselBlogs = blogs.take(3).toList();
    if (carouselBlogs.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            itemCount: carouselBlogs.length,
            itemBuilder: (context, index) {
              final blog = carouselBlogs[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GestureDetector(
                  onTap: () => _handleCardTap(blog),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: (blog.thumbnail != null && blog.thumbnail!.isNotEmpty)
                        ? Image.network(
                      'http://localhost:8000/blog/proxy-image/?url=${Uri.encodeComponent(blog.thumbnail!)}',
                      fit: BoxFit.cover,
                      errorBuilder: (c, o, s) => const Center(child: Icon(Icons.error)),
                    )
                        : Container(
                      color: Colors.grey[300],
                      child: const Center(child: Icon(Icons.photo, color: Colors.grey)),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(carouselBlogs.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: _currentPage == index ? 24 : 8,
              decoration: BoxDecoration(
                color: _currentPage == index ? Colors.green : Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BlogFormPage()),
          ).then((_) => _refreshBlogs());
        },
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: FutureBuilder<List<Blog>>(
        future: _blogsFuture,
        builder: (context, AsyncSnapshot<List<Blog>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final blogs = snapshot.data!;
            return RefreshIndicator(
              onRefresh: _refreshBlogs,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(0, 24, 0, 80), // Space for FAB
                children: [
                  if (blogs.isNotEmpty) _buildCarousel(blogs),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
                    child: Text('Latest Article', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  if (blogs.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: blogs.length,
                        itemBuilder: (context, index) {
                          final blog = blogs[index];
                          return BlogEntryCard(
                            blog: blog,
                            onTap: () => _handleCardTap(blog),
                            onEdit: () => _editBlog(blog),
                            onDelete: () => _deleteBlog(blog),
                          );
                        },
                      ),
                    )
                  else
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text('There are no blog entries yet.', style: TextStyle(color: Colors.grey)),
                      ),
                    ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No data available.'));
          }
        },
      ),
    );
  }
}