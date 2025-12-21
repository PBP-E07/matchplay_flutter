import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DashboardStats extends StatelessWidget {
  final int totalData;
  final double avgPrice;
  final double avgRating;
  final String totalLabel;
  final String avgPriceLabel;
  final String avgRatingLabel;

  const DashboardStats({
    super.key,
    required this.totalData,
    required this.avgPrice,
    required this.avgRating,
    this.totalLabel = "Total Data",
    this.avgPriceLabel = "Average Price",
    this.avgRatingLabel = "Average Rating",
  });

  @override
  Widget build(BuildContext context) {
    // Format mata uang
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // Responsive logic
        int columns;
        if (width >= 1100) {
          columns = 3; // Layar Besar: 3 Kartu sebaris
        } else if (width >= 700) {
          columns = 2; // Layar Sedang: 2 Kartu sebaris
        } else {
          columns = 1; // Layar Kecil: 1 Kartu sebaris
        }

        // Hitung lebar setiap kartu
        // Rumus: (Total Lebar - (Total Spasi antar kartu)) / Jumlah Kolom
        final double gap = 16.0;
        final double cardWidth = (width - (gap * (columns - 1))) / columns;

        return Wrap(
          spacing: gap, // Spasi Horizontal
          runSpacing: gap, // Spasi Vertikal (saat turun baris)
          children: [
            _buildStatCard(
              title: totalLabel,
              value: totalData.toString(),
              valueColor: Colors.purple,
              icon: Icons.stadium,
              width: cardWidth,
            ),
            _buildStatCard(
              title: avgPriceLabel,
              value: currencyFormat.format(avgPrice),
              valueColor: Colors.green,
              icon: Icons.attach_money,
              width: cardWidth,
            ),
            _buildStatCard(
              title: avgRatingLabel,
              value: avgRating.toString(),
              valueColor: Colors.amber,
              icon: Icons.star,
              width: cardWidth,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color valueColor,
    required IconData icon,
    required double width,
  }) {
    // SizedBox untuk memaksakan lebar kartu sesuai perhitungan
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          // Shadow halus agar terlihat timbul
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey[600], fontSize: 20),
                ),
                Icon(icon, color: Colors.grey[300], size: 24),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
