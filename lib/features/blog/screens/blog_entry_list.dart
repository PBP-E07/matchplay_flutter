import 'package:flutter/material.dart';
import 'package:matchplay_flutter/features/blog/models/blog_entry.dart';
import 'package:matchplay_flutter/features/blog/screens/blog_detail.dart';
import 'package:matchplay_flutter/features/blog/screens/blog_form.dart';
import 'package:matchplay_flutter/features/blog/widgets/blog_entry_card.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

class BlogEntryListPage extends StatefulWidget {
  const BlogEntryListPage({super.key});

  @override
  State<BlogEntryListPage> createState() => _BlogEntryListPageState();
}

class _BlogEntryListPageState extends State<BlogEntryListPage> {
  late Future<List<Blog>> _blogsFuture;

  @override
  void initState() {
    super.initState();
    _blogsFuture = fetchBlogs(context.read<CookieRequest>());
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
    return listBlog;
  }

  Future<void> deleteBlog(BuildContext context, CookieRequest request, String id) async {
    final response = await request.postJson(
      "http://localhost:8000/blog/delete-flutter/$id/",
      jsonEncode({
        "_method": "DELETE",
      }),
    );

    if (!context.mounted) return;

    if (response['status'] == 'ok') {
      _refreshBlogs();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Blog entry deleted successfully.")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to delete blog entry. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BlogFormPage()),
          ).then((_) => _refreshBlogs());
        },
        child: const Icon(Icons.add),
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
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Blog',
                          style: TextStyle(
                              fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Menampilkan ${blogs.length} Artikel',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                if (blogs.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.all(12.0),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 400.0,
                        mainAxisSpacing: 16.0,
                        crossAxisSpacing: 16.0,
                        childAspectRatio: 0.9,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          final blog = blogs[index];
                          return BlogEntryCard(
                            blog: blog,
                            onReadMore: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      BlogDetailPage(blog: blog),
                                ),
                              );
                            },
                            onEdit: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BlogFormPage(blog: blog),
                                ),
                              ).then((_) => _refreshBlogs());
                            },
                            onDelete: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Confirm Deletion'),
                                    content: const Text(
                                        'Are you sure you want to delete this blog entry?'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('Cancel'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: const Text('Delete'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          deleteBlog(
                                              context,
                                              context.read<CookieRequest>(),
                                              blog.id);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          );
                        },
                        childCount: blogs.length,
                      ),
                    ),
                  )
                else
                  const SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'There are no blog entries yet.',
                        style:
                            TextStyle(fontSize: 20, color: Color(0xff59A5D8)),
                      ),
                    ),
                  ),
              ],
            );
          } else {
            return const Center(
              child: Text(
                'There are no blog entries yet.',
                style: TextStyle(fontSize: 20, color: Color(0xff59A5D8)),
              ),
            );
          }
        },
      ),
    );
  }
}
