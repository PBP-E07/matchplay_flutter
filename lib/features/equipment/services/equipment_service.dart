import 'dart:convert';
import 'package:matchplay_flutter/config.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/equipment.dart';

class EquipmentService {
  static const String baseUrl = AppConfig.baseUrl;
  static const String _endpoint = '/equipment/';

  // Fetch Data (GET)
  Future<Map<String, dynamic>> fetchEquipments(
    CookieRequest request, {
    int page = 1,
    int perPage = 20,
    int? minPrice,
    int? maxPrice,
  }) async {
    final uri = '$baseUrl${_endpoint}json/';

    try {
      // Note: request.get mengembalikan dynamic (biasanya List atau Map yang sudah di-decode)
      // Namun endpoint 'show_json' Django mengembalikan List of Objects langsung.
      // Kita perlu handle response-nya.

      final response = await request.get(uri);

      // Karena show_json mengembalikan List, kita olah manual
      List<Equipment> allData = [];
      if (response != null) {
        // request.get otomatis decode JSON. Jika response adalah List:
        allData = List<Equipment>.from(
          response.map((x) => Equipment.fromJson(x)),
        );
      }

      // ... LOGIKA FILTERING CLIENT-SIDE (Sama seperti sebelumnya) ...
      if (minPrice != null) {
        allData = allData
            .where((e) => double.parse(e.fields.price) >= minPrice)
            .toList();
      }
      if (maxPrice != null) {
        allData = allData
            .where((e) => double.parse(e.fields.price) <= maxPrice)
            .toList();
      }

      // Hitung Stats
      double totalPrice = 0;
      int totalQty = 0;
      for (var e in allData) {
        totalPrice += double.parse(e.fields.price);
        totalQty += e.fields.stock;
      }
      double avgPrice = allData.isNotEmpty ? totalPrice / allData.length : 0;

      // Paginasi Client-side
      final totalData = allData.length;
      final totalPages = (totalData / perPage).ceil();
      final startIndex = (page - 1) * perPage;
      final endIndex = (startIndex + perPage < totalData)
          ? startIndex + perPage
          : totalData;

      List<Equipment> paginatedData = [];
      if (startIndex < totalData) {
        paginatedData = allData.sublist(startIndex, endIndex);
      }

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
    } catch (e) {
      throw Exception('Gagal koneksi: $e');
    }
  }

  // Create (POST JSON)
  Future<bool> createEquipment(
    CookieRequest request,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await request.postJson(
        '$baseUrl${_endpoint}create-flutter/',
        jsonEncode(data),
      );
      return response['status'] == 'success';
    } catch (e) {
      return false;
    }
  }

  // Edit
  Future<bool> editEquipment(
    CookieRequest request,
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await request.postJson(
        '$baseUrl${_endpoint}edit-flutter/$id/',
        jsonEncode(data),
      );
      return response['status'] == 'success';
    } catch (e) {
      return false;
    }
  }

  // Delete
  Future<bool> deleteEquipment(CookieRequest request, int id) async {
    try {
      final response = await request.postJson(
        '$baseUrl${_endpoint}delete-flutter/$id/',
        jsonEncode({}),
      );
      return response['status'] == 'success';
    } catch (e) {
      return false;
    }
  }
}
