import 'package:flutter/material.dart';
import 'package:matchplay_flutter/config.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/tournament.dart';
import '../widgets/tournament_card.dart';
import 'tournament_form.dart';
import 'tournament_detail.dart';
import 'package:matchplay_flutter/widgets/custom_bottom_navbar.dart'; 

class TournamentListPage extends StatefulWidget {
  const TournamentListPage({super.key});

  @override
  State<TournamentListPage> createState() => _TournamentListPageState();
}

class _TournamentListPageState extends State<TournamentListPage> {
  Future<List<Tournament>> fetchTournaments(CookieRequest request) async {
    String url = '${AppConfig.baseUrl}/tournament/json/';

    try {
      final response = await request.get(url);
      List<Tournament> listTournament = [];

      for (var d in response) {
        if (d != null) {
          try {
            if (d is Map && d.containsKey('fields')) {
              var fields = d['fields'];
              fields['id'] = d['pk'];
              listTournament.add(Tournament.fromJson(fields));
            } else {
              listTournament.add(Tournament.fromJson(d));
            }
          } catch (e) {
            // print("Gagal parsing item: $e");
          }
        }
      }
      return listTournament;
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    bool isAdmin = false;
    if (request.jsonData.containsKey('is_superuser')) {
      isAdmin = request.jsonData['is_superuser'];
    } else if (request.jsonData.containsKey('username')) {
       isAdmin = request.jsonData['username'] == 'admin'; 
    }

    final int pageIndex = isAdmin ? 2 : 1;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      
      // --- TAMBAHKAN NAVBAR DI SINI ---
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: pageIndex,
        isAdmin: isAdmin,
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
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
                    "All available tournaments",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
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
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (!snapshot.hasData || snapshot.data.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Center(child: Text("Belum ada turnamen.")),
                  );
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (_, index) {
                      return TournamentCard(
                        tournament: snapshot.data![index],
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TournamentDetailPage(
                                tournament: snapshot.data![index],
                              ),
                            ),
                          );

                          if (result == true) {
                            setState(() {
                              // print("Data berubah, refreshing list...");
                            });
                          }
                        },
                      );
                    },
                  );
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