import 'package:deteccion_persona_f/core/common/constants/app_constants.dart';
import 'package:deteccion_persona_f/features/dispositivos/data/dispositivo_model.dart';
import 'package:deteccion_persona_f/features/dispositivos/data/dispositivo_service.dart';
import 'package:deteccion_persona_f/features/dispositivos/presentation/pages/register_dispositivo_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DispositivoPage extends StatefulWidget {
  const DispositivoPage({super.key});

  @override
  State<DispositivoPage> createState() => _DispositivoPageState();
}

class _DispositivoPageState extends State<DispositivoPage> {
  final DispositivoService _dispositivoService = DispositivoService();
  late Future<List<DispositivoModel>> _dispositivosFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDispositivos();
  }

  void _loadDispositivos() {
    setState(() {
      _dispositivosFuture = _dispositivoService.getAllDispositivos();
    });
  }

  Future<void> _deleteDispositivo(String id) async {
    try {
      await _dispositivoService.deleteDispositivo(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dispositivo eliminado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        _loadDispositivos();
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
    }
  }

  List<DispositivoModel> _filterList(List<DispositivoModel> list) {
    if (_searchQuery.isEmpty) return list;
    return list
        .where((d) => d.nombreDispositivo.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Dispositivos',
          style: GoogleFonts.outfit(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterDispositivoScreen()),
              ).then((_) => _loadDispositivos());
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          children: [
            // Barra de búsqueda
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar dispositivo...',
                hintStyle: GoogleFonts.outfit(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<DispositivoModel>>(
                future: _dispositivosFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No hay dispositivos registrados'));
                  }

                  final filteredList = _filterList(snapshot.data!);

                  return ListView.separated(
                    itemCount: filteredList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final dispositivo = filteredList[index];
                      return _DispositivoCard(
                        dispositivo: dispositivo,
                        onDelete: () => _deleteDispositivo(dispositivo.id),
                        onEdit: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegisterDispositivoScreen(dispositivo: dispositivo),
                            ),
                          ).then((_) => _loadDispositivos());
                        },
                      );
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
}

class _DispositivoCard extends StatelessWidget {
  final DispositivoModel dispositivo;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _DispositivoCard({
    required this.dispositivo,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = dispositivo.estado ? Colors.green : Colors.red;
    final statusText = dispositivo.estado ? 'Conectado' : 'Desconectado';

    return Container(
      padding: const EdgeInsets.all(16),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dispositivo.nombreDispositivo,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                Text(
                  dispositivo.tipoDispositivo,
                  style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusText,
                      style: GoogleFonts.outfit(color: statusColor, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Características: ${dispositivo.caracteristicas}', style: GoogleFonts.outfit(fontSize: 13)),
                Text('Token: ${dispositivo.token}', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: onEdit,
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Eliminar Dispositivo'),
                      content: const Text('¿Estás seguro de que deseas eliminar este dispositivo?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            onDelete();
                          },
                          child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}