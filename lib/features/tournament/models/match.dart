class TournamentMatch {
  final int id;
  final int roundNumber;
  final String team1;
  final String team2;
  final int score1;
  final int score2;

  TournamentMatch({
    required this.id,
    required this.roundNumber,
    required this.team1,
    required this.team2,
    required this.score1,
    required this.score2,
  });

  factory TournamentMatch.fromJson(Map<String, dynamic> json) {
    return TournamentMatch(
      id: json['id'],
      roundNumber: json['round_number'] ?? 1,
      team1: json['team1_name'] ?? "Unknown",
      team2: json['team2_name'] ?? "Unknown",
      score1: json['score_team1'] ?? 0,
      score2: json['score_team2'] ?? 0,
    );
  }
}