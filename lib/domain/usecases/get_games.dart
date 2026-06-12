import 'package:marcadores_mundial_app/domain/entities/game.dart';
import 'package:marcadores_mundial_app/domain/repositories/worldcup_repository.dart';

class GetGames {
  final WorldCupRepository repository;
  GetGames(this.repository);

  Future<List<Game>> call() => repository.getGames();
}
