import 'package:flutter/material.dart';

class AdminFilterDialog extends StatefulWidget {
  final String? currentCategory;
  final int? currentMinPrice;
  final int? currentMaxPrice;
  final List<Map<String, String>>? categories; // Opsional

  const AdminFilterDialog({
    super.key,
    this.currentCategory,
    this.currentMinPrice,
    this.currentMaxPrice,
    this.categories,
  });

  @override
  State<AdminFilterDialog> createState() => _AdminFilterDialogState();
}

class _AdminFilterDialogState extends State<AdminFilterDialog> {
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
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Filter Data"),
      actionsAlignment: MainAxisAlignment.center,
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown Kategori (Hanya muncul jika categories disediakan)
            if (widget.categories != null) ...[
              const Text(
                "Category",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: [
                  const DropdownMenuItem(value: null, child: Text("All")),
                  ...widget.categories!.map((cat) {
                    return DropdownMenuItem(
                      value: cat['value'],
                      child: Text(cat['label']!),
                    );
                  }),
                ],
                onChanged: (val) => setState(() => _selectedCategory = val),
              ),
              const SizedBox(height: 16),
            ],

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
          onPressed: () => Navigator.pop(context),
          child: const Text("Close", style: TextStyle(color: Colors.white)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
          onPressed: () {
            Navigator.pop(context, {
              'category': _selectedCategory,
              'minPrice': int.tryParse(_minPriceController.text),
              'maxPrice': int.tryParse(_maxPriceController.text),
            });
          },
          child: const Text(
            "Apply Filters",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
