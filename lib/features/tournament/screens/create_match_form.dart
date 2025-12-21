import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/tournament.dart';
import '../models/team.dart';

class CreateMatchPage extends StatefulWidget {
  final Tournament tournament;

  const CreateMatchPage({super.key, required this.tournament});

  @override
  State<CreateMatchPage> createState() => _CreateMatchPageState();
}

class _CreateMatchPageState extends State<CreateMatchPage> {
  final _formKey = GlobalKey<FormState>();

  // Variables
  List<Team> _teams = [];
  Team? _selectedTeam1;
  Team? _selectedTeam2;
  final TextEditingController _roundController = TextEditingController(
    text: "1",
  );
  final TextEditingController _score1Controller = TextEditingController(
    text: "0",
  );
  final TextEditingController _score2Controller = TextEditingController(
    text: "0",
  );

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchTeams();
  }

  // DROPDOWN
  Future<void> fetchTeams() async {
    String baseUrl = kIsWeb ? 'http://localhost:8000' : 'http://10.0.2.2:8000';
    final url = Uri.parse(
      '$baseUrl/tournament/api/tournament/${widget.tournament.id}/teams/',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          _teams = data.map((d) => Team.fromJson(d)).toList();
        });
      }
    } catch (e) {
      // print("Error fetching teams: $e");
    }
  }

  // SUBMIT MATCH
  Future<void> _submitMatch() async {
    if (!_formKey.currentState!.validate()) return;

    // VALIDASI TEAM
    if (_selectedTeam1!.id == _selectedTeam2!.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Team 1 dan Team 2 tidak boleh sama!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    String baseUrl = kIsWeb ? 'http://localhost:8000' : 'http://10.0.2.2:8000';
    final url = Uri.parse(
      '$baseUrl/tournament/api/tournament/${widget.tournament.id}/matches/create/',
    );

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "team1_id": _selectedTeam1!.id,
          "team2_id": _selectedTeam2!.id,
          "round_number": int.parse(_roundController.text),
          "score_team1": int.parse(_score1Controller.text),
          "score_team2": int.parse(_score2Controller.text),
        }),
      );

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Match berhasil dibuat!"),
              backgroundColor: Colors.green,
            ),
          );
          // KEMBALI KE HALAMAN
          Navigator.pop(context, true);
        }
      } else {
        throw Exception("Gagal membuat match: ${response.body}");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Match"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // DROPDOWN TEAM 1
              DropdownButtonFormField<Team>(
                decoration: const InputDecoration(
                  labelText: "Pilih Team 1",
                  border: OutlineInputBorder(),
                ),
                value: _selectedTeam1,
                items: _teams.map((team) {
                  return DropdownMenuItem(value: team, child: Text(team.name));
                }).toList(),
                onChanged: (val) => setState(() => _selectedTeam1 = val),
                validator: (val) => val == null ? "Pilih Team 1" : null,
              ),
              const SizedBox(height: 16),

              // DROPDOWN TEAM B
              DropdownButtonFormField<Team>(
                decoration: const InputDecoration(
                  labelText: "Pilih Team 2",
                  border: OutlineInputBorder(),
                ),
                value: _selectedTeam2,
                items: _teams.map((team) {
                  return DropdownMenuItem(value: team, child: Text(team.name));
                }).toList(),
                onChanged: (val) => setState(() => _selectedTeam2 = val),
                validator: (val) => val == null ? "Pilih Team 2" : null,
              ),
              const SizedBox(height: 16),

              // INPUT ROUND & SCORES
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _roundController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Round",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _score1Controller,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Skor Team 1",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _score2Controller,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Skor Team 2",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // SUBMIT
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitMatch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8BC34A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Simpan Match",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
