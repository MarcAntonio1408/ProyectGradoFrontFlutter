import 'package:deteccion_persona_f/core/common/constants/app_constants.dart';
import 'package:deteccion_persona_f/features/auth/presentation/pages/auth_page.dart';
import 'package:deteccion_persona_f/features/auth/presentation/pages/onBoarding_screen.dart';
import 'package:deteccion_persona_f/main_screen.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

/// `SplashScreen` es un StatefulWidget que muestra una pantalla de bienvenida animada
/// al iniciar la aplicación.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

/// El estado para `SplashScreen`.
/// Utiliza `TickerProviderStateMixin` para proporcionar los `Ticker`s necesarios
/// para las animaciones.
class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Controlador principal para las animaciones.
  late AnimationController _controller;
  // Animación para el efecto de desvanecimiento (fade in).
  late Animation<double> _fadeInAnimation;
  // Animación para el efecto de deslizamiento hacia arriba.
  late Animation<Offset> _slideUpAnimation;
  // Animación para el efecto de escalado.
  late Animation<double> _scaleUpAnimation;

  // TODO: Reemplazar estos valores simulados con la lógica de estado real de la app.
  // Por ejemplo, leer desde SharedPreferences o un servicio de autenticación.
  final bool hasSeenOnboarding = false;
  final bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    // Inicializa el controlador de animación con una duración de 1.2 segundos.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Define la animación de desvanecimiento usando una curva `easeOut`.
    _fadeInAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    // Define la animación de deslizamiento desde abajo hacia arriba.
    _slideUpAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Define la animación de escalado para un efecto de "rebote".
    _scaleUpAnimation = Tween<double>(
      begin: 0.96,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    // Inicia las animaciones.
    _controller.forward();

    // Navega a la siguiente pantalla después de un retraso de 2 segundos.
    Future.delayed(const Duration(milliseconds: 2000), () {
      // Comprueba si el widget todavía está montado en el árbol de widgets.
      if (mounted) {
        Widget nextScreen;
        // Lógica para determinar la siguiente pantalla a mostrar.
        if (!hasSeenOnboarding) {
          // Si el usuario no ha visto el onboarding, muéstralo.
          nextScreen = const OnboardingScreen();
        } else if (!isLoggedIn) {
          // Si ha visto el onboarding pero no ha iniciado sesión, muestra la pantalla de autenticación.
          nextScreen = const AuthPage();
        } else {
          // Si ya ha iniciado sesión, llévalo a la pantalla principal.
          nextScreen = const MainScreen();
        }
        // Realiza la navegación reemplazando la pantalla actual (SplashScreen)
        // para que el usuario no pueda volver a ella.
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
            // Usa una transición de desvanecimiento para una navegación suave.
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    // Libera los recursos del controlador de animación para evitar fugas de memoria.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        // `AnimatedBuilder` reconstruye el widget cuando los valores de la animación cambian.
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            // Combina múltiples transiciones para un efecto de entrada complejo.
            return FadeTransition(
              opacity: _fadeInAnimation,
              child: SlideTransition(
                position: _slideUpAnimation,
                child: ScaleTransition(
                  scale: _scaleUpAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo minimalista de la aplicación.
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppConstants.primaryColor.withOpacity(0.1),
                              AppConstants.primaryColor.withOpacity(0.2),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              FluentSystemIcons.ic_fluent_shield_filled,
                              color: AppConstants.primaryColor,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Título de la marca.
                      Text(
                        'VigiIA',
                        style: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Eslogan o lema de la aplicación.
                      Text(
                        'Detección en tiempo real, protección sin descanso.',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Indicador de progreso circular.
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppConstants.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
