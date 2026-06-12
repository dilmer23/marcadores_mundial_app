import 'package:marcadores_mundial_app/domain/entities/game.dart';

class GameModel {
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

  const GameModel({
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

  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      id: json['id'] as String? ?? '',
      homeTeamId: json['home_team_id'] as String? ?? '0',
      awayTeamId: json['away_team_id'] as String? ?? '0',
      homeScore: json['home_score'] as String? ?? '0',
      awayScore: json['away_score'] as String? ?? '0',
      homeScorers: json['home_scorers']?.toString(),
      awayScorers: json['away_scorers']?.toString(),
      group: json['group'] as String? ?? '',
      matchday: json['matchday'] as String? ?? '',
      localDate: json['local_date'] as String? ?? '',
      stadiumId: json['stadium_id'] as String? ?? '0',
      finished: (json['finished'] as String? ?? 'FALSE') == 'TRUE',
      timeElapsed: json['time_elapsed'] as String? ?? 'notstarted',
      type: json['type'] as String? ?? 'group',
      homeTeamNameEn: json['home_team_name_en'] as String? ?? '',
      homeTeamNameFa: json['home_team_name_fa'] as String? ?? '',
      awayTeamNameEn: json['away_team_name_en'] as String? ?? '',
      awayTeamNameFa: json['away_team_name_fa'] as String? ?? '',
      homeTeamLabel: json['home_team_label'] as String?,
      awayTeamLabel: json['away_team_label'] as String?,
    );
  }

  Game toEntity() => Game(
        id: id,
        homeTeamId: homeTeamId,
        awayTeamId: awayTeamId,
        homeScore: homeScore,
        awayScore: awayScore,
        homeScorers: homeScorers,
        awayScorers: awayScorers,
        group: group,
        matchday: matchday,
        localDate: localDate,
        stadiumId: stadiumId,
        finished: finished,
        timeElapsed: timeElapsed,
        type: type,
        homeTeamNameEn: homeTeamNameEn,
        homeTeamNameFa: homeTeamNameFa,
        awayTeamNameEn: awayTeamNameEn,
        awayTeamNameFa: awayTeamNameFa,
        homeTeamLabel: homeTeamLabel,
        awayTeamLabel: awayTeamLabel,
      );
}
