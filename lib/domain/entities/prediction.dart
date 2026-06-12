class Prediction {
  final int? id;
  final String matchId;
  final int homeScore;
  final int awayScore;
  final int points;
  final String? updatedAt;

  const Prediction({
    this.id,
    required this.matchId,
    required this.homeScore,
    required this.awayScore,
    this.points = 0,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'match_id': matchId,
        'home_score': homeScore,
        'away_score': awayScore,
        'points': points,
        'updated_at': DateTime.now().toIso8601String(),
      };

  factory Prediction.fromMap(Map<String, dynamic> m) => Prediction(
        id: m['id'] as int?,
        matchId: m['match_id'] as String,
        homeScore: m['home_score'] as int,
        awayScore: m['away_score'] as int,
        points: m['points'] as int? ?? 0,
        updatedAt: m['updated_at'] as String?,
      );
}

class PredictionStats {
  final int total;
  final int scored;
  final int perfect;
  final int pending;

  const PredictionStats({
    required this.total,
    required this.scored,
    required this.perfect,
    required this.pending,
  });

  int get points => (scored * 2) + (perfect * 3);
}
