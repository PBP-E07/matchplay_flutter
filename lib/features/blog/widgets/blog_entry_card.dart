
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:matchplay_flutter/features/blog/models/blog_entry.dart';

class BlogEntryCard extends StatelessWidget {
  final Blog blog;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BlogEntryCard({
    super.key,
    required this.blog,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  String _capitalize(String s) => s.isEmpty ? '' : s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: InkWell(
        onTap: onTap, // Keep the main tap for navigation
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _capitalize(blog.category),
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      blog.title,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('d MMMM yyyy').format(blog.createdAt),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        InkWell(
                          onTap: onEdit,
                          child: const Row(
                            children: [
                              Icon(Icons.edit, size: 16, color: Colors.blue),
                              SizedBox(width: 4),
                              Text('Edit', style: TextStyle(color: Colors.blue, fontSize: 12)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        InkWell(
                          onTap: onDelete,
                          child: const Row(
                            children: [
                              Icon(Icons.delete, size: 16, color: Colors.red),
                              SizedBox(width: 4),
                              Text('Delete', style: TextStyle(color: Colors.red, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: (blog.thumbnail != null && blog.thumbnail!.isNotEmpty)
                    ? Image.network(
                        'http://localhost:8000/blog/proxy-image/?url=${Uri.encodeComponent(blog.thumbnail!)}',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey[200],
                          child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                        ),
                      )
                    : Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[200],
                        child: const Center(child: Icon(Icons.photo, color: Colors.grey)),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
