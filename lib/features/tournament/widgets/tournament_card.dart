import 'package:flutter/material.dart';
import '../models/tournament.dart';

class TournamentCard extends StatelessWidget {
  final Tournament tournament;
  final VoidCallback? onTap;

  const TournamentCard({super.key, required this.tournament, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: 
              Image.network(
                (tournament.bannerImage != null &&
                        tournament.bannerImage!.isNotEmpty)
                    ? tournament.bannerImage!
                    : "https://placehold.co/600x200/png",
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/images/padel_banner.png',
                    height: 150,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),

            // --- CARD TOURNAMENT ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TITLE
                  Text(
                    tournament.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // LEFT COLLUMN
                      Expanded(
                        child: Column(
                          children: [
                            _buildIconText(
                              Icons.location_on_outlined,
                              tournament.location,
                            ),
                            const SizedBox(height: 6),
                            _buildIconText(
                              Icons.people_outline,
                              "${tournament.totalTeams} Team dikonfirmasi",
                            ),
                            const SizedBox(height: 6),
                            _buildIconText(
                              Icons.emoji_events_outlined,
                              "Hadiah Menarik",
                            ),
                          ],
                        ),
                      ),
                      // RED COLLUMN
                      Column(
                        children: [
                          const Icon(
                            Icons.emoji_events,
                            color: Colors.amber,
                            size: 40,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            // Ambil Tanggal/Bulan saja (perlu parsing date sebenarnya)
                            tournament.startDate,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const Divider(height: 24),

                  // FOOTER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCE775),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "Ongoing",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.black54),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
