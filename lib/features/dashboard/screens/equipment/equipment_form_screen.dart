// Package Umum
import 'package:flutter/material.dart';

// Equipment
import '../../../equipment/models/equipment.dart';
import '../../../equipment/services/equipment_service.dart';

class EquipmentFormScreen extends StatefulWidget {
  final Equipment? equipment; // Null = Create, Not Null = Edit

  const EquipmentFormScreen({super.key, this.equipment});

  @override
  State<EquipmentFormScreen> createState() => _EquipmentFormScreenState();
}

class _EquipmentFormScreenState extends State<EquipmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = EquipmentService();

  // Controllers
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.equipment != null) {
      // Isi form jika Edit Mode
      final e = widget.equipment!;
      _nameController.text = e.fields.name;
      _quantityController.text = e.fields.quantity.toString();
      // Konversi string price "10000.00" jadi "10000" agar rapi di textfield
      _priceController.text = double.parse(
        e.fields.pricePerHour,
      ).toInt().toString();
      _descController.text = e.fields.description;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Persiapkan Data
    final data = {
      "name": _nameController.text,
      "quantity": int.parse(_quantityController.text),
      "price_per_hour": double.parse(_priceController.text),
      "description": _descController.text,
    };

    bool success = false;
    try {
      if (widget.equipment == null) {
        // Create Mode
        success = await _service.createEquipment(data);
      } else {
        // Edit Mode
        success = await _service.editEquipment(widget.equipment!.pk, data);
      }

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data berhasil disimpan!")),
        );
        Navigator.pop(context, true); // Kembali ke list dengan sinyal refresh
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal menyimpan data. Pastikan Anda login (Admin)."),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.equipment == null ? "Tambah Alat" : "Edit Alat"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Nama Alat
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: "Nama Alat",
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
                    ),
                    const SizedBox(height: 16),

                    // Row: Quantity & Price
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _quantityController,
                            decoration: const InputDecoration(
                              labelText: "Jumlah (Qty)",
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (val) =>
                                val!.isEmpty ? "Wajib diisi" : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            decoration: const InputDecoration(
                              labelText: "Harga / Jam",
                              prefixText: "Rp ",
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (val) =>
                                val!.isEmpty ? "Wajib diisi" : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descController,
                      decoration: const InputDecoration(
                        labelText: "Deskripsi",
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 4,
                      validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
                    ),

                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.blueAccent,
                        ),
                        onPressed: _submit,
                        child: Text(
                          widget.equipment == null
                              ? "SIMPAN DATA"
                              : "UPDATE DATA",
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
