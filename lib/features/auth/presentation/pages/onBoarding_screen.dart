import 'package:deteccion_persona_f/core/common/constants/app_constants.dart';
import 'package:deteccion_persona_f/features/auth/presentation/pages/auth_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// `OnboardingScreen` es un StatefulWidget que muestra una serie de páginas de introducción
/// a los nuevos usuarios.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // Controlador para el PageView, permite la navegación programática entre páginas.
  final PageController _pageController = PageController();
  // Almacena el índice de la página actualmente visible.
  int _currentPage = 0;

  // Lista de datos para cada página de la introducción.
  final List<OnboardingPage> _pages = [
    OnboardingPage(
      image: 'assets/images/onboarding_img1.png',
      title: 'Discover Unique Products',
      description: 'Find the perfect pieces to make your home truly yours.',
    ),
    OnboardingPage(
      image: 'assets/images/onboarding_img3.png',
      title: 'Quality & Comfort',
      description:
          'Experience comfort with our high-quality furniture selection',
    ),
    OnboardingPage(
      image: 'assets/images/onboarding_img2.png',
      title: 'Fast Delivery',
      description: 'Get your product delivered right to your doorstep',
    ),
  ];

  @override
  void dispose() {
    // Libera los recursos del controlador para evitar fugas de memoria.
    _pageController.dispose();
    super.dispose();
  }

  /// Navega a la siguiente página o finaliza la introducción si es la última página.
  void _onNextPage() {
    if (_currentPage < _pages.length - 1) {
      // Anima la transición a la siguiente página.
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      // Si está en la última página, completa el proceso.
      _completeOnboarding();
    }
  }

  void _completeOnboarding() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AuthPage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          //Page View
          // Widget que permite deslizar entre las diferentes páginas.
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) { // Se activa cada vez que la página cambia.
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return _buildPage(_pages[index]);
            },
          ),

          // Skip Button
          // Botón para saltar la introducción y ir directamente a la app.
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: TextButton(
              onPressed: _completeOnboarding,
              child: Text(
                'Skip',
                style: GoogleFonts.outfit(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Controles inferiores (indicador de página y botón de siguiente).
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //Page Indicator
                children: [
                  Container( // Contenedor para los puntos del indicador.
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: AppConstants.primaryColor,
                      border: Border.all(color: AppConstants.primaryColor),
                    ),
                    child: Row(
                      children: List.generate(
                        _pages.length,
                        (index) => Container(
                          width: 8,
                          height: 8, // Punto individual del indicador.
                          margin: EdgeInsets.only(right: index == _pages.length - 1 ? 0 : 8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentPage == index
                                ? Colors.white
                                : Colors.grey[500],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Botón de "Next" o "Get Started".
                  ElevatedButton(
                    onPressed: _onNextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.defaultBorderRadius,
                        ),
                      ),
                    ),
                    // El texto del botón cambia en la última página.
                    child: Text(
                      _currentPage == _pages.length - 1
                          ? 'Get Started'
                          : 'Next',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye la UI para una única página de introducción.
  Widget _buildPage(OnboardingPage page) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Image.asset(
            page.image,
            height: MediaQuery.of(context).size.height * 0.4,
            fit: BoxFit.contain,
          ),
          const Spacer(),

          //Content
          Padding(
            padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
            child: Column(
              children: [
                Text(
                  page.title,
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  page.description,
                  style: GoogleFonts.outfit(
                    color: Colors.black87,
                    fontSize: 16,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const Spacer(),
        ],
      ),
    );
  }
}

/// Una clase modelo para almacenar los datos de cada página de introducción.
class OnboardingPage {
  final String image;
  final String title;
  final String description;

  OnboardingPage({
    required this.image,
    required this.title,
    required this.description,
  });
}
