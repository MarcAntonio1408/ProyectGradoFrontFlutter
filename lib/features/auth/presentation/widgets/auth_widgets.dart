import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:deteccion_persona_f/core/common/constants/app_constants.dart';

/// Un campo de texto personalizado para formularios de autenticación.
/// Incluye una etiqueta, un campo de entrada y lógica para mostrar/ocultar contraseñas.
class AuthTextField extends StatefulWidget {
  final String label;
  final String hint;
  final bool isPassword;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool enabled;

  const AuthTextField({
    super.key,
    required this.label,
    required this.hint,
    this.isPassword = false,
    required this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  // Estado para controlar si el texto debe estar ofuscado (para contraseñas).
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    // Inicializa el estado de ofuscación basado en si el campo es de tipo contraseña.
    _obscureText = widget.isPassword;
  }

  /// Cambia la visibilidad del texto en el campo de contraseña.
  void _toggleVisibilty() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Variable local para simplificar el acceso a la propiedad `isPassword`.
    final isPasswordField = widget.isPassword;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Etiqueta del campo de texto.
        Text(
          widget.label,
          style: GoogleFonts.outfit(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        // El campo de texto en sí.
        TextFormField(
          controller: widget.controller,
          obscureText: isPasswordField ? _obscureText : false,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          enabled: widget.enabled,
          style: AppConstants.bodyStyle,
          // Decoración y estilos del campo de texto.
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: GoogleFonts.outfit(color: Colors.grey[400]),
            filled: true,
            fillColor: widget.enabled ? Colors.grey[100] : Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppConstants.defaultBorderRadius,
              ),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            // Ícono para mostrar/ocultar la contraseña si `isPassword` es verdadero.
            suffixIcon: isPasswordField
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: _toggleVisibilty,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

/// Un botón de acción principal para la autenticación.
/// Muestra un indicador de carga cuando `isLoading` es verdadero.
class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const AuthButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        // Deshabilita el botón si está en estado de carga.
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(
              AppConstants.defaultBorderRadius,
            ),
          ),
          elevation: 0,
        ),
        // Muestra un CircularProgressIndicator o el texto del botón.
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

/// Un botón secundario con borde, reutilizable en la aplicación.
/// También gestiona un estado de carga.
class ReusabledOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color? borderColor;
  final Color? textColor;
  final double borderRadius;

  const ReusabledOutlinedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.borderColor,
    this.textColor,
    this.borderRadius = AppConstants.defaultBorderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Deshabilita el gesto si está en estado de carga.
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor ?? Colors.grey[300]!),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        alignment: Alignment.center,
        // Muestra un indicador de carga o el texto del botón.
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                ),
              )
            : Text(
                text,
                style: GoogleFonts.outfit(
                  color: textColor ?? AppConstants.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }
}

/// Un widget divisor que muestra una línea horizontal con texto en el centro.
class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Línea a la izquierda del texto.
        Expanded(child: Divider(color: Colors.grey[200])),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Or continue With',
            style: GoogleFonts.outfit(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        // Línea a la derecha del texto.
        Expanded(child: Divider(color: Colors.grey[200])),
      ],
    );
  }
}
