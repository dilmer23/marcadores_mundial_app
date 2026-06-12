import 'package:marcadores_mundial_app/domain/entities/team.dart';
import 'package:marcadores_mundial_app/domain/entities/game.dart';
import 'package:marcadores_mundial_app/domain/entities/group_standing.dart';
import 'package:marcadores_mundial_app/domain/entities/stadium.dart';

abstract class WorldCupRepository {
  Future<List<Team>> getTeams();
  Future<List<Game>> getGames();
  Future<List<GroupStanding>> getGroupStandings();
  Future<List<Stadium>> getStadiums();
}
