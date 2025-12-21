import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/tournament.dart';
import '../widgets/tournament_card.dart';
import 'tournament_form.dart';
import 'tournament_detail.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TournamentListPage extends StatefulWidget {
  const TournamentListPage({super.key});

  @override
  State<TournamentListPage> createState() => _TournamentListPageState();
}

class _TournamentListPageState extends State<TournamentListPage> {
  Future<List<Tournament>> fetchTournaments(CookieRequest request) async {
    print("Memulai request ke Django..."); 

    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/tournament/json/'),
        headers: {"Content-Type": "application/json"},
      );

      print("Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        print("Data berhasil di-decode: ${data.length} item ditemukan");

        List<Tournament> listTournament = [];
        for (var d in data) {
          if (d != null) {
            listTournament.add(Tournament.fromJson(d));
          }
        }
        return listTournament;
      } else {
        print("Gagal memuat data. Server merespons: ${response.statusCode}");
        return [];
      }
    } 
    catch (e) {
      print("Error Fatal Koneksi: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    print("Halaman TournamentListPage sedang dirender..."); 

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GREEN HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 60,
                left: 20,
                right: 20,
                bottom: 30,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF00C853),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "ONGOING TOURNAMENTS",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Tournaments",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "90 tournaments available",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {}, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8BC34A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                    child: const Text("Public"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black54,
                      elevation: 0,
                    ),
                    child: const Text("Private"),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Recently Added Tournaments",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // LIST TOURNAMENT
            FutureBuilder(
              future: fetchTournaments(request),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.data == null) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("Belum ada turnamen."));
                  } 
                  else {
                    return ListView.builder(
                      shrinkWrap: true, 
                      physics:
                          const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (_, index) {
                        return TournamentCard(
                          tournament: snapshot.data![index],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TournamentDetailPage(
                                  tournament: snapshot.data![index],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }
                }
              },
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00C853),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TournamentFormPage()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
