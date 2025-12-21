import 'dart:convert';
import 'package:matchplay_flutter/config.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

// Models
import '../models/field.dart';
import '../models/facility.dart';
import '../data/field_response.dart';

class FieldService {
  static const String baseUrl = AppConfig.baseUrl;
  static const String _endpoint = '/api/fields/';

  // 1. GET: Ambil semua fields
  Future<FieldListResponse> fetchFields(
    CookieRequest request, {
    int page = 1,
    int perPage = 20,
    String search = '',
    String? category,
    int? minPrice,
    int? maxPrice,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
    };

    if (search.isNotEmpty) queryParams['search'] = search;
    if (category != null && category.isNotEmpty) {
      queryParams['category'] = category;
    }
    if (minPrice != null) queryParams['min_price'] = minPrice.toString();
    if (maxPrice != null) queryParams['max_price'] = maxPrice.toString();

    final queryString = Uri(queryParameters: queryParams).query;
    final url = '$baseUrl$_endpoint?$queryString';

    try {
      final response = await request.get(url);

      if (response['status'] == 'success') {
        return FieldListResponse.fromJson(response);
      } else {
        throw Exception(response['message'] ?? 'Gagal mengambil data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // 2. GET: Ambil detail
  Future<Field> fetchFieldDetail(CookieRequest request, int id) async {
    final url = '$baseUrl$_endpoint$id/';
    try {
      final response = await request.get(url);
      // Asumsi backend mengembalikan JSON object field langsung
      return Field.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengambil detail: $e');
    }
  }

  // 3. POST: Create
  Future<bool> createField(
    CookieRequest request,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await request.postJson(
        '$baseUrl$_endpoint',
        jsonEncode(data),
      );

      if (response['status'] == 'success') {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // 4. POST (Update): Menggantikan PATCH
  Future<bool> updateField(
    CookieRequest request,
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      // Kita kirim ke endpoint detail ID dengan method POST
      final response = await request.postJson(
        '$baseUrl$_endpoint$id/',
        jsonEncode(data),
      );

      if (response['status'] == 'success') {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // 5. POST (Delete): Mengirim flag _method: DELETE
  Future<bool> deleteField(CookieRequest request, int id) async {
    try {
      final response = await request.postJson(
        '$baseUrl$_endpoint$id/',
        jsonEncode({"_method": "DELETE"}), // Flag yang kita cek di Django
      );

      if (response['status'] == 'success') {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // 6. GET: Facilities
  Future<List<Facility>> fetchFacilities(CookieRequest request) async {
    try {
      final response = await request.get('$baseUrl${_endpoint}facilities/');

      if (response['status'] == 'success') {
        return (response['data'] as List)
            .map((item) => Facility.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
