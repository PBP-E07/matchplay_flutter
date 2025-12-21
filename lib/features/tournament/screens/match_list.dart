import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart'; 
import '../models/tournament.dart';
import '../models/match.dart';
import 'create_match_form.dart'; 

class MatchListPage extends StatefulWidget {
  final Tournament tournament;

  const MatchListPage({super.key, required this.tournament});

  @override
  State<MatchListPage> createState() => _MatchListPageState();
}

class _MatchListPageState extends State<MatchListPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<List<TournamentMatch>> fetchMatches() async {
    String baseUrl = kIsWeb ? 'http://localhost:8000' : 'http://10.0.2.2:8000';
    final url = Uri.parse('$baseUrl/tournament/api/${widget.tournament.id}/matches/');

    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((d) => TournamentMatch.fromJson(d)).toList();
      } else {
        print("Gagal fetch: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      // APP BAR 
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

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF8BC34A),
        onPressed: () async {
          // pindah ke create match
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateMatchPage(tournament: widget.tournament),
            ),
          );

          // success case
          if (result == true) {
            // rebuild
            setState(() {
            });
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),

      // BODY 
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // nama Turnamen
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Text(
              widget.tournament.name, 
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // TAB BAR
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF8BC34A),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF8BC34A),
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: "Semua"),
                Tab(text: "Terlalu"), 
                Tab(text: "Terlibat"),
              ],
            ),
          ),

          // ISI TAB
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                
                _buildMatchList(),
                
                const Center(child: Text("Fitur belum tersedia")),
                const Center(child: Text("Fitur belum tersedia")),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // LIST MATCH DENGAN FUTURE BUILDER
  Widget _buildMatchList() {
    return FutureBuilder<List<TournamentMatch>>(
      future: fetchMatches(), 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
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
                if (index == 0 || match.roundNumber != snapshot.data![index-1].roundNumber)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
                    child: Text(
                      "Round ${match.roundNumber}",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),

                _buildMatchCard(match),
              ],
            );
          },
        );
      },
    );
  }

  // MATCH LIST
  Widget _buildMatchCard(TournamentMatch match) {
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
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),

          // VS Separator
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
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          
          const Divider(height: 24),

          // TOMBOL EDIT / DELETE 
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InkWell(
                onTap: () { print("Edit match ID: ${match.id}"); },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Edit", style: TextStyle(color: Color(0xFFFFD600), fontWeight: FontWeight.bold)),
                ),
              ),
              InkWell(
                onTap: () { print("Delete match ID: ${match.id}"); },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Delete", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}