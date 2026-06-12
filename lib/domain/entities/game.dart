class Game {
  final String id;
  final String homeTeamId;
  final String awayTeamId;
  final String homeScore;
  final String awayScore;
  final String? homeScorers;
  final String? awayScorers;
  final String group;
  final String matchday;
  final String localDate;
  final String stadiumId;
  final bool finished;
  final String timeElapsed;
  final String type;
  final String homeTeamNameEn;
  final String homeTeamNameFa;
  final String awayTeamNameEn;
  final String awayTeamNameFa;
  final String? homeTeamLabel;
  final String? awayTeamLabel;

  const Game({
    required this.id,
    required this.homeTeamId,
    required this.awayTeamId,
    required this.homeScore,
    required this.awayScore,
    this.homeScorers,
    this.awayScorers,
    required this.group,
    required this.matchday,
    required this.localDate,
    required this.stadiumId,
    required this.finished,
    required this.timeElapsed,
    required this.type,
    required this.homeTeamNameEn,
    required this.homeTeamNameFa,
    required this.awayTeamNameEn,
    required this.awayTeamNameFa,
    this.homeTeamLabel,
    this.awayTeamLabel,
  });

  bool get isLive => timeElapsed == 'live' || timeElapsed == 'finished';
  bool get hasResult => finished || (homeScore != '0' || awayScore != '0');
}
