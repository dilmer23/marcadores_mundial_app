import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:marcadores_mundial_app/core/constants/api_constants.dart';
import 'package:marcadores_mundial_app/core/errors/exceptions.dart';
import 'package:marcadores_mundial_app/data/models/team_model.dart';
import 'package:marcadores_mundial_app/data/models/game_model.dart';
import 'package:marcadores_mundial_app/data/models/group_standing_model.dart';
import 'package:marcadores_mundial_app/data/models/stadium_model.dart';
import 'package:marcadores_mundial_app/data/database/prediction_database.dart';

class WorldCupRemoteDataSource {
  final http.Client client;

  WorldCupRemoteDataSource(this.client);

  Future<List<TeamModel>> getTeams() async {
    try {
      final response = await client
          .get(Uri.parse('${ApiConstants.baseUrl}${ApiConstants.teamsEndpoint}'))
          .timeout(ApiConstants.timeout);
      if (response.statusCode == 200) {
        await PredictionDatabase.cacheData('teams', response.body);
        final data = json.decode(response.body) as Map<String, dynamic>;
        final teamsList = (data['teams'] as List<dynamic>?) ?? [];
        return teamsList
            .map((e) => TeamModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw ServerException('Error ${response.statusCode}');
    } catch (e) {
      return _getCached('teams', (v) {
        final data = json.decode(v) as Map<String, dynamic>;
        return (data['teams'] as List<dynamic>)
            .map((e) => TeamModel.fromJson(e as Map<String, dynamic>))
            .toList();
      });
    }
  }

  Future<List<GameModel>> getGames() async {
    try {
      final response = await client
          .get(Uri.parse('${ApiConstants.baseUrl}${ApiConstants.gamesEndpoint}'))
          .timeout(ApiConstants.timeout);
      if (response.statusCode == 200) {
        await PredictionDatabase.cacheData('games', response.body);
        final data = json.decode(response.body) as Map<String, dynamic>;
        final gamesList = (data['games'] as List<dynamic>?) ?? [];
        return gamesList
            .map((e) => GameModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw ServerException('Error ${response.statusCode}');
    } catch (e) {
      return _getCached('games', (v) {
        final data = json.decode(v) as Map<String, dynamic>;
        return (data['games'] as List<dynamic>)
            .map((e) => GameModel.fromJson(e as Map<String, dynamic>))
            .toList();
      });
    }
  }

  Future<List<GroupStandingModel>> getGroupStandings() async {
    try {
      final response = await client
          .get(Uri.parse('${ApiConstants.baseUrl}${ApiConstants.groupsEndpoint}'))
          .timeout(ApiConstants.timeout);
      if (response.statusCode == 200) {
        await PredictionDatabase.cacheData('standings', response.body);
        final data = json.decode(response.body) as Map<String, dynamic>;
        final groupsList = (data['groups'] as List<dynamic>?) ?? [];
        return groupsList
            .map((e) => GroupStandingModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw ServerException('Error ${response.statusCode}');
    } catch (e) {
      return _getCached('standings', (v) {
        final data = json.decode(v) as Map<String, dynamic>;
        return (data['groups'] as List<dynamic>)
            .map((e) => GroupStandingModel.fromJson(e as Map<String, dynamic>))
            .toList();
      });
    }
  }

  Future<List<StadiumModel>> getStadiums() async {
    try {
      final response = await client
          .get(Uri.parse('${ApiConstants.baseUrl}${ApiConstants.stadiumsEndpoint}'))
          .timeout(ApiConstants.timeout);
      if (response.statusCode == 200) {
        await PredictionDatabase.cacheData('stadiums', response.body);
        final data = json.decode(response.body) as Map<String, dynamic>;
        final stadiumsList = (data['stadiums'] as List<dynamic>?) ?? [];
        return stadiumsList
            .map((e) => StadiumModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw ServerException('Error ${response.statusCode}');
    } catch (e) {
      return _getCached('stadiums', (v) {
        final data = json.decode(v) as Map<String, dynamic>;
        return (data['stadiums'] as List<dynamic>)
            .map((e) => StadiumModel.fromJson(e as Map<String, dynamic>))
            .toList();
      });
    }
  }

  Future<List<T>> _getCached<T>(String key, List<T> Function(String) parser) async {
    final cached = await PredictionDatabase.getCachedData(key);
    if (cached != null) {
      return parser(cached);
    }
    throw const ServerException('No cached data available');
  }
}
