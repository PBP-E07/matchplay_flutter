import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; 
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'tournament_list.dart';

class TournamentFormPage extends StatefulWidget {
  const TournamentFormPage({super.key});

  @override
  State<TournamentFormPage> createState() => _TournamentFormPageState();
}

class _TournamentFormPageState extends State<TournamentFormPage> {
  final _formKey = GlobalKey<FormState>();
  final Color _themeColor = const Color(0xFF8BC34A);

  String _name = "";
  String _sportType = "";
  String _location = "";
  String _description = "";
  String _prizePool = "";
  String _bannerImage = "";
  
  String _startDate = "";
  String _endDate = ""; 
  
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Buat Turnamen Baru',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              _buildLabel("Nama Turnamen"),
              TextFormField(
                decoration: _inputDecoration("Contoh: Piala Kemerdekaan", Icons.emoji_events),
                onChanged: (val) => _name = val,
                validator: (val) => val!.isEmpty ? "Nama wajib diisi" : null,
              ),
              const SizedBox(height: 16),

              _buildLabel("Jenis Olahraga"),
              TextFormField(
                decoration: _inputDecoration("Contoh: Futsal, Basket", Icons.sports_soccer),
                onChanged: (val) => _sportType = val,
                validator: (val) => val!.isEmpty ? "Jenis olahraga wajib diisi" : null,
              ),
              const SizedBox(height: 16),

              _buildLabel("Lokasi"),
              TextFormField(
                decoration: _inputDecoration("Contoh: GOR Soemantri", Icons.location_on),
                onChanged: (val) => _location = val,
                validator: (val) => val!.isEmpty ? "Lokasi wajib diisi" : null,
              ),
              const SizedBox(height: 16),

              _buildLabel("Tanggal Mulai"),
              TextFormField(
                controller: _startDateController,
                decoration: _inputDecoration("Pilih Tanggal Mulai", Icons.calendar_today),
                readOnly: true,
                onTap: () => _pickDate(context, _startDateController, (val) => _startDate = val),
                validator: (val) => val!.isEmpty ? "Tanggal mulai wajib diisi" : null,
              ),
              const SizedBox(height: 16),

              _buildLabel("Tanggal Selesai"),
              TextFormField(
                controller: _endDateController,
                decoration: _inputDecoration("Pilih Tanggal Selesai", Icons.event_available),
                readOnly: true,
                onTap: () => _pickDate(context, _endDateController, (val) => _endDate = val),
              ),
              const SizedBox(height: 16),

              _buildLabel("Hadiah (Prize Pool)"),
              TextFormField(
                decoration: _inputDecoration("Contoh: Rp 10.000.000", Icons.monetization_on_outlined),
                onChanged: (val) => _prizePool = val,
              ),
              const SizedBox(height: 16),

              _buildLabel("Deskripsi"),
              TextFormField(
                decoration: _inputDecoration("Jelaskan detail turnamen...", Icons.description_outlined),
                maxLines: 3, 
                onChanged: (val) => _description = val,
              ),
              const SizedBox(height: 16),

              _buildLabel("Banner Image URL"),
              TextFormField(
                decoration: _inputDecoration("https://example.com/banner.jpg", Icons.image_outlined),
                onChanged: (val) => _bannerImage = val,
              ),

              const SizedBox(height: 40),

              // SIMPAN
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: _themeColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  onPressed: _isLoading ? null : () => _submitForm(request),
                  child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("SIMPAN TURNAMEN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm(CookieRequest request) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
  
    String baseUrl = kIsWeb ? 'http://localhost:8000' : 'http://10.0.2.2:8000';
    
    try {
      final response = await request.postJson(
        "$baseUrl/tournament/api/tournament/create/",
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Turnamen berhasil dibuat!"), backgroundColor: Colors.green),
          );
          
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const TournamentListPage()),
            (route) => false,
          );
        } 
        else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? "Gagal menyimpan."), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
       }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate(BuildContext context, TextEditingController controller, Function(String) setDateState) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: _themeColor, onPrimary: Colors.white),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      String formattedDate = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2,'0')}-${pickedDate.day.toString().padLeft(2,'0')}";
      setState(() {
        controller.text = formattedDate; 
        setDateState(formattedDate);    
      });
    }
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: _themeColor),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: _themeColor, width: 2),
      ),
    );
  }
}