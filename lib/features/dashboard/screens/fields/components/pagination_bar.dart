import 'package:flutter/material.dart';

class PaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;

  const PaginationBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Tentukan range halaman (Window Logic)
    // Mulai dari 2 halaman sebelumnya, tapi tidak boleh kurang dari 1
    int startPage = currentPage - 2;
    if (startPage < 1) startPage = 1;

    // Sampai 2 halaman setelahnya, tapi tidak boleh lebih dari totalPages
    int endPage = currentPage + 2;
    if (endPage > totalPages) endPage = totalPages;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // === TOMBOL PREV ===
        // Hanya muncul jika bukan di halaman pertama
        if (currentPage > 1) ...[
          _buildPageButton(
            label: "Prev",
            onTap: () => onPageChanged(currentPage - 1),
            isActive: false,
          ),
          const SizedBox(width: 8),
        ],

        // === TOMBOL ANGKA ===
        // Loop dari startPage ke endPage
        for (int i = startPage; i <= endPage; i++) ...[
          _buildPageButton(
            label: i.toString(),
            onTap: () => onPageChanged(i),
            isActive: i == currentPage,
          ),
          // Tambahkan spasi antar angka, kecuali di angka terakhir
          if (i < endPage) const SizedBox(width: 8),
        ],

        // === TOMBOL NEXT ===
        // Hanya muncul jika belum di halaman terakhir
        if (currentPage < totalPages) ...[
          const SizedBox(width: 8),
          _buildPageButton(
            label: "Next",
            onTap: () => onPageChanged(currentPage + 1),
            isActive: false,
          ),
        ],
      ],
    );
  }

  // Helper Widget untuk membuat tombol agar kodenya tidak berulang
  Widget _buildPageButton({
    required String label,
    required VoidCallback onTap,
    required bool isActive,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          // Warna biru jika aktif, putih jika tidak
          color: isActive ? Colors.blueAccent : Colors.white,
          borderRadius: BorderRadius.circular(4),
          // Border abu-abu tipis
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Text(
          label,
          style: TextStyle(
            // Teks putih jika aktif, hitam jika tidak
            color: isActive ? Colors.white : Colors.black87,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
