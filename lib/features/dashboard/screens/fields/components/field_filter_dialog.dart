import 'package:flutter/material.dart';

class FieldFilterDialog extends StatefulWidget {
  final String? currentCategory;
  final int? currentMinPrice;
  final int? currentMaxPrice;
  final List<Map<String, String>> categories;

  const FieldFilterDialog({
    super.key,
    this.currentCategory,
    this.currentMinPrice,
    this.currentMaxPrice,
    required this.categories,
  });

  @override
  State<FieldFilterDialog> createState() => _FieldFilterDialogState();
}

class _FieldFilterDialogState extends State<FieldFilterDialog> {
  late TextEditingController _minPriceController;
  late TextEditingController _maxPriceController;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _minPriceController = TextEditingController(
      text: widget.currentMinPrice?.toString() ?? '',
    );
    _maxPriceController = TextEditingController(
      text: widget.currentMaxPrice?.toString() ?? '',
    );
    _selectedCategory = widget.currentCategory;
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _applyFilter() {
    // Kembalikan data ke halaman utama dalam bentuk Map
    Navigator.pop(context, {
      'category': _selectedCategory,
      'minPrice': int.tryParse(_minPriceController.text),
      'maxPrice': int.tryParse(_maxPriceController.text),
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Filter Lapangan"),
      actionsAlignment: MainAxisAlignment.center,
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kategori
            const Text(
              "Sport Category",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text("All")),
                ...widget.categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat['value'],
                    child: Text(cat['label']!),
                  );
                }),
              ],
              onChanged: (val) => setState(() => _selectedCategory = val),
            ),

            const SizedBox(height: 16),

            // Harga
            const Text(
              "Price Range (Rp)",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: "Min",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _maxPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: "Max",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
          onPressed: () => Navigator.pop(context), // Return null
          child: const Text("Close", style: TextStyle(color: Colors.white)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
          onPressed: _applyFilter,
          child: const Text(
            "Apply Filters",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
