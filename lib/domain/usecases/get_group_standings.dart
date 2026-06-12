import 'package:marcadores_mundial_app/domain/entities/group_standing.dart';
import 'package:marcadores_mundial_app/domain/repositories/worldcup_repository.dart';

class GetGroupStandings {
  final WorldCupRepository repository;
  GetGroupStandings(this.repository);

  Future<List<GroupStanding>> call() => repository.getGroupStandings();
}
