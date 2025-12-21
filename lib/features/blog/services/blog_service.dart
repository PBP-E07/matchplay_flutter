import 'dart:convert';
import 'package:matchplay_flutter/config.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/blog_entry.dart';

class BlogService {
  static const String baseUrl = AppConfig.baseUrl;
  // Prefix URL backend
  static const String _endpoint = '/blog/';

  // Fetch Data (GET) - Client Side Pagination & Filtering
  Future<Map<String, dynamic>> fetchBlogs(
    CookieRequest request, {
    int page = 1,
    int perPage = 10,
    String? search, // Search by Title
    String? category, // Filter by Category
  }) async {
    final uri = '$baseUrl${_endpoint}json/';

    try {
      final response = await request.get(uri);

      // Parsing Data
      // Response struktur: {'blogs': [list data]}
      List<Blog> allBlogs = [];
      if (response != null && response['blogs'] != null) {
        for (var d in response['blogs']) {
          allBlogs.add(Blog.fromJson(d));
        }
      }

      // 1. Client-side Filtering (Category)
      if (category != null && category.isNotEmpty) {
        allBlogs = allBlogs
            .where((b) => b.category.toLowerCase() == category.toLowerCase())
            .toList();
      }

      // 2. Client-side Searching (Title)
      if (search != null && search.isNotEmpty) {
        allBlogs = allBlogs
            .where((b) => b.title.toLowerCase().contains(search.toLowerCase()))
            .toList();
      }

      // 3. Hitung Stats (Total Data & Total Views)
      int totalViews = 0;
      for (var b in allBlogs) {
        totalViews += b.blogViews;
      }

      // 4. Client-side Pagination Logic
      final totalData = allBlogs.length;
      final totalPages = (totalData / perPage).ceil();
      final startIndex = (page - 1) * perPage;
      final endIndex = (startIndex + perPage < totalData)
          ? startIndex + perPage
          : totalData;

      List<Blog> paginatedData = [];
      if (startIndex < totalData) {
        paginatedData = allBlogs.sublist(startIndex, endIndex);
      }

      return {
        "data": paginatedData,
        "meta": {
          "total_data": totalData,
          "total_pages": totalPages == 0 ? 1 : totalPages,
          "current_page": page,
          "total_views": totalViews,
        },
      };
    } catch (e) {
      throw Exception('Gagal mengambil data blog: $e');
    }
  }

  // Create (POST)
  Future<bool> createBlog(
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

  // Update (POST)
  Future<bool> updateBlog(
    CookieRequest request,
    String id,
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

  // Delete (POST)
  Future<bool> deleteBlog(CookieRequest request, String id) async {
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
