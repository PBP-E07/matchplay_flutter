import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/tournament.dart';
import 'tournament_list.dart';

class EditTournamentFormPage extends StatefulWidget {
  final Tournament tournament;

  const EditTournamentFormPage({super.key, required this.tournament});

  @override
  State<EditTournamentFormPage> createState() => _EditTournamentFormPageState();
}

class _EditTournamentFormPageState extends State<EditTournamentFormPage> {
  final _formKey = GlobalKey<FormState>();
  final Color _themeColor = const Color(0xFFFFA726);

  late String _name;
  late String _sportType;
  late String _location;
  late String _description;
  late String _prizePool;
  late String _bannerImage;
  late String _startDate;
  late String _endDate;

  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _name = widget.tournament.name;
    _sportType = widget.tournament.sportType ?? "";
    _location = widget.tournament.location;
    _description = "";
    _prizePool = widget.tournament.prizePool ?? "";
    _bannerImage = widget.tournament.bannerImage ?? "";
    _startDate = widget.tournament.startDate;
    _endDate = widget.tournament.endDate ?? "";

    _startDateController.text = _startDate;
    _endDateController.text = _endDate;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Turnamen")),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: "Nama Turnamen"),
                onChanged: (val) => _name = val,
                validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _sportType,
                decoration: const InputDecoration(labelText: "Jenis Olahraga"),
                onChanged: (val) => _sportType = val,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _location,
                decoration: const InputDecoration(labelText: "Lokasi"),
                onChanged: (val) => _location = val,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _startDateController,
                decoration: const InputDecoration(
                  labelText: "Tanggal Mulai",
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _pickDate(
                  context,
                  _startDateController,
                  (val) => _startDate = val,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _endDateController,
                decoration: const InputDecoration(
                  labelText: "Tanggal Selesai",
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _pickDate(
                  context,
                  _endDateController,
                  (val) => _endDate = val,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _prizePool,
                decoration: const InputDecoration(labelText: "Prize Pool"),
                onChanged: (val) => _prizePool = val,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _bannerImage,
                decoration: const InputDecoration(labelText: "Banner URL"),
                onChanged: (val) => _bannerImage = val,
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _themeColor,
                    padding: const EdgeInsets.all(16),
                  ),
                  onPressed: _isLoading ? null : () => _submitEdit(request),
                  child: const Text(
                    "UPDATE TURNAMEN",
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

  Future<void> _submitEdit(CookieRequest request) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    String baseUrl = kIsWeb ? 'http://localhost:8000' : 'http://10.0.2.2:8000';

    try {
      final response = await request.postJson(
        "$baseUrl/tournament/api/edit/${widget.tournament.id}/",
        jsonEncode({
          'name': _name,
          'sport_type': _sportType,
          'location': _location,
          'start_date': _startDate,
          'end_date': _endDate.isNotEmpty ? _endDate : null,
          'description': _description,
          'prize_pool': _prizePool,
          'banner_image': _bannerImage.isNotEmpty ? _bannerImage : null,
        }),
      );

      if (mounted) {
        if (response['status'] == 'success') {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Berhasil diupdate!")));
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const TournamentListPage()),
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(response['message'])));
        }
      }
    } catch (e) {
      //  print(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate(
    BuildContext context,
    TextEditingController controller,
    Function(String) setDateState,
  ) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      String formattedDate =
          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      setState(() {
        controller.text = formattedDate;
        setDateState(formattedDate);
      });
    }
  }
}
