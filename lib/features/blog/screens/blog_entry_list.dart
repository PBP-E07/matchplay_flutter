import 'package:flutter/material.dart';
import 'package:matchplay_flutter/features/blog/models/blog_entry.dart';
import 'package:matchplay_flutter/features/blog/screens/blog_detail.dart';
import 'package:matchplay_flutter/features/blog/widgets/blog_entry_card.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class BlogEntryListPage extends StatefulWidget {
  const BlogEntryListPage({super.key});

  @override
  State<BlogEntryListPage> createState() => _BlogEntryListPageState();
}

class _BlogEntryListPageState extends State<BlogEntryListPage> {
  // 1. Deklarasikan Future sebagai variabel state
  late Future<List<Blog>> _blogsFuture;

  @override
  void initState() {
    super.initState();
    // 2. Panggil fetchBlogs sekali saja di initState
    _blogsFuture = fetchBlogs(context.read<CookieRequest>());
  }

  Future<List<Blog>> fetchBlogs(CookieRequest request) async {
    // Menggunakan URL yang benar sesuai dengan urls.py Django
    final response = await request.get('http://localhost:8000/blog/json/');

    // Mengasumsikan responsnya adalah Map dengan key 'blogs'
    var data = response['blogs'];

    List<Blog> listBlog = [];
    for (var d in data) {
      if (d != null) {
        listBlog.add(Blog.fromJson(d));
      }
    }
    return listBlog;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog List'),
      ),
      body: FutureBuilder<List<Blog>>(
        // 4. Gunakan variabel Future yang sudah disimpan
        future: _blogsFuture,
        builder: (context, AsyncSnapshot<List<Blog>> snapshot) {
          // Logika builder yang lebih robust
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (_, index) => BlogEntryCard(
                blog: snapshot.data![index],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlogDetailPage(
                        blog: snapshot.data![index],
                      ),
                    ),
                  );
                },
              ),
            );
          } else {
            // Jika tidak ada data atau data kosong
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
