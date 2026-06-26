import 'package:marcadores_mundial_app/domain/repositories/auth_repository.dart';

class CheckEmailConfirmed {
  final AuthRepository repository;
  CheckEmailConfirmed(this.repository);

  Future<bool> call() => repository.isEmailConfirmed();
}
