import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:matchplay_flutter/config.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/tournament.dart';
import '../models/match.dart';
import 'create_match_form.dart';

class MatchListPage extends StatefulWidget {
  final Tournament tournament;

  const MatchListPage({super.key, required this.tournament});

  @override
  State<MatchListPage> createState() => _MatchListPageState();
}

class _MatchListPageState extends State<MatchListPage> {
  String baseUrl = AppConfig.baseUrl;

  Future<List<TournamentMatch>> fetchMatches(CookieRequest request) async {
    final url = '$baseUrl/tournament/api/${widget.tournament.id}/matches/';

    try {
      final response = await request.get(url);

      List<TournamentMatch> listMatches = [];
      for (var d in response) {
        if (d != null) {
          listMatches.add(TournamentMatch.fromJson(d));
        }
      }
      return listMatches;
    } catch (e) {
      // print("Error fetching match: $e");
      return [];
    }
  }

  // DELETE MATCH
  Future<void> _deleteMatch(CookieRequest request, int matchId) async {
    final url =
        '$baseUrl/tournament/api/${widget.tournament.id}/matches/$matchId/delete/';

    try {
      final response = await request.postJson(url, jsonEncode({}));

      if (response['status'] == 'success') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Pertandingan berhasil dihapus"),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {});
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Gagal: ${response['message']}"),
              backgroundColor: Colors.grey,
            ),
          );
        }
      }
    } catch (e) {
      // print("Error delete: $e");
    }
  }

  // EDIT SCORE
  Future<void> _editMatchScore(
    CookieRequest request,
    int matchId,
    int score1,
    int score2,
  ) async {
    final url =
        '$baseUrl/tournament/api/${widget.tournament.id}/matches/$matchId/edit/';

    try {
      final response = await request.postJson(
        url,
        jsonEncode({'score_team1': score1, 'score_team2': score2}),
      );

      if (response['status'] == 'success') {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Skor berhasil diupdate"),
              backgroundColor: Colors.green,
            ),
          );
          // REFRESH
          setState(() {});
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Gagal: ${response['message']}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // print("Error edit: $e");
    }
  }

  // DIALOG EDIT
  void _showEditDialog(CookieRequest request, TournamentMatch match) {
    final TextEditingController score1Controller = TextEditingController(
      text: match.score1.toString(),
    );
    final TextEditingController score2Controller = TextEditingController(
      text: match.score2.toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Skor Pertandingan"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${match.team1} vs ${match.team2}",
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: score1Controller,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: match.team1,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      "-",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: score2Controller,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: match.team2,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8BC34A),
              ),
              onPressed: () {
                int s1 = int.tryParse(score1Controller.text) ?? 0;
                int s2 = int.tryParse(score2Controller.text) ?? 0;
                _editMatchScore(request, match.id, s1, s2);
              },
              child: const Text(
                "Simpan",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // DIALOG DELETE
  void _showDeleteDialog(CookieRequest request, int matchId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Hapus Pertandingan"),
          content: const Text(
            "Apakah Anda yakin ingin menghapus match ini? Data tidak bisa dikembalikan.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(context);
                _deleteMatch(request, matchId);
              },
              child: const Text("Hapus", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // akses cookie
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Match List",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // hanya muncul jika creator
      floatingActionButton: widget.tournament.isCreator
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF8BC34A),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CreateMatchPage(tournament: widget.tournament),
                  ),
                );
                if (result == true) setState(() {});
              },
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Text(
              widget.tournament.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Divider(thickness: 1, color: Colors.grey),
          ),
          Expanded(child: _buildMatchList(request)),
        ],
      ),
    );
  }

  Widget _buildMatchList(CookieRequest request) {
    return FutureBuilder<List<TournamentMatch>>(
      future: fetchMatches(request),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Belum ada pertandingan."));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final match = snapshot.data![index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (index == 0 ||
                    match.roundNumber != snapshot.data![index - 1].roundNumber)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
                    child: Text(
                      "Round ${match.roundNumber}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                _buildMatchCard(request, match),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMatchCard(CookieRequest request, TournamentMatch match) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF8BC34A), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Round ${match.roundNumber}",
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          const Divider(height: 24),
          // TEAM 1
          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, size: 20, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  match.team1,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ),
              Text(
                "${match.score1}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          // VS
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: Text(
                "vs",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ),
          // TEAM 2
          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, size: 20, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  match.team2,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ),
              Text(
                "${match.score2}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),

          const Divider(height: 24),

          // hanya muncul jika creator
          if (widget.tournament.isCreator)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  onTap: () => _showEditDialog(request, match),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Edit Score",
                      style: TextStyle(
                        color: Color(0xFFFFD600),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => _showDeleteDialog(request, match.id),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Delete Match",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            const Center(
              child: Text(
                "Read Only",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
