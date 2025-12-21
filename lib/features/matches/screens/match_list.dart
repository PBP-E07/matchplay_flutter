import 'package:flutter/material.dart';
import 'package:matchplay_flutter/features/matches/screens/create_match_form.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:matchplay_flutter/config.dart';
import 'package:matchplay_flutter/features/matches/models/match_model.dart';

class MatchListScreen extends StatefulWidget {
  const MatchListScreen({super.key});

  @override
  State<MatchListScreen> createState() => _MatchListScreenState();
}

class _MatchListScreenState extends State<MatchListScreen> {
  Future<List<MatchModel>> fetchMatches(CookieRequest request) async {
    // 1. Fetch data from Django API
    final response = await request.get('${AppConfig.baseUrl}/api/matches/');

    // 2. Parse the response
    List<MatchModel> listMatches = [];
    if (response['status'] == 'success') {
      for (var d in response['data']) {
        if (d != null) {
          listMatches.add(MatchModel.fromJson(d));
        }
      }
    }
    return listMatches;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Matches'),
      ),
      // Add a floating button to open your "Create Match" form
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateMatchForm()),
          );
          // Refresh the list after returning from the form
          setState(() {}); 
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder(
        future: fetchMatches(request),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data.isEmpty) {
            return const Center(child: Text("No matches available. Create one!"));
          } else {
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: snapshot.data!.length,
              itemBuilder: (_, index) {
                MatchModel match = snapshot.data![index];
                return _buildMatchCard(match);
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildMatchCard(MatchModel match) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  match.fieldName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    match.timeSlot,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text("Date: ${match.date}", style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: match.progress,
              backgroundColor: Colors.grey[200],
              color: Colors.green,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${match.currentPlayers}/${match.maxPlayers} Players",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Rp ${match.price}",
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
