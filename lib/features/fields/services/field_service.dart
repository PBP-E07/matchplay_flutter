import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/field.dart';
import '../models/facility.dart';
import '../data/field_response.dart';

class FieldService {
  // Android Emulator: 'http://10.0.2.2:8000'
  // Windows/Web: 'http://127.0.0.1:8000'
  static const String baseUrl = 'http://127.0.0.1:8000';

  // Endpoint prefix
  static const String _endpoint = '/api/fields/';

  // 1. GET: Ambil semua fields dengan filter & pagination
  Future<FieldListResponse> fetchFields({
    int page = 1,
    int perPage = 20,
    String search = '',
    String? category,
    int? minPrice,
    int? maxPrice,
  }) async {
    // Menyusun Query Parameters
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

    // Membangun URL
    final uri = Uri.parse(
      '$baseUrl$_endpoint',
    ).replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        if (json['status'] == 'success') {
          // Menggunakan helper class response
          return FieldListResponse.fromJson(json);
        } else {
          throw Exception(json['message'] ?? 'Gagal mengambil data');
        }
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal koneksi ke server: $e');
    }
  }

  // 2. GET: Ambil detail satu field
  Future<Field> fetchFieldDetail(int id) async {
    final uri = Uri.parse('$baseUrl$_endpoint$id/');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return Field.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Field tidak ditemukan');
    }
  }

  // 3. POST: Tambah Field Baru
  Future<bool> createField(Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl$_endpoint');

    try {
      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      // Backend me-return 201 Created jika sukses
      if (response.statusCode == 201) {
        return true;
      } else {
        // Bisa parsing error detail dari 'errors' key di backend
        // print('Gagal create: ${response.body}');
        return false;
      }
    } catch (e) {
      rethrow;
    }
  }

  // 4. PATCH: Update Field
  Future<bool> updateField(int id, Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl$_endpoint$id/');

    try {
      final response = await http.patch(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        // print('Gagal update: ${response.body}');
        return false;
      }
    } catch (e) {
      rethrow;
    }
  }

  // 5. DELETE: Hapus Field
  Future<bool> deleteField(int id) async {
    final uri = Uri.parse('$baseUrl$_endpoint$id/');

    try {
      final response = await http.delete(uri);

      // Backend me-return 204 No Content jika sukses
      if (response.statusCode == 204) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      rethrow;
    }
  }

  // 6. GET: Ambil daftar semua fasilitas untuk opsi di Form
  Future<List<Facility>> fetchFacilities() async {
    final uri = Uri.parse('$baseUrl${_endpoint}facilities/');

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'success') {
          // Parsing list of facilities
          return (json['data'] as List)
              .map((item) => Facility.fromJson(item))
              .toList();
        }
      }
      return []; // Return kosong jika gagal parsing
    } catch (e) {
      // print("Error fetching facilities: $e");
      return [];
    }
  }
}
