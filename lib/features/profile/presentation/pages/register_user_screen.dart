import 'package:deteccion_persona_f/core/common/constants/app_constants.dart';
import 'package:deteccion_persona_f/features/auth/data/auth_logins.dart';
import 'package:deteccion_persona_f/features/auth/data/auth_service.dart';
import 'package:deteccion_persona_f/features/auth/presentation/widgets/auth_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterUserScreen extends StatefulWidget {
  final DatosUsuarios? usuarioToEdit;
  const RegisterUserScreen({super.key, this.usuarioToEdit});

  @override
  State<RegisterUserScreen> createState() => _RegisterUserScreenState();
}

class _RegisterUserScreenState extends State<RegisterUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  
  // Rol seleccionado por defecto
  String _selectedRole = 'usuario';

  @override
  void initState() {
    super.initState();
    if (widget.usuarioToEdit != null) {
      _usernameController.text = widget.usuarioToEdit!.nombreUsuario;
      _emailController.text = widget.usuarioToEdit!.correo;
      _fullNameController.text = widget.usuarioToEdit!.nombreCompleto;
      _selectedRole = widget.usuarioToEdit!.roles.contains('admin') ? 'admin' : 'usuario';
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        if (widget.usuarioToEdit == null) {
          await _authService.createUser(
            username: _usernameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            fullName: _fullNameController.text.trim(),
            roles: [_selectedRole],
          );
        } else {
          await _authService.updateUser(
            widget.usuarioToEdit!.id,
            username: _usernameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(), // Puede estar vacío
            fullName: _fullNameController.text.trim(),
            roles: [_selectedRole],
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.usuarioToEdit == null ? 'Usuario creado con éxito' : 'Usuario actualizado con éxito'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
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
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.usuarioToEdit == null ? 'Agregar Usuario' : 'Editar Usuario',
          style: GoogleFonts.outfit(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AuthTextField(
                label: 'Nombre de Usuario',
                hint: 'Ej. jdoe',
                controller: _usernameController,
                validator: (value) => (value == null || value.isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),

              AuthTextField(
                label: 'Correo Electrónico',
                hint: 'Ej. usuario@email.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Requerido';
                  if (!value.contains('@')) return 'Correo inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              AuthTextField(
                label: 'Contraseña',
                hint: widget.usuarioToEdit == null ? 'Mínimo 6 caracteres' : 'Dejar en blanco para mantener',
                controller: _passwordController,
                isPassword: true,
                validator: (value) {
                  if (widget.usuarioToEdit == null && (value == null || value.isEmpty)) return 'Requerido';
                  if (value != null && value.isNotEmpty && value.length < 6) return 'Mínimo 6 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              AuthTextField(
                label: 'Nombre Completo',
                hint: 'Ej. John Doe',
                controller: _fullNameController,
                validator: (value) => (value == null || value.isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 24),

              Text(
                'Rol del Usuario',
                style: GoogleFonts.outfit(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: Text('Administrador', style: GoogleFonts.outfit()),
                      value: 'admin',
                      groupValue: _selectedRole,
                      activeColor: AppConstants.primaryColor,
                      onChanged: (value) => setState(() => _selectedRole = value!),
                    ),
                    Divider(height: 1, color: Colors.grey[300]),
                    RadioListTile<String>(
                      title: Text('Usuario', style: GoogleFonts.outfit()),
                      value: 'usuario',
                      groupValue: _selectedRole,
                      activeColor: AppConstants.primaryColor,
                      onChanged: (value) => setState(() => _selectedRole = value!),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              AuthButton(
                text: widget.usuarioToEdit == null ? 'Crear Usuario' : 'Guardar Cambios',
                isLoading: _isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}