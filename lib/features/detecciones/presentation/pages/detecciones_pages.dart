import 'package:deteccion_persona_f/core/common/constants/app_constants.dart';
import 'package:deteccion_persona_f/features/detecciones/data/captura_persona_model.dart';
import 'package:deteccion_persona_f/features/detecciones/data/captura_persona_service.dart';
import 'package:deteccion_persona_f/features/detecciones/presentation/pages/deteccion_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DeteccionesPages extends StatefulWidget {
  const DeteccionesPages({super.key});

  @override
  State<DeteccionesPages> createState() => _DeteccionesPagesState();
}

class _DeteccionesPagesState extends State<DeteccionesPages> {
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final CapturaPersonaService _capturaService = CapturaPersonaService();
  late Future<List<CapturaPersonaModel>> _capturasFuture;

  @override
  void initState() {
    super.initState();
    _loadCapturas();
  }

  void _loadCapturas() {
    setState(() {
      _capturasFuture = _capturaService.getAllCapturas();
    });
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  List<CapturaPersonaModel> _filterList(List<CapturaPersonaModel> list) {
    DateTime? start;
    DateTime? end;

    if (_startDateController.text.isNotEmpty) {
      start = DateTime.tryParse(_startDateController.text);
    }
    if (_endDateController.text.isNotEmpty) {
      end = DateTime.tryParse(_endDateController.text);
      if (end != null) {
        // Ajustar al final del día para incluir registros de ese día completo
        end = DateTime(end.year, end.month, end.day, 23, 59, 59);
      }
    }

    if (start == null && end == null) return list;

    return list.where((item) {
      final date = item.fecha;
      final isAfterStart = start == null || date.isAfter(start) || date.isAtSameMomentAs(start);
      final isBeforeEnd = end == null || date.isBefore(end) || date.isAtSameMomentAs(end);
      return isAfterStart && isBeforeEnd;
    }).toList();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppConstants.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Detecciones',
          style: GoogleFonts.outfit(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notification_add_outlined,
              color: Colors.black,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    context,
                    'Fecha Inicio',
                    _startDateController,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDateField(
                    context,
                    'Fecha Final',
                    _endDateController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.defaultBorderRadius,
                    ),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Filtrar Resultados',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: FutureBuilder<List<CapturaPersonaModel>>(
                future: _capturasFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No hay detecciones registradas'));
                  }

                  final list = snapshot.data!;
                  final filteredList = _filterList(list);

                  if (filteredList.isEmpty) {
                    return const Center(child: Text('No se encontraron resultados en este rango'));
                  }

                  return ListView.separated(
                    itemCount: filteredList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _CapturaCard(captura: filteredList[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(
    BuildContext context,
    String label,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _selectDate(context, controller),
          child: AbsorbPointer(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'YYYY-MM-DD',
                hintStyle: GoogleFonts.outfit(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.defaultBorderRadius,
                  ),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                suffixIcon: const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CapturaCard extends StatelessWidget {
  final CapturaPersonaModel captura;
  const _CapturaCard({required this.captura});

  @override
  Widget build(BuildContext context) {
    final statusText = captura.encontrado ? 'Coincidencia confirmada' : 'Coincidencia en espera';
    final statusColor = captura.encontrado ? Colors.green : Colors.orange;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Imagen a la izquierda
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[200],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: captura.foto.isNotEmpty
                  ? Image.network(
                      captura.foto.startsWith('http')
                          ? captura.foto
                          : '${AppConstants.apiBaseUrl}/files/${captura.foto}',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                    )
                  : const Icon(Icons.image, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 16),
          // Información a la derecha
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  captura.nombrePersona,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusText,
                  style: GoogleFonts.outfit(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Columna Izquierda: faceCount
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rostros', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
                        Text('${captura.faceCount}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(width: 24),
                    // Columna Derecha: resultJson (Ropa)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ropa', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
                          Text(
                            captura.resultJson,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Fecha: ${captura.fecha.toLocal().toString().split(' ')[0]}', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[600])),
                if (captura.encontrado)
                  Text('Encontrado: ${captura.updatedAt.toLocal().toString().split(' ')[0]}', style: GoogleFonts.outfit(fontSize: 12, color: Colors.green[700])),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DeteccionDetailScreen(captura: captura),
                ),
              );
            },
            borderRadius: BorderRadius.circular(50),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Icon(Icons.chevron_right, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}