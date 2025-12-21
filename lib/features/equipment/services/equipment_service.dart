// Package Umum
import 'dart:convert';
import 'package:http/http.dart' as http;

// Models
import '../models/equipment.dart';

class EquipmentService {
  // Sesuaikan URL
  // Web/Windows: 127.0.0.1
  // Emulator Android: 10.0.2.2
  static const String baseUrl = 'http://127.0.0.1:8000';

  static const String _endpointJson = '/equipment/json/';
  static const String _endpoint = '/equipment/';

  // Fetch Data dengan Client-side Pagination
  Future<Map<String, dynamic>> fetchEquipments({
    int page = 1,
    int perPage = 20,
    int? minPrice,
    int? maxPrice,
  }) async {
    final uri = Uri.parse('$baseUrl$_endpointJson');

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        // 1. Parse semua data dari backend
        List<Equipment> allData = equipmentFromJson(response.body);

        // 2. Client-side filtering (harga)
        if (minPrice != null) {
          allData = allData
              .where((e) => double.parse(e.fields.pricePerHour) >= minPrice)
              .toList();
        }
        if (maxPrice != null) {
          allData = allData
              .where((e) => double.parse(e.fields.pricePerHour) <= maxPrice)
              .toList();
        }

        // 3. Hitung statistik (untuk cards)
        double totalPrice = 0;
        int totalQty = 0;
        for (var e in allData) {
          totalPrice += double.parse(e.fields.pricePerHour);
          totalQty += e.fields.quantity;
        }
        double avgPrice = allData.isNotEmpty ? totalPrice / allData.length : 0;

        // 4. Client-side pagination logic
        final totalData = allData.length;
        final totalPages = (totalData / perPage).ceil();

        // Ambil potongan data (slice) sesuai halaman
        final startIndex = (page - 1) * perPage;
        final endIndex = (startIndex + perPage < totalData)
            ? startIndex + perPage
            : totalData;

        List<Equipment> paginatedData = [];
        if (startIndex < totalData) {
          paginatedData = allData.sublist(startIndex, endIndex);
        }

        // Return format yang mirip dengan FieldService agar UI mudah
        return {
          "data": paginatedData,
          "meta": {
            "total_data": totalData,
            "total_pages": totalPages == 0 ? 1 : totalPages,
            "current_page": page,
            "avg_price": avgPrice,
            "total_qty": totalQty,
          },
        };
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal koneksi: $e');
    }
  }

  // Create
  Future<bool> createEquipment(Map<String, dynamic> data) async {
    final uri = Uri.parse(
      '$baseUrl${_endpoint}create-flutter/',
    ); // Endpoint JSON

    try {
      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        // Debugging jika error
        // print('Gagal create: ${response.body}');
        return false;
      }
    } catch (e) {
      rethrow;
    }
  }

  // Edit
  Future<bool> editEquipment(int id, Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl$_endpoint$id/edit/');

    try {
      // Karena edit_equipment di Django pakai request.POST, kirim map biasa (bukan JSON string)
      // Note: Pastikan data semua bertipe String saat dikirim sebagai form fields
      final Map<String, String> formData = {
        'name': data['name'],
        'quantity': data['quantity'].toString(),
        'price_per_hour': data['price_per_hour'].toString(),
        'description': data['description'],
      };

      final response = await http.post(
        uri,
        // Tidak pakai header application/json karena ini Form Url Encoded
        body: formData,
      );

      // Backend edit_equipment return JsonResponse({'status': 'success'})
      if (response.statusCode == 200) {
        return true;
      } else {
        // print('Gagal edit: ${response.body}');
        return false;
      }
    } catch (e) {
      rethrow;
    }
  }

  // Delete
  Future<bool> deleteEquipment(int id) async {
    final uri = Uri.parse('$baseUrl$_endpoint$id/delete/');
    try {
      final response = await http.post(uri);
      return response.statusCode == 200; // JsonResponse({'status': 'deleted'})
    } catch (e) {
      return false;
    }
  }
}
