import 'package:flutter/material.dart';
import 'package:matchplay_flutter/features/fields/models/field.dart';

class FieldCard extends StatelessWidget {
  final Field field;

  const FieldCard({super.key, required this.field});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Placeholder: Link to detail page later
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Clicked on ${field.name}")),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white, // Ensure card background is white like the design
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Image Section
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  field.image, // Using 'image' from your model
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(
                        width: 90, 
                        height: 90, 
                        color: Colors.grey, 
                        child: Icon(Icons.broken_image, color: Colors.white)
                      ),
                ),
              ),
              const SizedBox(width: 16),
              
              // 2. Details Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Rating Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            field.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Display Rating from your model
                        Row(
                          children: [
                            const Icon(Icons.star, size: 16, color: Colors.amber),
                            Text(
                              field.rating.toString(),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    
                    // Price
                    Text(
                      "Mulai Rp. ${field.price} / Sesi",
                      style: const TextStyle(
                        fontSize: 14, 
                        fontWeight: FontWeight.w600,
                        color: Colors.black87
                      ),
                    ),
                    const SizedBox(height: 6),
                    
                    // Location with Icon
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF00C853)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            field.location,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
