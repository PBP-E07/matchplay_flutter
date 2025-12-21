import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:matchplay_flutter/config.dart';
import 'package:matchplay_flutter/features/equipment/models/equipment.dart';

class EquipmentFormPage extends StatefulWidget {
  final Equipment? equipment;
  const EquipmentFormPage({super.key, this.equipment});

  @override
  State<EquipmentFormPage> createState() => _EquipmentFormPageState();
}

class _EquipmentFormPageState extends State<EquipmentFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controller buat input field
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Kalau ada data equipment (Mode Edit), isi form-nya
    if (widget.equipment != null) {
      _nameController.text = widget.equipment!.fields.name;
      _priceController.text = widget.equipment!.fields.pricePerHour.toString();
      _descController.text = widget.equipment!.fields.description;
      _qtyController.text = widget.equipment!.fields.quantity.toString();
      _imageController.text = widget.equipment!.fields.image ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    bool isEdit = widget.equipment != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Alat' : 'Tambah Alat Baru',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00BFA6),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildTextField(_nameController, "Nama Alat", Icons.inventory),
              _buildTextField(
                _priceController,
                "Harga per Jam",
                Icons.attach_money,
                isNumber: true,
              ),
              _buildTextField(
                _qtyController,
                "Jumlah Stok",
                Icons.numbers,
                isNumber: true,
              ),
              _buildTextField(
                _imageController,
                "URL Gambar / Path",
                Icons.image,
              ),
              _buildTextField(
                _descController,
                "Deskripsi",
                Icons.description,
                maxLines: 3,
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BFA6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Tentukan endpoint: create atau edit
                      String baseUrl = AppConfig.baseUrl;
                      String url = isEdit
                          ? '$baseUrl/equipment/edit-flutter/${widget.equipment!.pk}/'
                          : '$baseUrl/equipment/create-flutter/';

                      final response = await request.post(
                        url,
                        jsonEncode({
                          'name': _nameController.text,
                          'price_per_hour': _priceController.text,
                          'description': _descController.text,
                          'quantity': _qtyController.text,
                          'image': _imageController.text,
                        }),
                      );

                      if (context.mounted) {
                        if (response['status'] == 'success') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isEdit
                                    ? "Berhasil diubah!"
                                    : "Berhasil ditambah!",
                              ),
                            ),
                          );
                          Navigator.pop(context, true); // Balik ke list
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Terjadi kesalahan, coba lagi."),
                            ),
                          );
                        }
                      }
                    }
                  },
                  child: Text(
                    isEdit ? "Simpan Perubahan" : "Tambah Alat",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget helper biar kode lo rapi
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (value) => (value == null || value.isEmpty)
            ? "$label nggak boleh kosong"
            : null,
      ),
    );
  }
}
