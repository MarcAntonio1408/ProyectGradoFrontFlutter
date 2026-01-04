import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:deteccion_persona_f/core/common/constants/app_constants.dart';
import 'package:deteccion_persona_f/features/auth/data/auth_logins.dart';

class AuthService {
  Future<DatosUsuarios> login(String email, String password) async {
    print('DEBUG: AuthService.login iniciado para: $email');
    final uri = Uri.parse('${AppConstants.apiBaseUrl}/auth/login');
    print('DEBUG: Intentando conectar a: $uri');

    try {
      print('DEBUG: Enviando petición HTTP POST...');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'correo': email,
          'password': password,
        }),
      );
      print('DEBUG: Respuesta recibida. Código: ${response.statusCode}');
      print('DEBUG: Cuerpo respuesta: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        // Ajuste: Dependiendo de si el backend devuelve { user: {...}, token: "..." }
        // o directamente el objeto usuario.
        if (data.containsKey('user')) {
          print('DEBUG: Procesando usuario desde data["user"]');
          return DatosUsuarios.fromJson(data['user']);
        }
        print('DEBUG: Procesando usuario desde raíz del JSON');
        return DatosUsuarios.fromJson(data);
      } else {
        print('DEBUG: El servidor devolvió un error');
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Error en las credenciales');
      }
    } catch (e) {
      print('DEBUG: Excepción en AuthService: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  Future<DatosUsuarios> register(String username, String email, String password, String fullName) async {
    final uri = Uri.parse('${AppConstants.apiBaseUrl}/auth/register');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombreUsuario': username,
          'correo': email,
          'password': password,
          'nombreCompleto': fullName,
          'roles': ['usuario'],
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return DatosUsuarios.fromJson(data.containsKey('user') ? data['user'] : data);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Error en el registro');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
