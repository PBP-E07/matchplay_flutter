import 'package:flutter/material.dart';

class AdminFilterDialog extends StatefulWidget {
  final String? currentCategory;
  final int? currentMin;
  final int? currentMax;
  final List<Map<String, String>>? categories;
  final String rangeTitle;

  const AdminFilterDialog({
    super.key,
    this.currentCategory,
    this.currentMin,
    this.currentMax,
    this.categories,
    this.rangeTitle = "Price Range (Rp)", // Default
  });

  @override
  State<AdminFilterDialog> createState() => _AdminFilterDialogState();
}

class _AdminFilterDialogState extends State<AdminFilterDialog> {
  late TextEditingController _minController;
  late TextEditingController _maxController;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _minController = TextEditingController(
      text: widget.currentMin?.toString() ?? '',
    );
    _maxController = TextEditingController(
      text: widget.currentMax?.toString() ?? '',
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
            if (widget.categories != null) ...[
              const Text(
                "Category",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
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

            Text(
              widget.rangeTitle,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minController,
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
                    controller: _maxController,
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
        // Close
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),

        const SizedBox(width: 8),

        // Apply
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context, {
              'category': _selectedCategory,
              'min': int.tryParse(_minController.text),
              'max': int.tryParse(_maxController.text),
            });
          },
          child: const Text("Apply Filters"),
        ),
      ],
    );
  }
}
