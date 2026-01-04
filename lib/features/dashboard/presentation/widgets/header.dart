import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:deteccion_persona_f/features/profile/presentation/pages/perfil_pages.dart';

class Header extends StatelessWidget {
  final VoidCallback onCartTap;
  const Header({super.key, required this.onCartTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PerfilPages()),
            );
          },
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFFE0E0E0),
            backgroundImage: AssetImage('assets/images/profile.png'),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello',
              style: GoogleFonts.outfit(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Guest User',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Spacer(),
        GestureDetector(
          onTap: onCartTap,
          child: Badge.count(
            count: 2,
            child: Icon(Icons.shopping_cart_outlined, size: 32),
          ),
        ),
      ],
    );
  }
}
