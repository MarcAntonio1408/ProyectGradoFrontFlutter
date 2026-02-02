import 'dart:convert';
import 'package:deteccion_persona_f/core/common/constants/app_constants.dart';
import 'package:deteccion_persona_f/features/dispositivos/data/dispositivo_model.dart';
import 'package:http/http.dart' as http;

class DispositivoService {
  Future<List<DispositivoModel>> getAllDispositivos() async {
    final uri = Uri.parse('${AppConstants.apiBaseUrl}/dispositivo');

    try {
      final headers = {
        'Content-Type': 'application/json',
        if (AppConstants.authToken != null) 'Authorization': 'Bearer ${AppConstants.authToken}',
      };

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => DispositivoModel.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar dispositivos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> deleteDispositivo(String id) async {
    final uri = Uri.parse('${AppConstants.apiBaseUrl}/dispositivo/$id');

    try {
      final headers = {
        'Content-Type': 'application/json',
        if (AppConstants.authToken != null) 'Authorization': 'Bearer ${AppConstants.authToken}',
      };

      final response = await http.delete(uri, headers: headers);

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error al eliminar dispositivo: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> createDispositivo({
    required String nombreDispositivo,
    String? tipoDispositivo,
    String? caracteristicas,
    String? token,
  }) async {
    final uri = Uri.parse('${AppConstants.apiBaseUrl}/dispositivo');

    try {
      final headers = {
        'Content-Type': 'application/json',
        if (AppConstants.authToken != null) 'Authorization': 'Bearer ${AppConstants.authToken}',
      };

      final body = jsonEncode({
        'nombreDispositivo': nombreDispositivo,
        if (tipoDispositivo != null && tipoDispositivo.isNotEmpty) 'tipoDispositivo': tipoDispositivo,
        if (caracteristicas != null && caracteristicas.isNotEmpty) 'caracteristicas': caracteristicas,
        if (token != null && token.isNotEmpty) 'token': token,
      });

      final response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Error al crear dispositivo: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> updateDispositivo(
    String id, {
    String? nombreDispositivo,
    String? tipoDispositivo,
    String? caracteristicas,
    String? token,
  }) async {
    final uri = Uri.parse('${AppConstants.apiBaseUrl}/dispositivo/$id');

    try {
      final headers = {
        'Content-Type': 'application/json',
        if (AppConstants.authToken != null) 'Authorization': 'Bearer ${AppConstants.authToken}',
      };

      final body = jsonEncode({
        if (nombreDispositivo != null) 'nombreDispositivo': nombreDispositivo,
        if (tipoDispositivo != null) 'tipoDispositivo': tipoDispositivo,
        if (caracteristicas != null) 'caracteristicas': caracteristicas,
        if (token != null) 'token': token,
      });

      final response = await http.patch(uri, headers: headers, body: body);

      if (response.statusCode != 200) {
        throw Exception('Error al actualizar dispositivo: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}