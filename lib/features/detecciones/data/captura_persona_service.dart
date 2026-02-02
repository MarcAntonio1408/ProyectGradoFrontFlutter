import 'dart:convert';
import 'package:deteccion_persona_f/core/common/constants/app_constants.dart';
import 'package:deteccion_persona_f/features/detecciones/data/captura_persona_model.dart';
import 'package:http/http.dart' as http;

class CapturaPersonaService {
  Future<List<CapturaPersonaModel>> getAllCapturas() async {
    final uri = Uri.parse('${AppConstants.apiBaseUrl}/captura-persona');

    try {
      final headers = {
        'Content-Type': 'application/json',
        if (AppConstants.authToken != null) 'Authorization': 'Bearer ${AppConstants.authToken}',
      };

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => CapturaPersonaModel.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar detecciones: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> actualizarEstadoEncontrado(String id) async {
    final uri = Uri.parse('${AppConstants.apiBaseUrl}/captura-persona/$id/encontrado');

    try {
      final headers = {
        'Content-Type': 'application/json',
        if (AppConstants.authToken != null) 'Authorization': 'Bearer ${AppConstants.authToken}',
      };

      final response = await http.patch(uri, headers: headers);

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Error al actualizar estado: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}