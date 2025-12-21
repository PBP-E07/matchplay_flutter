class Tournament {
  final int id;
  final String name;
  final String? sportType;
  final String location;
  final String startDate;
  final String? endDate;
  final String? prizePool;
  final String? bannerImage;
  final String description; 
  final bool isPrivate;
  final int totalTeams;
  final bool isCreator; 

  Tournament({
    required this.id,
    required this.name,
    required this.sportType,
    required this.location,
    required this.startDate,
    this.endDate,
    this.prizePool,
    this.bannerImage,
    required this.description, 
    required this.isPrivate,
    required this.totalTeams,
    required this.isCreator, 
  });

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['id'] ?? 0,
      name: json['name'] ?? "No Name",
      sportType: json['sport_type'] ?? "General", 
      location: json['location'] ?? "-",
      startDate: json['start_date'] ?? "",
      endDate: json['end_date'],
      prizePool: json['prize_pool']?.toString(), 
      bannerImage: json['banner_image'],
      description: json['description'] ?? "Tidak ada deskripsi.", 
      isPrivate: json['is_private'] ?? false,
      totalTeams: json['total_teams'] ?? 0,    
      isCreator: json['is_creator'] ?? false, 
    );
  }
}