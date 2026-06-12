import 'package:marcadores_mundial_app/domain/entities/stadium.dart';
import 'package:marcadores_mundial_app/domain/repositories/worldcup_repository.dart';

class GetStadiums {
  final WorldCupRepository repository;
  GetStadiums(this.repository);

  Future<List<Stadium>> call() => repository.getStadiums();
}
