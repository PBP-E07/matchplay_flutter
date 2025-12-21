import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DashboardStats extends StatelessWidget {
  final int totalData;
  final double avgPrice;
  final double avgRating;

  // Labels
  final String totalLabel;
  final String avgPriceLabel;
  final String avgRatingLabel;

  // Configuration
  final bool isCurrency; // True = Pakai Rp, False = Angka biasa
  final bool isCard3Int;
  final IconData icon1; // Icon untuk kartu kiri
  final IconData icon2; // Icon untuk kartu tengah
  final IconData icon3; // Icon untuk kartu kanan

  const DashboardStats({
    super.key,
    required this.totalData,
    required this.avgPrice,
    required this.avgRating,

    this.totalLabel = "Total Fields",
    this.avgPriceLabel = "Average Price",
    this.avgRatingLabel = "Average Rating",

    // Default values sesuai modul Field
    this.isCurrency = true,
    this.isCard3Int = false,

    this.icon1 = Icons.stadium,
    this.icon2 = Icons.attach_money,
    this.icon3 = Icons.star,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // Format nilai kartu ke-2 (Bisa Rp atau Angka biasa)
    String card2Value = isCurrency
        ? currencyFormat.format(avgPrice)
        : avgPrice.toInt().toString(); // Hilangkan desimal jika bukan uang
    String card3Value = avgRating.toStringAsFixed(isCard3Int ? 0 : 2);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: totalLabel,
                value: totalData.toString(),
                icon: icon1,
                color: Colors.purple,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: avgPriceLabel,
                value: card2Value,
                icon: icon2,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: avgRatingLabel,
                value: card3Value,
                icon: icon3,
                color: Colors.orange,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
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
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              Icon(icon, color: color.withValues(alpha: 0.8), size: 24),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color.withValues(alpha: 1),
            ),
          ),
        ],
      ),
    );
  }
}
