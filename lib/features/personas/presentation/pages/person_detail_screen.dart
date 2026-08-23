import 'package:deteccion_persona_f/core/common/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:deteccion_persona_f/core/common/utils/image_utils.dart';

class PersonDetailScreen extends StatelessWidget {
  final String name;
  final String alias;
  final String notes;
  final String requestedBy;
  final String phoneNumber;
  final bool isFound;
  final String photo;

  const PersonDetailScreen({
    super.key,
    required this.name,
    required this.alias,
    required this.notes,
    required this.requestedBy,
    required this.phoneNumber,
    required this.isFound,
    required this.photo,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = isFound ? Colors.green : Colors.red;
    final statusText = isFound ? 'Encontrado' : 'Desaparecida';

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
          'Detalles de Persona',
          style: GoogleFonts.outfit(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Foto de la persona
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: isFound ? Colors.green : Colors.red,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipOval(
                child: photo.isNotEmpty
                    ? Image.network(
                        ImageUtils.getImageUrl(photo),
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }

                          return const Center(
                            child: SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) {
                          return Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.grey[400],
                          );
                        },
                      )
                    : Icon(Icons.person, size: 80, color: Colors.grey[400]),
              ),
            ),
            const SizedBox(height: 24),

            // Nombre y Estado
            Text(
              name,
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                statusText,
                style: GoogleFonts.outfit(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Tarjeta de Información
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildInfoRow(Icons.person_outline, 'Alias', alias),
                  const Divider(height: 32),
                  _buildInfoRow(Icons.note_alt_outlined, 'Notas', notes),
                  const Divider(height: 32),
                  _buildInfoRow(
                    Icons.assignment_ind_outlined,
                    'Solicitado por',
                    requestedBy,
                  ),
                  const Divider(height: 32),
                  _buildInfoRow(Icons.phone_outlined, 'Teléfono', phoneNumber),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppConstants.primaryColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.outfit(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.outfit(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
