import 'package:deteccion_persona_f/core/common/constants/app_constants.dart';

class ImageUtils {
  static String getImageUrl(String? image) {
    if (image == null || image.isEmpty) {
      return '';
    }

    // Si ya es una URL completa
    if (image.startsWith('http://') ||
        image.startsWith('https://')) {
      return image;
    }

    // Eliminar "/api" del final si existe
    final baseUrl = AppConstants.apiBaseUrl.replaceAll(
      RegExp(r'/api/?$'),
      '',
    );

    return '$baseUrl/$image';
  }
}