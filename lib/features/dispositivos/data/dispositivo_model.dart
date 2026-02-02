class DispositivoModel {
  final String id;
  final String nombreDispositivo;
  final String tipoDispositivo;
  final bool estado;
  final String caracteristicas;
  final String token;

  DispositivoModel({
    required this.id,
    required this.nombreDispositivo,
    required this.tipoDispositivo,
    required this.estado,
    required this.caracteristicas,
    required this.token,
  });

  factory DispositivoModel.fromJson(Map<String, dynamic> json) {
    return DispositivoModel(
      id: json['id']?.toString() ?? '',
      nombreDispositivo: json['nombreDispositivo']?.toString() ?? '',
      tipoDispositivo: json['tipoDispositivo']?.toString() ?? '',
      estado: json['estado'] ?? false,
      caracteristicas: json['caracteristicas']?.toString() ?? '',
      token: json['token']?.toString() ?? '',
    );
  }
}