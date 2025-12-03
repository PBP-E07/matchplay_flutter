// Model Facility
import 'facility.dart';

class Field {
  final int? id;
  final String name;
  final String image;
  final int price;
  final double rating;
  final String location;
  final String sport;
  final String url;
  final List<Facility> facilities;

  Field({
    this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.rating,
    required this.location,
    required this.sport,
    required this.url,
    required this.facilities,
  });

  // Mendapatkan data
  // GET mengambil Facility sebagai Object
  factory Field.fromJson(Map<String, dynamic> json) {
    return Field(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      price: json['price'],
      rating: (json['rating'] is int)
          ? (json['rating'] as int).toDouble()
          : json['rating'],
      location: json['location'],
      sport: json['sport'],
      url: json['url'],
      facilities: json['facilities'] != null
          // Mengubah JSON Object menjadi Dart Object
          ? (json['facilities'] as List)
                .map((i) => Facility.fromJson(i))
                .toList()
          : [],
    );
  }

  // Mengirim data
  // PATCH dan DELETE menggunakan Facility dalam bentuk integer ID
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
      'price': price,
      'rating': rating,
      'location': location,
      'sport': sport,
      'url': url,
      'facilities': facilities.map((f) => f.id).toList(),
    };
  }
}
