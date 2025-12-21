// Package Umum
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

// Fields
import '../../../fields/models/field.dart';
import '../../../fields/models/facility.dart';
import '../../../fields/services/field_service.dart';

class FieldFormScreen extends StatefulWidget {
  final Field? field; // Jika null = Create, jika ada = Edit

  const FieldFormScreen({super.key, this.field});

  @override
  State<FieldFormScreen> createState() => _FieldFormScreenState();
}

class _FieldFormScreenState extends State<FieldFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = FieldService();

  // Controllers
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _ratingController = TextEditingController();
  final _locationController = TextEditingController();
  final _imageController = TextEditingController();
  final _urlController = TextEditingController();

  // State Variables
  String? _selectedSport;
  List<Facility> _availableFacilities = []; // Opsi dari API
  final Set<int> _selectedFacilityIds = {}; // Yang dipilih user
  bool _isLoading = false;

  // Daftar Sport Hardcoded sesuai models.py Django
  final List<Map<String, String>> _sportCategories = [
    {'value': 'badminton', 'label': 'Badminton'},
    {'value': 'basketball', 'label': 'Basketball'},
    {'value': 'billiard', 'label': 'Billiard'},
    {'value': 'e-sport', 'label': 'E-Sport'},
    {'value': 'futsal', 'label': 'Futsal'},
    {'value': 'golf', 'label': 'Golf'},
    {'value': 'mini soccer', 'label': 'Mini Soccer'},
    {'value': 'padel', 'label': 'Padel'},
    {'value': 'pickleball', 'label': 'Pickleball'},
    {'value': 'sepak bola', 'label': 'Sepak Bola'},
    {'value': 'squash', 'label': 'Squash'},
    {'value': 'tenis meja', 'label': 'Tenis Meja'},
    {'value': 'tennis', 'label': 'Tennis'},
  ];

  @override
  void initState() {
    super.initState();
    _initialLoad();
  }

  Future<void> _initialLoad() async {
    setState(() => _isLoading = true);
    final request = context.read<CookieRequest>();

    // 1. Fetch opsi fasilitas dari backend
    try {
      final facilities = await _service.fetchFacilities(request);
      setState(() {
        _availableFacilities = facilities;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat fasilitas: $e')));
    }

    // 2. Jika Edit Mode, isi form dengan data lama
    if (widget.field != null) {
      final f = widget.field!;
      _nameController.text = f.name;
      _priceController.text = f.price.toString();
      _ratingController.text = f.rating.toString();
      _locationController.text = f.location;
      _imageController.text = f.image;
      _urlController.text = f.url;
      _selectedSport = f.sport;

      // Map fasilitas yang sudah dimiliki ke dalam Set ID
      for (var facility in f.facilities) {
        _selectedFacilityIds.add(facility.id);
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _ratingController.dispose();
    _locationController.dispose();
    _imageController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSport == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pilih kategori olahraga!')));
      return;
    }

    setState(() => _isLoading = true);
    final request = context.read<CookieRequest>();

    // Mempersiapkan Data JSON
    // Backend mengharapkan 'facilities' berupa List ID [1, 2, 3]
    final data = {
      "name": _nameController.text,
      "sport": _selectedSport,
      "price": int.parse(_priceController.text),
      "rating": double.parse(_ratingController.text),
      "location": _locationController.text,
      "image": _imageController.text,
      "url": _urlController.text,
      "facilities": _selectedFacilityIds.toList(),
    };

    bool success = false;
    try {
      if (widget.field == null) {
        // Create Mode
        success = await _service.createField(request, data);
      } else {
        // Edit Mode
        success = await _service.updateField(request, widget.field!.id, data);
      }

      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          Navigator.pop(context, true); // Kembali ke list & refresh
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data berhasil disimpan!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal menyimpan data (Cek log)')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.field == null ? 'Tambah Lapangan' : 'Edit Lapangan'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // === Nama ===
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Lapangan',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),

                    // === Sport (Dropdown) ===
                    DropdownButtonFormField<String>(
                      initialValue: _selectedSport,
                      decoration: const InputDecoration(
                        labelText: 'Kategori Olahraga',
                        border: OutlineInputBorder(),
                      ),
                      items: _sportCategories.map((sport) {
                        return DropdownMenuItem(
                          value: sport['value'],
                          child: Text(sport['label']!),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedSport = val),
                    ),
                    const SizedBox(height: 16),

                    // === Harga & Rating (Row) ===
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            decoration: const InputDecoration(
                              labelText: 'Harga (Rp)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Wajib diisi';
                              final n = int.tryParse(value);
                              if (n == null) return 'Harus angka bulat';
                              if (n < 0) return 'Harga tidak boleh negatif';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _ratingController,
                            decoration: const InputDecoration(
                              labelText: 'Rating (0-5)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Wajib diisi';
                              }
                              final n = double.tryParse(value);
                              if (n == null || n < 0 || n > 5) {
                                return 'Invalid (0-5)';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // === Lokasi ===
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Alamat / Lokasi',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Wajib diisi';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // === Facilities (Checkbox Group) ===
                    const Text(
                      "Fasilitas",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      height:
                          200, // Fixed height dengan scroll agar tidak memakan tempat
                      child: _availableFacilities.isEmpty
                          ? const Center(
                              child: Text("Tidak ada fasilitas tersedia"),
                            )
                          : ListView.builder(
                              itemCount: _availableFacilities.length,
                              itemBuilder: (context, index) {
                                final facility = _availableFacilities[index];
                                final isChecked = _selectedFacilityIds.contains(
                                  facility.id,
                                );
                                return CheckboxListTile(
                                  title: Text(facility.name),
                                  value: isChecked,
                                  onChanged: (bool? val) {
                                    setState(() {
                                      if (val == true) {
                                        _selectedFacilityIds.add(facility.id);
                                      } else {
                                        _selectedFacilityIds.remove(
                                          facility.id,
                                        );
                                      }
                                    });
                                  },
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 16),

                    // === Image URL ===
                    TextFormField(
                      controller: _imageController,
                      decoration: const InputDecoration(
                        labelText: 'URL Gambar',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Wajib diisi';
                        // Cek sederhana apakah format URL valid
                        if (!Uri.parse(value).isAbsolute) {
                          return 'Format URL tidak valid (Gunakan http/https)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // === Map URL ===
                    TextFormField(
                      controller: _urlController,
                      decoration: const InputDecoration(
                        labelText: 'URL Google Maps',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Wajib diisi';
                        // Cek sederhana apakah format URL valid
                        if (!Uri.parse(value).isAbsolute) {
                          return 'Format URL tidak valid (Gunakan http/https)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // === Submit Button ===
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.blueAccent,
                        ),
                        onPressed: _submit,
                        child: Text(
                          widget.field == null ? "SIMPAN DATA" : "UPDATE DATA",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
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
