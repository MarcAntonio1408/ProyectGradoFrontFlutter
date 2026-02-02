import 'package:deteccion_persona_f/core/common/constants/app_constants.dart';
import 'package:deteccion_persona_f/features/detecciones/data/captura_persona_model.dart';
import 'package:deteccion_persona_f/features/detecciones/data/captura_persona_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DeteccionDetailScreen extends StatefulWidget {
  final CapturaPersonaModel captura;

  const DeteccionDetailScreen({super.key, required this.captura});

  @override
  State<DeteccionDetailScreen> createState() => _DeteccionDetailScreenState();
}

class _DeteccionDetailScreenState extends State<DeteccionDetailScreen> {
  late CapturaPersonaModel _captura;
  final CapturaPersonaService _service = CapturaPersonaService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _captura = widget.captura;
  }

  Future<void> _confirmarCoincidencia() async {
    setState(() => _isLoading = true);
    try {
      await _service.actualizarEstadoEncontrado(_captura.id);

      setState(() {
        // Actualizamos el modelo localmente para reflejar el cambio en la UI
        _captura = CapturaPersonaModel(
          id: _captura.id,
          foto: _captura.foto,
          faceCount: _captura.faceCount,
          resultJson: _captura.resultJson,
          clothingCount: _captura.clothingCount,
          encontrado: true,
          fecha: _captura.fecha,
          createdAt: _captura.createdAt,
          updatedAt: DateTime.now(),
          nombrePersona: _captura.nombrePersona,
        );
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Coincidencia confirmada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
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

  @override
  Widget build(BuildContext context) {
    final statusColor = _captura.encontrado ? Colors.green : Colors.red;
    final statusText = _captura.encontrado ? 'Coincidencia Confirmada' : 'Coincidencia en Espera';

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
          'Detalles de Detección',
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
            // Foto de la captura
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: statusColor,
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: _captura.foto.isNotEmpty
                    ? Image.network(
                        _captura.foto.startsWith('http')
                            ? _captura.foto
                            : '${AppConstants.apiBaseUrl}/files/${_captura.foto}',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(Icons.image_not_supported, size: 80, color: Colors.grey[400]),
                      )
                    : Icon(
                        Icons.image_not_supported,
                        size: 80,
                        color: Colors.grey[400],
                      ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Nombre y Estado
            Text(
              _captura.nombrePersona,
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
                  _buildInfoRow(Icons.tag_faces, 'Cantidad de Rostros', _captura.faceCount.toString()),
                  const Divider(height: 32),
                  _buildInfoRow(Icons.checkroom, 'Ropa Detectada', _captura.resultJson),
                  const Divider(height: 32),
                  _buildInfoRow(Icons.numbers, 'Cantidad de Ropa', _captura.clothingCount.toString()),
                  const Divider(height: 32),
                  _buildInfoRow(Icons.calendar_today, 'Fecha de Detección', _captura.fecha.toLocal().toString().split(' ')[0]),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Botón Confirmar Coincidencia
            if (!_captura.encontrado)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _confirmarCoincidencia,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Confirmar Coincidencia',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            const SizedBox(height: 24),
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
              Text(label, style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(value, style: GoogleFonts.outfit(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}