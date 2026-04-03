class CapturaPersonaModel {
  final String id;
  final String foto;
  final int faceCount;
  final String resultJson;
  final int clothingCount;
  final bool encontrado;
  final DateTime fecha;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String nombrePersona;
  final List<String> nombresPersonas;

  CapturaPersonaModel({
    required this.id,
    required this.foto,
    required this.faceCount,
    required this.resultJson,
    required this.clothingCount,
    required this.encontrado,
    required this.fecha,
    required this.createdAt,
    required this.updatedAt,
    required this.nombrePersona,
    required this.nombresPersonas,
  });

  factory CapturaPersonaModel.fromJson(Map<String, dynamic> json) {
    List<String> nombres = [];
    if (json['nombrePersonaEncontrada'] != null &&
        json['nombrePersonaEncontrada'] is List) {
      nombres = (json['nombrePersonaEncontrada'] as List).map((e) => e.toString()).toList();
    }

    if (nombres.isEmpty && json['persona'] != null && json['persona']['namePersona'] != null) {
      nombres.add(json['persona']['namePersona'].toString());
    }

    if (nombres.isEmpty) {
      nombres.add('Desconocido');
    }

    String nombre = nombres.join(', ');

    String ropa = 'Sin datos';
    int ropaCount = 0;
    if (json['clothesDetections'] != null &&
        json['clothesDetections'] is List &&
        (json['clothesDetections'] as List).isNotEmpty) {
      final List<String> items = [];
      for (var detection in (json['clothesDetections'] as List)) {
        ropaCount += int.tryParse(detection['clothingCount']?.toString() ?? '0') ?? 0;
        final dynamic result = detection['resultJson'];
        if (result is List) {
          items.addAll(result.map((e) => e.toString()));
        } else if (result != null) {
          items.add(result.toString());
        }
      }
      // Usar un Set para eliminar duplicados y luego unir.
      if (items.isNotEmpty) ropa = items.toSet().join(', ');
    } else if (json['resultJson'] != null) {
      final dynamic result = json['resultJson'];
      if (result is List) {
        ropa = result.join(', ');
      } else {
        ropa = result.toString();
      }
    }

    return CapturaPersonaModel(
      id: json['id']?.toString() ?? '',
      foto: json['filename']?.toString() ?? json['foto']?.toString() ?? '',
      faceCount: int.tryParse(json['faceCount']?.toString() ?? '0') ?? 0,
      resultJson: ropa,
      clothingCount: ropaCount,
      encontrado: json['encontrado'] ?? false,
      fecha: DateTime.tryParse(json['fecha']?.toString() ?? '') ?? DateTime.now(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
      nombrePersona: nombre,
      nombresPersonas: nombres,
    );
  }
}