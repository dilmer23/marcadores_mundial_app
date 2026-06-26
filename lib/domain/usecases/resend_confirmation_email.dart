import 'package:marcadores_mundial_app/domain/repositories/auth_repository.dart';

class ResendConfirmationEmail {
  final AuthRepository repository;
  ResendConfirmationEmail(this.repository);

  Future<void> call(String email) => repository.resendConfirmationEmail(email);
}
