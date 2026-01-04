class DatosUsuarios {
  String id;
  String nombreUsuario;
  String correo;
  String nombreCompleto;
  bool isActive;
  List<String> roles;
  DateTime createdAt;
  DateTime updatedAt;

  DatosUsuarios({
    required this.id,
    required this.nombreUsuario,
    required this.correo,
    required this.nombreCompleto,
    required this.isActive,
    required this.roles,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DatosUsuarios.fromJson(Map<String, dynamic> json) {
    return DatosUsuarios(
      id: json['id'] ?? '',
      nombreUsuario: json['nombreUsuario'] ?? json['username'] ?? '',
      correo: json['correo'] ?? json['email'] ?? '',
      nombreCompleto: json['nombreCompleto'] ?? json['fullName'] ?? '',
      isActive: json['isActive'] ?? false,
      roles: List<String>.from(json['roles'] ?? []),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}
