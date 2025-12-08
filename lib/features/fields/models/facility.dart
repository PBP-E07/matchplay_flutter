class Facility {
  final int id;
  final String name;

  Facility({required this.id, required this.name});

  factory Facility.fromJson(Map<String, dynamic> json) {
    return Facility(id: json['id'], name: json['name']);
  }

  // Untuk keperluan dropdown/multi-select di Form
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Facility && runtimeType == other.runtimeType && id == other.id;

  // Hashcode
  @override
  int get hashCode => id.hashCode;

  // Method untuk debug
  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
