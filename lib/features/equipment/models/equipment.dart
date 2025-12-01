// To parse this JSON data, do
//
//     final equipment = equipmentFromJson(jsonString);

import 'dart:convert';

List<Equipment> equipmentFromJson(String str) => List<Equipment>.from(json.decode(str).map((x) => Equipment.fromJson(x)));

String equipmentToJson(List<Equipment> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Equipment {
    String model;
    int pk;
    Fields fields;

    Equipment({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory Equipment.fromJson(Map<String, dynamic> json) => Equipment(
        model: json["model"],
        pk: json["pk"],
        fields: Fields.fromJson(json["fields"]),
    );

    Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
    };
}

class Fields {
    String name;
    int quantity;
    String pricePerHour;
    String description;
    String image;

    Fields({
        required this.name,
        required this.quantity,
        required this.pricePerHour,
        required this.description,
        required this.image,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        name: json["name"],
        quantity: json["quantity"],
        pricePerHour: json["price_per_hour"],
        description: json["description"],
        image: json["image"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "quantity": quantity,
        "price_per_hour": pricePerHour,
        "description": description,
        "image": image,
    };
}
