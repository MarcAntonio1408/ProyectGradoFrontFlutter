import 'package:deteccion_persona_f/core/common/constants/app_constants.dart';
import 'package:deteccion_persona_f/features/auth/data/auth_service.dart';
import 'package:deteccion_persona_f/features/auth/presentation/pages/forgot_password_screen.dart';
import 'package:deteccion_persona_f/features/auth/presentation/widgets/auth_widgets.dart';
import 'package:deteccion_persona_f/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// `AuthPage` es un StatefulWidget que representa la pantalla principal de autenticación.
/// Contiene la lógica para alternar entre los formularios de inicio de sesión y registro.
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

/// El estado para `AuthPage`.
/// Utiliza `SingleTickerProviderStateMixin` para proporcionar el `Ticker` necesario
/// para las animaciones del `TabController`.
class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  // Controlador para gestionar las pestañas de "Sign In" y "Sign Up".
  late TabController _tabController;

  // Clave global para el formulario de inicio de sesión, usada para validación.
  final _signInFormKey = GlobalKey<FormState>();
  // Controladores para los campos de texto del formulario de inicio de sesión.
  final _signInEmailController = TextEditingController();
  final _signInPasswordController = TextEditingController();

  // Clave global para el formulario de registro.
  final _signUpFormKey = GlobalKey<FormState>();
  // Controladores para los campos de texto del formulario de registro.
  final _signUpNameController = TextEditingController();
  final _signUpEmailController = TextEditingController();
  final _signUpPasswordController = TextEditingController();
  final _signUpConfirmPasswordController = TextEditingController();
  final _signUpFullNameController = TextEditingController();

  // Estado de carga y servicio
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    // Inicializa el TabController con 2 pestañas.
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    // Libera los recursos de los controladores para evitar fugas de memoria.
    _tabController.dispose();
    _signInEmailController.dispose();
    _signInPasswordController.dispose();
    _signUpNameController.dispose();
    _signUpEmailController.dispose();
    _signUpPasswordController.dispose();
    _signUpConfirmPasswordController.dispose();
    _signUpFullNameController.dispose();
    super.dispose();
  }

  /// Valida y procesa el formulario de inicio de sesión.
  Future<void> _onSignInPressed() async {
    if (_signInFormKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      bool loginSuccess = false;
      try {
        await _authService.login(
          _signInEmailController.text.trim(),
          _signInPasswordController.text.trim(),
        );
        loginSuccess = true;

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
          );
        }
      } finally {
        if (mounted && !loginSuccess) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  /// Valida y procesa el formulario de registro.
  Future<void> _onSignUpPressed() async {
    if (_signUpFormKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _authService.register(
          _signUpNameController.text.trim(),
          _signUpEmailController.text.trim(),
          _signUpPasswordController.text.trim(),
          _signUpFullNameController.text.trim(),
        );

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _continueAsGuest() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Cabecera que contiene el título y las pestañas.
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppConstants.defaultBorderRadius,
                      ),
                      child: Image.asset(
                        'assets/images/login_createuser.png',
                        height: 180,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Título de bienvenida.
                  Text(
                    'Bienvenidos',
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Subtítulo.
                  Text(
                    'Sign in or create an account to continue',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Contenedor de las pestañas.
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(
                        AppConstants.defaultBorderRadius,
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      // Estilos para el indicador de la pestaña seleccionada.
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorColor: AppConstants.primaryColor,
                      indicator: BoxDecoration(
                        color: AppConstants.primaryColor,
                        borderRadius: BorderRadius.circular(
                          AppConstants.defaultBorderRadius,
                        ),
                      ),
                      // Estilos para el texto de las pestañas.
                      dividerColor: Colors.transparent,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey[600],
                      labelStyle: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      tabs: const [
                        Tab(text: 'Sign In'),
                        Tab(text: 'Sign Up'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Contenido que cambia según la pestaña seleccionada.
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  //Sign In
                  _buildSignInTab(),
                  //Sign Up
                  _buildSignUpTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye el contenido de la pestaña "Sign In".
  Widget _buildSignInTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Formulario de inicio de sesión.
          Form(
            key: _signInFormKey,
            child: Column(
              children: [
                AuthTextField(
                  label: 'Email',
                  hint: 'Enter your email',
                  controller: _signInEmailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                AuthTextField(
                  label: 'Password',
                  hint: 'Enter your password',
                  controller: _signInPasswordController,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Forgot Password?',
                      style: GoogleFonts.outfit(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                AuthButton(
                  text: 'Sign In',
                  onPressed: _onSignInPressed,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 16),
                ReusabledOutlinedButton(
                  text: 'Continue as Guest',
                  onPressed: _continueAsGuest,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Sección para cambiar a la pestaña de registro.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Don\'t have an account?',
                style: GoogleFonts.outfit(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              TextButton(
                onPressed: () {
                  _tabController.animateTo(1); //Switch to sign up tab
                },
                child: Text(
                  'Sign Up',
                  style: GoogleFonts.outfit(
                    color: AppConstants.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Construye el contenido de la pestaña "Sign Up".
  Widget _buildSignUpTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Formulario de registro.
          Form(
            key: _signUpFormKey,
            child: Column(
              children: [
                AuthTextField(
                  label: 'Nombre de Usuario',
                  hint: 'Ingrese su Nombre de Usuario',
                  controller: _signUpNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese su nombre de Usuario';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                AuthTextField(
                  label: 'Email',
                  hint: 'Ingrese su email',
                  controller: _signUpEmailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese su email';
                    }
                    if (!value.contains('@')) {
                      return 'Por favor ingrese un email válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                AuthTextField(
                  label: 'Password',
                  hint: 'Cree una contraseña',
                  controller: _signUpPasswordController,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese una contraseña';
                    }
                    if (value.length < 6) {
                      return 'La contraseña debe tener al menos una mayuscula, minuscula, un numero, y 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                AuthTextField(
                  label: 'Confirme su contraseña',
                  hint: 'Confirme su contraseña',
                  controller: _signUpConfirmPasswordController,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor confirme su contraseña';
                    }
                    if (value != _signUpPasswordController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                AuthTextField(
                  label: 'Nombre Completo',
                  hint: 'Ingrese su Nombre Completo',
                  controller: _signUpFullNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese su nombre completo';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          AuthButton(
            text: 'Cree una Cuenta',
            onPressed: _onSignUpPressed,
            isLoading: _isLoading,
          ),
          const SizedBox(height: 16),
          // ReusabledOutlinedButton(
          //   text: 'Continue as Guest',
          //   onPressed: _continueAsGuest,
          // ),
          const SizedBox(height: 24),
          // Sección para cambiar a la pestaña de inicio de sesión.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Ya tienes una cuenta?',
                style: GoogleFonts.outfit(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              TextButton(
                onPressed: () {
                  _tabController.animateTo(0); //Switch to sign in tab
                },
                child: Text(
                  'Sign In',
                  style: GoogleFonts.outfit(
                    color: AppConstants.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
