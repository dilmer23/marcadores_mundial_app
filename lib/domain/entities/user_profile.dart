class UserProfile {
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

  const UserProfile({
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

  UserProfile copyWith({
    String? id,
    String? email,
    String? nombre,
    String? apellido,
    String? telefono,
    int? edad,
    String? role,
    bool? aceptaPoliticas,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      telefono: telefono ?? this.telefono,
      edad: edad ?? this.edad,
      role: role ?? this.role,
      aceptaPoliticas: aceptaPoliticas ?? this.aceptaPoliticas,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get hasCompletedProfile => nombre != null && nombre!.length >= 2;

  bool get isAdmin => role == 'admin';
}
