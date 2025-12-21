import 'package:flutter/material.dart';
import 'package:matchplay_flutter/features/blog/screens/blog_entry_list.dart';

class BlogPage extends StatelessWidget {
  const BlogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BlogEntryListPage()),
            );
          },
          child: const Text('See Blog List'),
        ),
      ),
    );
  }
}
