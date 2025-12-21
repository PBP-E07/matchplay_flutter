import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import '../../../blog/models/blog_entry.dart';
import '../../../blog/services/blog_service.dart';

class BlogFormScreen extends StatefulWidget {
  final Blog? blog; // Null = Create, Not Null = Edit

  const BlogFormScreen({super.key, this.blog});

  @override
  State<BlogFormScreen> createState() => _BlogFormScreenState();
}

class _BlogFormScreenState extends State<BlogFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = BlogService();

  // Controllers
  final _titleController = TextEditingController();
  final _summaryController = TextEditingController();
  final _contentController = TextEditingController();
  final _thumbnailController = TextEditingController();
  final _authorController = TextEditingController();

  // Kategori hardcoded sesuai models.py Django
  final List<String> _categories = [
    'padel',
    'basket',
    'futsal',
    'badminton',
    'Health & Fitness',
  ];
  String? _selectedCategory;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Default category
    _selectedCategory = _categories.first;

    if (widget.blog != null) {
      // Edit Mode
      final b = widget.blog!;
      _titleController.text = b.title;
      _summaryController.text = b.summary;
      _contentController.text = b.content;
      _thumbnailController.text = b.thumbnail ?? '';
      _authorController.text = b.author;

      // Pastikan kategori ada di list, kalau tidak default ke index 0
      if (_categories.contains(b.category)) {
        _selectedCategory = b.category;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _contentController.dispose();
    _thumbnailController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final request = context.read<CookieRequest>();

    final data = {
      "title": _titleController.text,
      "summary": _summaryController.text,
      "content": _contentController.text,
      "thumbnail": _thumbnailController.text,
      "author": _authorController.text,
      "category": _selectedCategory,
    };

    bool success = false;
    try {
      if (widget.blog == null) {
        success = await _service.createBlog(request, data);
      } else {
        success = await _service.updateBlog(request, widget.blog!.id, data);
      }

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Blog berhasil disimpan!")),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Gagal menyimpan data.")));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.blog == null ? "Buat Artikel Baru" : "Edit Artikel"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: "Judul",
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _authorController,
                            decoration: const InputDecoration(
                              labelText: "Penulis",
                              border: OutlineInputBorder(),
                            ),
                            validator: (val) =>
                                val!.isEmpty ? "Wajib diisi" : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            decoration: const InputDecoration(
                              labelText: "Kategori",
                              border: OutlineInputBorder(),
                            ),
                            items: _categories
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) =>
                                setState(() => _selectedCategory = val),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _summaryController,
                      decoration: const InputDecoration(
                        labelText: "Ringkasan (Summary)",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        labelText: "Konten Lengkap",
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 8,
                      validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _thumbnailController,
                      decoration: const InputDecoration(
                        labelText: "URL Gambar (Optional)",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.blueAccent,
                        ),
                        onPressed: _submit,
                        child: Text(
                          widget.blog == null ? "PUBLISH" : "UPDATE",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
