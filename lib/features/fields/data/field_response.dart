import '../models/field.dart';

class FieldListResponse {
  final List<Field> fields;
  final FieldMeta meta;

  FieldListResponse({required this.fields, required this.meta});

  factory FieldListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data']; // Akses key 'data'
    return FieldListResponse(
      fields: (data['fields'] as List).map((i) => Field.fromJson(i)).toList(),
      meta: FieldMeta.fromJson(data['meta']),
    );
  }
}

class FieldMeta {
  final int totalData;
  final int totalPages;
  final int currentPage;
  final double avgPrice;
  final double avgRating;

  FieldMeta({
    required this.totalData,
    required this.totalPages,
    required this.currentPage,
    required this.avgPrice,
    required this.avgRating,
  });

  factory FieldMeta.fromJson(Map<String, dynamic> json) {
    return FieldMeta(
      totalData: json['total_data'],
      totalPages: json['total_pages'],
      currentPage: json['current_page'],
      avgPrice: (json['avg_price'] as num).toDouble(),
      avgRating: (json['avg_rating'] as num).toDouble(),
    );
  }
}
