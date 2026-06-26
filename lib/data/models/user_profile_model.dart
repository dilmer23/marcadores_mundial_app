import 'package:marcadores_mundial_app/domain/entities/user_profile.dart';

class UserProfileModel {
  final String id;
  final String email;
  final String? nombre;
  final String? apellido;
  final String? telefono;
  final int? edad;
  final String role;
  final bool aceptaPoliticas;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfileModel({
    required this.id,
    required this.email,
    this.nombre,
    this.apellido,
    this.telefono,
    this.edad,
    this.role = 'user',
    this.aceptaPoliticas = false,
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      nombre: json['nombre'] as String?,
      apellido: json['apellido'] as String?,
      telefono: json['telefono'] as String?,
      edad: json['edad'] as int?,
      role: json['role'] as String? ?? 'user',
      aceptaPoliticas: json['acepta_politicas'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nombre': nombre,
      'apellido': apellido,
      'telefono': telefono,
      'edad': edad,
      'role': role,
      'acepta_politicas': aceptaPoliticas,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  UserProfile toEntity() {
    return UserProfile(
      id: id,
      email: email,
      nombre: nombre,
      apellido: apellido,
      telefono: telefono,
      edad: edad,
      role: role,
      aceptaPoliticas: aceptaPoliticas,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory UserProfileModel.fromEntity(UserProfile entity) {
    return UserProfileModel(
      id: entity.id,
      email: entity.email,
      nombre: entity.nombre,
      apellido: entity.apellido,
      telefono: entity.telefono,
      edad: entity.edad,
      role: entity.role,
      aceptaPoliticas: entity.aceptaPoliticas,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
