import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:deteccion_persona_f/core/common/constants/app_constants.dart';
import 'package:deteccion_persona_f/features/personas/data/getAll.dart';

class PersonasService {
  Future<List<DatosPersonas>> getAllPersonas() async {
    final uri = Uri.parse('${AppConstants.apiBaseUrl}/personas');

    try {
      final headers = {
        'Content-Type': 'application/json',
        if (AppConstants.authToken != null) 'Authorization': 'Bearer ${AppConstants.authToken}',
      };

      final response = await http.get(
        uri,
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => DatosPersonas.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar personas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<DatosPersonas>> findByUser(String userId) async {
    final uri = Uri.parse('${AppConstants.apiBaseUrl}/personas/user/$userId');

    try {
      final headers = {
        'Content-Type': 'application/json',
        if (AppConstants.authToken != null) 'Authorization': 'Bearer ${AppConstants.authToken}',
      };

      final response = await http.get(
        uri,
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => DatosPersonas.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar personas del usuario: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> createPersona({
    required String name,
    String? alias,
    String? notes,
    String? requestedBy,
    String? phone,
    File? image,
  }) async {
    final uri = Uri.parse('${AppConstants.apiBaseUrl}/personas');
    final request = http.MultipartRequest('POST', uri);

    // Agrega campos de texto
    request.fields['namePersona'] = name;
    if (alias != null && alias.isNotEmpty) request.fields['alias'] = alias;
    if (notes != null && notes.isNotEmpty) request.fields['notas'] = notes;
    if (requestedBy != null && requestedBy.isNotEmpty) request.fields['personaSolicitada'] = requestedBy;
    if (phone != null && phone.isNotEmpty) request.fields['telefono'] = phone;

    // Agrega la imagen si existe
    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('foto', image.path));
    }

    if (AppConstants.authToken != null) {
      request.headers['Authorization'] = 'Bearer ${AppConstants.authToken}';
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al registrar: ${response.body}');
    }
  }
}