class Tournament {
  final int id;
  final String name;
  final String? sportType; 
  final String location;
  final String startDate;
  final String? endDate;
  final String? prizePool;   
  final String? bannerImage; 
  final bool isPrivate;
  final int totalTeams;

  Tournament({
    required this.id,
    required this.name,
    this.sportType,
    required this.location,
    required this.startDate,
    this.endDate,
    this.prizePool,
    this.bannerImage,
    required this.isPrivate,
    required this.totalTeams,
  });

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['id'],
      name: json['name'],
      sportType: json['sport_type'],
      location: json['location'] ?? "-",
      startDate: json['start_date'] ?? "",
      endDate: json['end_date'],
      prizePool: json['prize_pool'],     
      bannerImage: json['banner_image'], 
      isPrivate: json['is_private'] ?? false,
      totalTeams: json['total_teams'] ?? 0,
    );
  }
}