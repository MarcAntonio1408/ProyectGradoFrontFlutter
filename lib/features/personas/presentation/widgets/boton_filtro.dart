import 'package:deteccion_persona_f/core/common/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BotonFiltro extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const BotonFiltro({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
            border: isSelected ? null : Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            text,
            style: GoogleFonts.outfit(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}