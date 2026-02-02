import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:deteccion_persona_f/core/common/constants/app_constants.dart';
import 'package:deteccion_persona_f/features/auth/data/auth_logins.dart';

class AuthService {
  /// Verifica la conexión con el backend haciendo una petición simple.
  /// Imprime logs en la consola para indicar el estado de la conexión.
  Future<void> checkBackendConnection() async {
    // Basado en tu .env, la URL es http://localhost:3000/api
    final uri = Uri.parse(AppConstants.apiBaseUrl);
    print('--- [Health Check] Verificando conexión con el backend ---');
    print('--- [Health Check] URL de destino: $uri');
    try {
      // Usamos un timeout corto para no bloquear la app por mucho tiempo.
      // Una petición a la raíz del API debería ser suficiente para saber si está vivo.
      await http.get(uri).timeout(const Duration(seconds: 5));
      print('--- [Health Check] Conexión con el backend establecida exitosamente.');
    } catch (e) {
      print('--- [Health Check] ERROR: No se pudo conectar con el backend.');
      print('--- [Health Check] Causa del error: $e');
      print('--- [Health Check] Asegúrate de que el servidor NestJS esté corriendo en la dirección correcta.');
    }
  }

  Future<DatosUsuarios> login(String email, String password) async {
    final uri = Uri.parse('${AppConstants.apiBaseUrl}/auth/login');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'correo': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        // La respuesta del backend debe contener el token y los datos del usuario.
        // Si el token no está, la autenticación no puede continuar.
        if (!data.containsKey('token') || data['token'] == null) {
          throw Exception('La respuesta del servidor no incluyó un token de autenticación.');
        }

        // Guardamos el token y los datos del usuario.
        // Asumimos que los datos del usuario vienen en el cuerpo principal de la respuesta
        // junto al token, como en tu ejemplo. Si vinieran anidados en una clave "user",
        // se usaría: DatosUsuarios.fromJson(data['user'])
        AppConstants.authToken = data['token'];
        final user = DatosUsuarios.fromJson(data.containsKey('user') ? data['user'] : data);
        AppConstants.currentUser = user;
        return user;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Error en las credenciales');
      }
    } catch (e) {
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
        // Se asume que la respuesta de registro también devuelve un token para iniciar sesión automáticamente.
        if (!data.containsKey('token') || data['token'] == null) {
          throw Exception('La respuesta del servidor no incluyó un token de autenticación tras el registro.');
        }

        AppConstants.authToken = data['token'];
        final user = DatosUsuarios.fromJson(data.containsKey('user') ? data['user'] : data);
        AppConstants.currentUser = user;

        return user;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Error en el registro');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<DatosUsuarios>> getAllUsers() async {
    final uri = Uri.parse('${AppConstants.apiBaseUrl}/auth');

    try {
      final headers = {
        'Content-Type': 'application/json',
        if (AppConstants.authToken != null) 'Authorization': 'Bearer ${AppConstants.authToken}',
      };

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => DatosUsuarios.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar usuarios: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> deleteUser(String id) async {
    final uri = Uri.parse('${AppConstants.apiBaseUrl}/auth/$id');

    try {
      final headers = {
        'Content-Type': 'application/json',
        if (AppConstants.authToken != null) 'Authorization': 'Bearer ${AppConstants.authToken}',
      };

      final response = await http.delete(uri, headers: headers);

      if (response.statusCode != 200 && response.statusCode != 204) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Error al eliminar usuario');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> createUser({
    required String username,
    required String email,
    required String password,
    required String fullName,
    required List<String> roles,
  }) async {
    final uri = Uri.parse('${AppConstants.apiBaseUrl}/auth/register');

    try {
      final headers = {
        'Content-Type': 'application/json',
        if (AppConstants.authToken != null) 'Authorization': 'Bearer ${AppConstants.authToken}',
      };

      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode({
          'nombreUsuario': username,
          'correo': email,
          'password': password,
          'nombreCompleto': fullName,
          'roles': roles,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Error al crear usuario');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> updateUser(
    String id, {
    String? username,
    String? email,
    String? password,
    String? fullName,
    List<String>? roles,
  }) async {
    final uri = Uri.parse('${AppConstants.apiBaseUrl}/auth/$id');

    try {
      final headers = {
        'Content-Type': 'application/json',
        if (AppConstants.authToken != null) 'Authorization': 'Bearer ${AppConstants.authToken}',
      };

      final body = jsonEncode({
        if (username != null) 'nombreUsuario': username,
        if (email != null) 'correo': email,
        if (password != null && password.isNotEmpty) 'password': password,
        if (fullName != null) 'nombreCompleto': fullName,
        if (roles != null) 'roles': roles,
      });

      final response = await http.patch(uri, headers: headers, body: body);

      if (response.statusCode != 200) {
        throw Exception('Error al actualizar usuario: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> toggleUserStatus(String id) async {
    final uri = Uri.parse('${AppConstants.apiBaseUrl}/auth/estado/$id');

    try {
      final headers = {
        'Content-Type': 'application/json',
        if (AppConstants.authToken != null) 'Authorization': 'Bearer ${AppConstants.authToken}',
      };

      final response = await http.patch(uri, headers: headers);

      if (response.statusCode != 200) {
        throw Exception('Error al cambiar estado: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<DatosUsuarios> checkAuthStatus() async {
    final uri = Uri.parse('${AppConstants.apiBaseUrl}/auth/check-status');

    try {
      final headers = {
        'Content-Type': 'application/json',
        if (AppConstants.authToken != null) 'Authorization': 'Bearer ${AppConstants.authToken}',
      };

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        if (data.containsKey('token') && data['token'] != null) {
          AppConstants.authToken = data['token'];
        }

        final user = DatosUsuarios.fromJson(data.containsKey('user') ? data['user'] : data);
        AppConstants.currentUser = user;
        return user;
      } else {
        throw Exception('Error al verificar estado: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
