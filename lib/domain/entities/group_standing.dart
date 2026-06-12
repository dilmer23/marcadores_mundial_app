class GroupStanding {
  final String groupName;
  final List<TeamStanding> teams;

  const GroupStanding({
    required this.groupName,
    required this.teams,
  });
}

class TeamStanding {
  final String teamId;
  final int mp;
  final int w;
  final int l;
  final int d;
  final int pts;
  final int gf;
  final int ga;
  final int gd;

  const TeamStanding({
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
}
