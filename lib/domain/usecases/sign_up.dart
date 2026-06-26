import 'package:marcadores_mundial_app/domain/repositories/auth_repository.dart';

class SignUp {
  final AuthRepository repository;
  SignUp(this.repository);

  Future<void> call(String email, String password) =>
      repository.signUp(email, password);
}
