import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:matchplay_flutter/features/blog/models/blog_entry.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class BlogFormPage extends StatefulWidget {
  final Blog? blog;
  const BlogFormPage({super.key, this.blog});

  @override
  State<BlogFormPage> createState() => _BlogFormPageState();
}

class _BlogFormPageState extends State<BlogFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _summaryController;
  late TextEditingController _contentController;
  late TextEditingController _thumbnailController;
  String? _selectedCategory;

  final List<Map<String, String>> _categories = [
    {'value': 'padel', 'display': 'Padel'},
    {'value': 'basket', 'display': 'Basket'},
    {'value': 'futsal', 'display': 'Futsal'},
    {'value': 'badminton', 'display': 'Badminton'},
    {'value': 'Health & Fitness', 'display': 'Health & Fitness'},
  ];

  bool get _isEditing => widget.blog != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.blog?.title ?? "");
    _authorController = TextEditingController(text: widget.blog?.author ?? "");
    _summaryController = TextEditingController(text: widget.blog?.summary ?? "");
    _contentController = TextEditingController(text: widget.blog?.content ?? "");
    _thumbnailController = TextEditingController(text: widget.blog?.thumbnail ?? "");
    _selectedCategory = widget.blog?.category ?? 'padel'; // Set default to 'padel'
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _summaryController.dispose();
    _contentController.dispose();
    _thumbnailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Blog Post' : 'Create New Blog Post'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: "Blog Title",
                    labelText: "Blog Title",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Title cannot be empty!";
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: "Category",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                  ),
                  items: _categories.map<DropdownMenuItem<String>>((Map<String, String> category) {
                    return DropdownMenuItem<String>(
                      value: category['value'],
                      child: Text(category['display']!),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  },
                  validator: (value) => value == null ? 'Please select a category' : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _authorController,
                  decoration: const InputDecoration(
                    hintText: "Author",
                    labelText: "Author",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Author cannot be empty!";
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    hintText: "What are you thinking about?",
                    labelText: "Content",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Content cannot be empty!";
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _thumbnailController,
                  decoration: const InputDecoration(
                    hintText: "Thumbnail URL (Optional)",
                    labelText: "Thumbnail URL",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                  ),
                  // Validator removed as it is now optional
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final url = _isEditing
                            ? "http://localhost:8000/blog/edit-flutter/${widget.blog!.id}/"
                            : "http://localhost:8000/blog/create-flutter/";
                        
                        final response = await request.postJson(
                            url,
                            jsonEncode(<String, String?>{
                              '_method': _isEditing ? 'PUT' : 'POST',
                              'title': _titleController.text,
                              'author': _authorController.text,
                              'summary': _summaryController.text,
                              'content': _contentController.text,
                              'thumbnail': _thumbnailController.text,
                              'category': _selectedCategory,
                            }));
                        if (context.mounted) {
                           if (response['status'] == 'success') {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Blog post has been ${_isEditing ? 'updated' : 'saved'}!"),
                            ));
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content:
                                  Text("Something went wrong, please try again."),
                            ));
                          }
                        }                        
                      }
                    },
                    child: const Text("Submit"),
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
