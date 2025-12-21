import 'package:flutter/material.dart';
import 'package:matchplay_flutter/features/blog/models/blog_entry.dart';
import 'package:matchplay_flutter/config.dart';

class BlogDetailPage extends StatelessWidget {
  final Blog blog;

  const BlogDetailPage({super.key, required this.blog});

  String _formatDate(DateTime date) {
    final dateInGmtPlus7 = date.toUtc().add(const Duration(hours: 7));
    
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dateInGmtPlus7.day} ${months[dateInGmtPlus7.month - 1]} ${dateInGmtPlus7.year}';
  }

  static const String blogUrl = "${AppConfig.baseUrl}/blog/";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog Detail'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (blog.thumbnail != null && blog.thumbnail!.isNotEmpty)
              Image.network(
                '${blogUrl}proxy-image/?url=${Uri.encodeComponent(blog.thumbnail!)}',
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 250,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                  ),
                ),
              )
            else
              Container(
                height: 250,
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.photo, size: 50, color: Colors.grey),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    blog.title,
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Text(
                        'by ${blog.author}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo.shade700,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _formatDate(blog.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Icon(Icons.visibility, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${blog.blogViews} views',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 32),

                  Text(
                    blog.content, // Corrected from blog.summary
                    style: const TextStyle(
                      fontSize: 16.0,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
