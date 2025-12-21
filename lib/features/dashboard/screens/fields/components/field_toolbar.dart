import 'package:flutter/material.dart';
import 'dart:math';

class FieldToolbar extends StatelessWidget {
  // Action Callbacks
  final VoidCallback onAddPressed;
  final VoidCallback onFilterPressed;

  // Pagination Info
  final int totalData;
  final int currentPage;
  final int perPage;
  final List<int> pageSizeList;
  final Function(int) onPerPageChanged;

  const FieldToolbar({
    super.key,
    required this.onAddPressed,
    required this.onFilterPressed,
    required this.totalData,
    required this.currentPage,
    required this.perPage,
    required this.pageSizeList,
    required this.onPerPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    int start = totalData == 0 ? 0 : ((currentPage - 1) * perPage) + 1;
    int end = min(currentPage * perPage, totalData);

    return SizedBox(
      width: double.infinity,
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // GRUP KIRI: Tombol Tambah & Filter
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                onPressed: onAddPressed,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  "Tambah Lapangan",
                  style: TextStyle(color: Colors.white),
                ),
              ),

              const SizedBox(width: 12),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4285F4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                onPressed: onFilterPressed,
                icon: const Icon(Icons.filter_list, color: Colors.white),
                label: const Text(
                  "Filter",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),

          // GRUP KANAN: Pagination Info & Dropdown
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: perPage,
                    icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                    items: pageSizeList.map((int val) {
                      return DropdownMenuItem<int>(
                        value: val,
                        child: Text(val.toString()),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) onPerPageChanged(val);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                "Showing $start-$end of $totalData fields",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
