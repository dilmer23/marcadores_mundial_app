import 'package:marcadores_mundial_app/domain/entities/user_profile.dart';
import 'package:marcadores_mundial_app/domain/repositories/auth_repository.dart';

class SignIn {
  final AuthRepository repository;
  SignIn(this.repository);

  Future<UserProfile> call(String email, String password) =>
      repository.signIn(email, password);
}
