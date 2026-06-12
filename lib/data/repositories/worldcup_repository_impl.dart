import 'package:marcadores_mundial_app/core/errors/exceptions.dart';
import 'package:marcadores_mundial_app/domain/entities/team.dart';
import 'package:marcadores_mundial_app/domain/entities/game.dart';
import 'package:marcadores_mundial_app/domain/entities/group_standing.dart';
import 'package:marcadores_mundial_app/domain/entities/stadium.dart';
import 'package:marcadores_mundial_app/domain/repositories/worldcup_repository.dart';
import 'package:marcadores_mundial_app/data/datasources/worldcup_remote_data_source.dart';

class WorldCupRepositoryImpl implements WorldCupRepository {
  final WorldCupRemoteDataSource remoteDataSource;

  WorldCupRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Team>> getTeams() async {
    try {
      final models = await remoteDataSource.getTeams();
      return models.map((e) => e.toEntity()).toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<List<Game>> getGames() async {
    try {
      final models = await remoteDataSource.getGames();
      return models.map((e) => e.toEntity()).toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<List<GroupStanding>> getGroupStandings() async {
    try {
      final models = await remoteDataSource.getGroupStandings();
      return models.map((e) => e.toEntity()).toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<List<Stadium>> getStadiums() async {
    try {
      final models = await remoteDataSource.getStadiums();
      return models.map((e) => e.toEntity()).toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }
}
