import 'package:marcadores_mundial_app/domain/repositories/auth_repository.dart';

class SendPasswordReset {
  final AuthRepository repository;
  SendPasswordReset(this.repository);

  Future<void> call(String email) => repository.sendPasswordReset(email);
}
