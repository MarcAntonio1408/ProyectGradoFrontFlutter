class DatosPersonas {
  String id;
  String namePersona;
  String alias;
  String notas;
  String personaSolicitada;
  String telefono;
  bool encontrado;
  DateTime? fechaEncontada;
  String foto;
  User? user;
  DateTime createdAt;
  DateTime updatedAt;

  DatosPersonas({
    required this.id,
    required this.namePersona,
    required this.alias,
    required this.notas,
    required this.personaSolicitada,
    required this.telefono,
    required this.encontrado,
    required this.fechaEncontada,
    required this.foto,
    required this.user,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DatosPersonas.fromJson(Map<String, dynamic> json) {
    return DatosPersonas(
      id: json['id'] ?? '',
      namePersona: json['namePersona'] ?? '',
      alias: json['alias'] ?? '',
      notas: json['notas'] ?? '',
      personaSolicitada: json['personaSolicitada'] ?? '',
      telefono: json['telefono'] ?? '',
      encontrado: json['encontrado'] ?? false,
      fechaEncontada: json['fechaEncontada'] != null
          ? DateTime.tryParse(json['fechaEncontada'])
          : null,
      foto:
          json['filePath']?.toString() ??
          json['fileUrl']?.toString() ??
          json['filename']?.toString() ??
          json['foto']?.toString() ??
          '',
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class User {
  String id;
  String nombreUsuario;
  String correo;
  String nombreCompleto;
  bool isActive;
  List<Role> roles;
  DateTime createdAt;
  DateTime updatedAt;

  User({
    required this.id,
    required this.nombreUsuario,
    required this.correo,
    required this.nombreCompleto,
    required this.isActive,
    required this.roles,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      nombreUsuario: json['nombreUsuario'] ?? '',
      correo: json['correo'] ?? '',
      nombreCompleto: json['nombreCompleto'] ?? '',
      isActive: json['isActive'] ?? false,
      roles:
          (json['roles'] as List<dynamic>?)
              ?.map((role) => _parseRole(role.toString()))
              .toList() ??
          [],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  static Role _parseRole(String role) {
    return role.toUpperCase() == 'ADMIN' ? Role.ADMIN : Role.USER;
  }
}

enum Role { ADMIN, USER }
