class HeadToHead {
  final String team1;
  final String team2;
  final int team1Wins;
  final int team2Wins;
  final int draws;
  final int team1Goals;
  final int team2Goals;
  final String lastMeeting;
  final String lastScore;

  const HeadToHead({
    required this.team1,
    required this.team2,
    required this.team1Wins,
    required this.team2Wins,
    required this.draws,
    required this.team1Goals,
    required this.team2Goals,
    required this.lastMeeting,
    required this.lastScore,
  });
}

final headToHeadData = {
  'Argentina-Brazil': const HeadToHead(
    team1: 'Argentina',
    team2: 'Brazil',
    team1Wins: 42,
    team2Wins: 43,
    draws: 26,
    team1Goals: 162,
    team2Goals: 167,
    lastMeeting: 'World Cup 2022 QF',
    lastScore: '2-1 (Argentina)',
  ),
  'Germany-Italy': const HeadToHead(
    team1: 'Germany',
    team2: 'Italy',
    team1Wins: 9,
    team2Wins: 15,
    draws: 11,
    team1Goals: 39,
    team2Goals: 51,
    lastMeeting: 'UEFA Nations League 2022',
    lastScore: '1-1',
  ),
  'England-Germany': const HeadToHead(
    team1: 'England',
    team2: 'Germany',
    team1Wins: 13,
    team2Wins: 16,
    draws: 5,
    team1Goals: 50,
    team2Goals: 58,
    lastMeeting: 'Euro 2020 R16',
    lastScore: '2-0 (England)',
  ),
  'France-Germany': const HeadToHead(
    team1: 'France',
    team2: 'Germany',
    team1Wins: 12,
    team2Wins: 10,
    draws: 7,
    team1Goals: 49,
    team2Goals: 48,
    lastMeeting: 'World Cup 2014 QF',
    lastScore: '1-0 (Germany)',
  ),
  'Netherlands-Argentina': const HeadToHead(
    team1: 'Netherlands',
    team2: 'Argentina',
    team1Wins: 5,
    team2Wins: 4,
    draws: 5,
    team1Goals: 18,
    team2Goals: 16,
    lastMeeting: 'World Cup 2022 QF',
    lastScore: '3-4 pens (2-2 aet)',
  ),
  'Portugal-Spain': const HeadToHead(
    team1: 'Portugal',
    team2: 'Spain',
    team1Wins: 6,
    team2Wins: 16,
    draws: 6,
    team1Goals: 30,
    team2Goals: 57,
    lastMeeting: 'World Cup 2018 Group',
    lastScore: '3-3',
  ),
  'Mexico-USA': const HeadToHead(
    team1: 'Mexico',
    team2: 'USA',
    team1Wins: 36,
    team2Wins: 22,
    draws: 17,
    team1Goals: 92,
    team2Goals: 74,
    lastMeeting: 'Gold Cup 2023',
    lastScore: '1-0 (Mexico)',
  ),
  'England-France': const HeadToHead(
    team1: 'England',
    team2: 'France',
    team1Wins: 17,
    team2Wins: 10,
    draws: 5,
    team1Goals: 52,
    team2Goals: 41,
    lastMeeting: 'World Cup 2022 QF',
    lastScore: '2-1 (France)',
  ),
};
