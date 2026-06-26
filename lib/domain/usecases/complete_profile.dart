import 'package:marcadores_mundial_app/domain/entities/user_profile.dart';
import 'package:marcadores_mundial_app/domain/repositories/auth_repository.dart';

class CompleteProfile {
  final AuthRepository repository;
  CompleteProfile(this.repository);

  Future<UserProfile> call({
    required String nombre,
    required String apellido,
    required String telefono,
    required int edad,
    required bool aceptaPoliticas,
  }) => repository.completeProfile(
    nombre: nombre,
    apellido: apellido,
    telefono: telefono,
    edad: edad,
    aceptaPoliticas: aceptaPoliticas,
  );
}
