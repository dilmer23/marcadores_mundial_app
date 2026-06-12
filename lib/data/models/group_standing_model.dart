import 'package:marcadores_mundial_app/domain/entities/group_standing.dart';

class TeamStandingModel {
  final String teamId;
  final int mp;
  final int w;
  final int l;
  final int d;
  final int pts;
  final int gf;
  final int ga;
  final int gd;

  const TeamStandingModel({
    required this.teamId,
    required this.mp,
    required this.w,
    required this.l,
    required this.d,
    required this.pts,
    required this.gf,
    required this.ga,
    required this.gd,
  });

  factory TeamStandingModel.fromJson(Map<String, dynamic> json) {
    return TeamStandingModel(
      teamId: json['team_id'] as String? ?? '',
      mp: int.tryParse(json['mp'] as String? ?? '0') ?? 0,
      w: int.tryParse(json['w'] as String? ?? '0') ?? 0,
      l: int.tryParse(json['l'] as String? ?? '0') ?? 0,
      d: int.tryParse(json['d'] as String? ?? '0') ?? 0,
      pts: int.tryParse(json['pts'] as String? ?? '0') ?? 0,
      gf: int.tryParse(json['gf'] as String? ?? '0') ?? 0,
      ga: int.tryParse(json['ga'] as String? ?? '0') ?? 0,
      gd: int.tryParse(json['gd'] as String? ?? '0') ?? 0,
    );
  }

  TeamStanding toEntity() => TeamStanding(
        teamId: teamId,
        mp: mp,
        w: w,
        l: l,
        d: d,
        pts: pts,
        gf: gf,
        ga: ga,
        gd: gd,
      );
}

class GroupStandingModel {
  final String groupName;
  final List<TeamStandingModel> teams;

  const GroupStandingModel({
    required this.groupName,
    required this.teams,
  });

  factory GroupStandingModel.fromJson(Map<String, dynamic> json) {
    final teamsList = (json['teams'] as List<dynamic>?)
            ?.map((e) =>
                TeamStandingModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return GroupStandingModel(
      groupName: json['name'] as String? ?? '',
      teams: teamsList,
    );
  }

  GroupStanding toEntity() => GroupStanding(
        groupName: groupName,
        teams: teams.map((e) => e.toEntity()).toList(),
      );
}
