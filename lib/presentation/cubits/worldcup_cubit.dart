import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:marcadores_mundial_app/core/errors/exceptions.dart';
import 'package:marcadores_mundial_app/domain/entities/team.dart';
import 'package:marcadores_mundial_app/domain/entities/game.dart';
import 'package:marcadores_mundial_app/domain/entities/group_standing.dart';
import 'package:marcadores_mundial_app/domain/entities/stadium.dart';
import 'package:marcadores_mundial_app/domain/repositories/worldcup_repository.dart';

class WorldCupState extends Equatable {
  final List<Team> teams;
  final List<Game> games;
  final List<GroupStanding> groupStandings;
  final List<Stadium> stadiums;
  final bool isLoading;
  final String? error;

  const WorldCupState({
    this.teams = const [],
    this.games = const [],
    this.groupStandings = const [],
    this.stadiums = const [],
    this.isLoading = false,
    this.error,
  });

  WorldCupState copyWith({
    List<Team>? teams,
    List<Game>? games,
    List<GroupStanding>? groupStandings,
    List<Stadium>? stadiums,
    bool? isLoading,
    String? error,
  }) {
    return WorldCupState(
      teams: teams ?? this.teams,
      games: games ?? this.games,
      groupStandings: groupStandings ?? this.groupStandings,
      stadiums: stadiums ?? this.stadiums,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props =>
      [teams, games, groupStandings, stadiums, isLoading, error];
}

class WorldCupCubit extends Cubit<WorldCupState> {
  final WorldCupRepository repository;

  WorldCupCubit(this.repository) : super(const WorldCupState());

  Map<String, Team> get teamMap {
    final map = <String, Team>{};
    for (final team in state.teams) {
      map[team.id] = team;
    }
    return map;
  }

  List<Game> get upcomingGames {
    return state.games
        .where((g) => !g.finished && g.timeElapsed == 'notstarted')
        .toList()
      ..sort((a, b) => a.localDate.compareTo(b.localDate));
  }

  List<Game> get liveGames {
    return state.games
        .where((g) => g.timeElapsed == 'live' || g.timeElapsed == 'finished')
        .toList()
      ..sort((a, b) => a.localDate.compareTo(b.localDate));
  }

  Team? getTeamById(String id) {
    try {
      return state.teams.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> loadAllData() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final results = await Future.wait([
        repository.getTeams(),
        repository.getGames(),
        repository.getGroupStandings(),
        repository.getStadiums(),
      ]);
      emit(state.copyWith(
        isLoading: false,
        teams: results[0] as List<Team>,
        games: results[1] as List<Game>,
        groupStandings: results[2] as List<GroupStanding>,
        stadiums: results[3] as List<Stadium>,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e is ServerException ? e.message : 'Connection error',
      ));
    }
  }

  void clearError() => emit(state.copyWith(error: null));
}
