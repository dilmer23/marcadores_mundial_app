import 'package:marcadores_mundial_app/domain/entities/user_profile.dart';
import 'package:marcadores_mundial_app/domain/repositories/auth_repository.dart';

class GetCurrentProfile {
  final AuthRepository repository;
  GetCurrentProfile(this.repository);

  Future<UserProfile?> call() => repository.getCurrentProfile();
}
