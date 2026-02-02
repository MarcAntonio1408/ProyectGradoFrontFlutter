import 'package:deteccion_persona_f/core/common/constants/app_constants.dart';
import 'package:deteccion_persona_f/features/auth/data/auth_logins.dart';
import 'package:deteccion_persona_f/features/auth/data/auth_service.dart';
import 'package:deteccion_persona_f/features/auth/presentation/pages/auth_page.dart';
import 'package:deteccion_persona_f/features/profile/presentation/pages/register_user_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PerfilPages extends StatefulWidget {
  const PerfilPages({super.key});

  @override
  State<PerfilPages> createState() => _PerfilPagesState();
}

class _PerfilPagesState extends State<PerfilPages> {
  final AuthService _authService = AuthService();
  late Future<List<DatosUsuarios>> _usersFuture;

  @override
  void initState() {
    super.initState();
    final isAdmin = AppConstants.currentUser?.roles.contains('admin') ?? false;
    if (isAdmin) {
      _loadUsers();
    } else {
      _usersFuture = Future.value([]);
    }
  }

  void _loadUsers() {
    setState(() {
      _usersFuture = _authService.getAllUsers();
    });
  }

  void _signOut(BuildContext context) {
    // Limpiar los datos de la sesión
    AppConstants.authToken = null;
    AppConstants.currentUser = null;

    // Navegar a la página de login y eliminar todas las rutas anteriores
    // para que el usuario no pueda volver atrás.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const AuthPage()),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> _deleteUser(String id) async {
    try {
      await _authService.deleteUser(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuario eliminado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        _loadUsers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleStatus(String id) async {
    try {
      await _authService.toggleUserStatus(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Estado actualizado correctamente'),
            backgroundColor: Colors.blue,
          ),
        );
        _loadUsers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AppConstants.currentUser;
    final isAdmin = user?.roles.contains('admin') ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Perfil de Usuario',
          style: GoogleFonts.outfit(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (user != null) ...[
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 50,
                backgroundColor: AppConstants.primaryColor,
                child: const Icon(Icons.person, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                user.nombreCompleto,
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.correo,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Chip(
                label: Text(
                  user.roles.join(', ').toUpperCase(),
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                backgroundColor: AppConstants.primaryColor,
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _signOut(context),
                icon: const Icon(Icons.logout),
                label: const Text('Salir'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                  ),
                  textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            if (isAdmin) ...[
              const SizedBox(height: 32),
              // Sección de Gestión de Usuarios (Visible para todos o restringir según rol si se desea)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Usuarios Registrados',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.person_add, color: Colors.black),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RegisterUserScreen()),
                      ).then((_) => _loadUsers());
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<DatosUsuarios>>(
                future: _usersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('No hay usuarios registrados'));
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final usuario = snapshot.data![index];
                      final isActive = usuario.isActive;

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    usuario.nombreCompleto,
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    '@${usuario.nombreUsuario}',
                                    style: GoogleFonts.outfit(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    usuario.correo,
                                    style: GoogleFonts.outfit(
                                        color: Colors.grey[600], fontSize: 13),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isActive
                                              ? Colors.green.withOpacity(0.1)
                                              : Colors.red.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          isActive ? 'Activo' : 'Inactivo',
                                          style: GoogleFonts.outfit(
                                            color: isActive
                                                ? Colors.green
                                                : Colors.red,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Rol: ${usuario.roles.join(", ")}',
                                        style: GoogleFonts.outfit(
                                            fontSize: 12, color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    isActive
                                        ? Icons.toggle_on
                                        : Icons.toggle_off,
                                    color:
                                        isActive ? Colors.green : Colors.grey,
                                    size: 35,
                                  ),
                                  onPressed: () => _toggleStatus(usuario.id),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue, size: 30),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            RegisterUserScreen(
                                                usuarioToEdit: usuario),
                                      ),
                                    ).then((_) => _loadUsers());
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red, size: 30),
                                  onPressed: () => _deleteUser(usuario.id),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}