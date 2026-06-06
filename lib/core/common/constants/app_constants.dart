import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:deteccion_persona_f/features/auth/data/auth_logins.dart';

/// Una clase que contiene constantes de diseño reutilizables en toda la aplicación.
/// Esto ayuda a mantener una interfaz de usuario consistente y facilita los cambios de estilo globales.
class AppConstants {
  // --- API ---
  // Usa 'http://10.0.2.2:3000/api' para emulador Android
  // Usa 'http://localhost:3000/api' para iOS o Web
  // static const String apiBaseUrl = 'http://10.0.2.2:3000/api'; //Emulador Android
  // static const String apiBaseUrl = 'http://10.0.2.2:3000/api';
  // static const String apiBaseUrl = 'http://192.168.100.3:3000/api'; // IP de tu adaptador Wi-Fi
   static const String apiBaseUrl = 'http://10.128.169.35:3000/api'; // IP de tu adaptador Wi-Fi (celular)
  
  // static const String apiBaseUrl = 'http://192.168.1.9:3000/api'; // IP de tu adaptador Wi-Fi
  // static const String apiBaseUrl = 'http://10.14.214.35:3000/api'; // IP de tu adaptador Wi-Fi
  
  // --- COLORES ---
  /// Color principal usado para elementos importantes como botones y acentos.
  static Color primaryColor = Color(0xFF085B63);
  /// Color secundario, una versión semitransparente del color primario.
  static Color secondaryColor = primaryColor.withOpacity(0.7);
  /// Color de fondo principal para la mayoría de las pantallas.
  static const Color backgroundColor = Colors.white;
  /// Color de texto por defecto.
  static const Color textColor = Color(0xFF1A1A1A);
  /// Un color gris claro, útil para fondos de campos de texto o divisores.
  static const Color greyColor = Color(0xFFF5F5F5);

  // --- ESTILOS DE TEXTO ---
  /// Estilo para encabezados principales.
  static TextStyle get headingStyle => GoogleFonts.outfit(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textColor,
  );

  /// Estilo para títulos de secciones o tarjetas.
  static TextStyle get titleStyle => GoogleFonts.outfit(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textColor,
  );

  /// Estilo para el cuerpo de texto general.
  static TextStyle get bodyStyle => GoogleFonts.outfit(
    fontSize: 16,
    color: textColor,
  );

  // --- ESPACIADO Y BORDES ---
  /// Relleno (padding) estándar.
  static const double defaultPadding = 16.0;
  /// Relleno pequeño.
  static const double smallPadding = 8.0;
  /// Relleno grande.
  static const double largePadding = 24.0;

  /// Radio de borde por defecto para botones y contenedores.
  static const double defaultBorderRadius = 26.0;
  /// Radio de borde pequeño.
  static const double smallBorderRadius = 8.0;
  /// Radio de borde grande.
  static const double largeBorderRadius = 16.0;
  
  // --- ANIMACIONES ---
  /// Duración estándar para animaciones de UI.
  static const Duration defaultDuration = Duration(milliseconds: 300);

  // --- SESIÓN (Simple In-Memory) ---
  static String? authToken;
  static DatosUsuarios? currentUser;
}