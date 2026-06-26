import 'package:marcadores_mundial_app/domain/entities/user_profile.dart';
import 'package:marcadores_mundial_app/domain/repositories/auth_repository.dart';
import 'package:marcadores_mundial_app/data/services/supabase_service.dart';
import 'package:marcadores_mundial_app/core/errors/exceptions.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseService _service;

  AuthRepositoryImpl(this._service);

  @override
  Future<void> signUp(String email, String password) async {
    try {
      await _service.signUp(email, password);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserProfile> signIn(String email, String password) async {
    try {
      final model = await _service.signIn(email, password);
      return model.toEntity();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _service.signOut();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _service.sendPasswordReset(email);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> resendConfirmationEmail(String email) async {
    try {
      await _service.resendConfirmationEmail(email);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> isEmailConfirmed() async {
    try {
      return await _service.isEmailConfirmed();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<UserProfile?> getCurrentProfile() async {
    try {
      final uid = _service.currentUserId;
      if (uid == null) return null;
      final model = await _service.getProfile(uid);
      return model?.toEntity();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<UserProfile> completeProfile({
    required String nombre,
    required String apellido,
    required String telefono,
    required int edad,
    required bool aceptaPoliticas,
  }) async {
    try {
      final uid = _service.currentUserId;
      final email = _service.currentUserEmail;
      if (uid == null || email == null) {
        throw const ServerException('Sesión no encontrada');
      }
      final model = await _service.completeProfile(
        userId: uid,
        email: email,
        nombre: nombre,
        apellido: apellido,
        telefono: telefono,
        edad: edad,
        aceptaPoliticas: aceptaPoliticas,
      );
      return model.toEntity();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> isSignedIn() async {
    return _service.hasSession;
  }

  @override
  bool get hasSession => _service.hasSession;
}
