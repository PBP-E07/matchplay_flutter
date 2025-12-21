class MatchModel {
  final int id;
  final String fieldName;
  final String timeSlot;
  final String date;
  final int price;
  final int currentPlayers;
  final int maxPlayers;

  MatchModel({
    required this.id,
    required this.fieldName,
    required this.timeSlot,
    required this.date,
    required this.price,
    required this.currentPlayers,
    required this.maxPlayers,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id'],
      fieldName: json['field_name'] ?? 'Unknown Field',
      timeSlot: json['time_slot'],
      date: json['date'],
      price: json['price'],
      currentPlayers: json['current_players'],
      maxPlayers: json['max_players'],
    );
  }

  double get progress => currentPlayers / maxPlayers;
  int get spotsLeft => maxPlayers - currentPlayers;
}
