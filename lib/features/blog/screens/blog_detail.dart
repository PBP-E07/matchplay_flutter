import 'package:flutter/material.dart';
import 'package:matchplay_flutter/features/blog/models/blog_entry.dart';

class BlogDetailPage extends StatelessWidget {final Blog blog;

const BlogDetailPage({super.key, required this.blog});

String _formatDate(DateTime date) {
  // Simple date formatter without intl package
  final months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

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
          // Thumbnail image
          if (blog.thumbnail.isNotEmpty)
            Image.network(
              'http://localhost:8000/blog/proxy-image/?url=${Uri.encodeComponent(blog.thumbnail)}',
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 250,
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.broken_image, size: 50),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  blog.title,
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Author and Date
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

                // Views count
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

                // Full content
                Text(
                  blog.summary,
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