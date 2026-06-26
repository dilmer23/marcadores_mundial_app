import 'package:marcadores_mundial_app/domain/entities/user_profile.dart';

abstract class AuthRepository {
  Future<void> signUp(String email, String password);
  Future<UserProfile> signIn(String email, String password);
  Future<void> signOut();
  Future<void> sendPasswordReset(String email);
  Future<void> resendConfirmationEmail(String email);
  Future<bool> isEmailConfirmed();
  Future<UserProfile?> getCurrentProfile();
  Future<UserProfile> completeProfile({
    required String nombre,
    required String apellido,
    required String telefono,
    required int edad,
    required bool aceptaPoliticas,
  });
  Future<bool> isSignedIn();
  bool get hasSession;
}
