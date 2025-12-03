import 'package:flutter/material.dart';
import 'package:matchplay_flutter/features/blog/models/blog_entry.dart';

class BlogEntryCard extends StatelessWidget {
  final Blog blog;
  final VoidCallback onReadMore;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BlogEntryCard({
    super.key,
    required this.blog,
    required this.onReadMore,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: Image.network(
              'http://localhost:8000/blog/proxy-image/?url=${Uri.encodeComponent(blog.thumbnail)}',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[300],
                child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        blog.title,
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        blog.summary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          InkWell(
                            onTap: onEdit,
                            child: Row(
                              children: const [
                                Icon(Icons.edit_square, size: 16),
                                SizedBox(width: 4),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          InkWell(
                            onTap: onDelete,
                            child: Row(
                              children: const [
                                Icon(Icons.delete, size: 16),
                                SizedBox(width: 4),
                                Text('Delete'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: onReadMore,
                        child: const Text('Read More'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
