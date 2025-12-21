import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart'; 
import '../models/tournament.dart';
import 'match_list.dart';
import 'join_tournament_form.dart'; 
import 'edit_tournament_form.dart'; 
import 'tournament_list.dart'; 

class TournamentDetailPage extends StatefulWidget {
  final Tournament tournament;

  const TournamentDetailPage({super.key, required this.tournament});

  @override
  State<TournamentDetailPage> createState() => _TournamentDetailPageState();
}

class _TournamentDetailPageState extends State<TournamentDetailPage> {
  late int _currentTeamCount;
  
  bool _hasChanged = false; 

  @override
  void initState() {
    super.initState();
    _currentTeamCount = widget.tournament.totalTeams;
  }

  // DELETE
  Future<void> _deleteTournament(BuildContext context, CookieRequest request) async {
    String baseUrl = kIsWeb ? 'http://localhost:8000' : 'http://10.0.2.2:8000';
    final url = '$baseUrl/tournament/api/delete/${widget.tournament.id}/';

    try {
      final response = await request.postJson(url, "{}"); 
      if (response['status'] == 'success') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Turnamen berhasil dihapus"), backgroundColor: Colors.red),
          );
          Navigator.pushAndRemoveUntil(
            context, 
            MaterialPageRoute(builder: (context) => const TournamentListPage()), 
            (route) => false
          );
        }
      } else {
         if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['message'])));
         }
      }
    } catch (e) {
      print("Error deleting: $e");
    }
  }

  void _showDeleteConfirmation(BuildContext context, CookieRequest request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Turnamen?"),
        content: const Text("Tindakan ini tidak dapat dibatalkan."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context); 
              _deleteTournament(context, request); 
            }, 
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return PopScope(
      canPop: false, 
      onPopInvoked: (didPop) {
        if (didPop) return;
        Navigator.pop(context, _hasChanged);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Tournament Details", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context, _hasChanged),
          ),
          actions: [
            if (widget.tournament.isCreator) 
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.black),
                onSelected: (value) async {
                  if (value == 'edit') {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditTournamentFormPage(tournament: widget.tournament),
                      ),
                    );
                    setState(() { _hasChanged = true; });
                  } else if (value == 'delete') {
                    _showDeleteConfirmation(context, request);
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(children: [Icon(Icons.edit, color: Colors.orange), SizedBox(width: 12), Text('Edit')]),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 12), Text('Hapus')]),
                  ),
                ],
              ),
          ],
        ),

        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BANNER
              SizedBox(
              width: double.infinity,
              height: 200,
              child: Image.network(
                (widget.tournament.bannerImage != null && 
                 widget.tournament.bannerImage!.isNotEmpty &&
                 widget.tournament.bannerImage!.startsWith('http'))
                    ? widget.tournament.bannerImage!
                    : "https://placehold.co/600x400/png?text=Tournament", 
                fit: BoxFit.cover,
                
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, size: 50, color: Colors.grey),
                        Text("URL Gambar Tidak Valid", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                },
              ),
            ),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.tournament.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 8),
                    Text("Sedang Berlangsung", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                    const SizedBox(height: 24),

                    // INFO CARD
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        children: [
                          _buildInfoRow(icon: Icons.location_on_outlined, label: "Venue", value: widget.tournament.location),
                          const Divider(height: 24),
                          _buildInfoRow(icon: Icons.people_outline, label: "Teams", value: "$_currentTeamCount Team Terdaftar"),
                          const Divider(height: 24),
                          _buildInfoRow(
                            icon: Icons.emoji_events_outlined, 
                            label: "Prize", 
                            value: (widget.tournament.prizePool != null && widget.tournament.prizePool!.isNotEmpty) 
                                ? "Rp ${widget.tournament.prizePool}" : "Tidak ada hadiah",
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Text("Tournament Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text(
                      widget.tournament.description.isNotEmpty ? widget.tournament.description : "Tidak ada deskripsi tersedia.",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
                    ),
                    const SizedBox(height: 100), 
                  ],
                ),
              ),
            ],
          ),
        ),

        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MatchListPage(tournament: widget.tournament)));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFA726), foregroundColor: Colors.white, minimumSize: const Size.fromHeight(45), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    child: const Text("View Matches", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => JoinTournamentPage(tournament: widget.tournament)),
                      );
                      
                      if (result == true) {
                        setState(() {
                          _currentTeamCount += 1;
                          // FLAG DATA BERUBAH
                          _hasChanged = true; 
                        });
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil bergabung!"), backgroundColor: Colors.green));
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8BC34A), foregroundColor: Colors.white, minimumSize: const Size.fromHeight(45), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    child: const Text("Join Tournament", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 28, color: Colors.black87),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
        ),
      ],
    );
  }
}