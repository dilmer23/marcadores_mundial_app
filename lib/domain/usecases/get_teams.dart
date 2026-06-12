import 'package:marcadores_mundial_app/domain/entities/team.dart';
import 'package:marcadores_mundial_app/domain/repositories/worldcup_repository.dart';

class GetTeams {
  final WorldCupRepository repository;
  GetTeams(this.repository);

  Future<List<Team>> call() => repository.getTeams();
}
