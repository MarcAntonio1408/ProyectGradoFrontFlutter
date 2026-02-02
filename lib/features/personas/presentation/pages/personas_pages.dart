import 'package:deteccion_persona_f/core/common/constants/app_constants.dart';
import 'package:deteccion_persona_f/features/personas/data/getAll.dart';
import 'package:deteccion_persona_f/features/personas/data/personas_service.dart';
import 'package:deteccion_persona_f/features/personas/presentation/pages/person_detail_screen.dart';
import 'package:deteccion_persona_f/features/personas/presentation/pages/register_person_screen.dart';
import 'package:deteccion_persona_f/features/personas/presentation/widgets/boton_filtro.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PersonasPages extends StatefulWidget {
  const PersonasPages({super.key});

  @override
  State<PersonasPages> createState() => _PersonasPagesState();
}

class _PersonasPagesState extends State<PersonasPages> {
  String _selectedFilter = 'Todos';
  String _searchQuery = '';
  final PersonasService _personasService = PersonasService();
  late Future<List<DatosPersonas>> _personasFuture;

  @override
  void initState() {
    super.initState();
    _loadPersonas();
  }

  void _loadPersonas() {
    setState(() {
      final user = AppConstants.currentUser;
      final isAdmin = user?.roles.contains('admin') ?? false;
      if (isAdmin) {
        _personasFuture = _personasService.getAllPersonas();
      } else {
        _personasFuture = _personasService.findByUser(user?.id ?? '');
      }
    });
  }

  List<DatosPersonas> _filterList(List<DatosPersonas> list) {
    List<DatosPersonas> filteredList = list;

    // 1. Filtro por categoría (Tabs)
    if (_selectedFilter == 'Desaparecidos') {
      filteredList = filteredList.where((p) => !p.encontrado).toList();
    } else if (_selectedFilter == 'Encontrados') {
      filteredList = filteredList.where((p) => p.encontrado).toList();
    }

    // 2. Filtro por texto de búsqueda (Nombre)
    if (_searchQuery.isNotEmpty) {
      filteredList = filteredList.where((p) => p.namePersona.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    return filteredList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Gestión de Personas',
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
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                children: [
                  // Barra de búsqueda
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre...',
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
                  // Botones de filtro
                  Row(
                    children: [
                      BotonFiltro(
                        text: 'Todos',
                        isSelected: _selectedFilter == 'Todos',
                        onTap: () => setState(() => _selectedFilter = 'Todos'),
                      ),
                      const SizedBox(width: 8),
                      BotonFiltro(
                        text: 'Desaparecidos',
                        isSelected: _selectedFilter == 'Desaparecidos',
                        onTap: () => setState(() => _selectedFilter = 'Desaparecidos'),
                      ),
                      const SizedBox(width: 8),
                      BotonFiltro(
                        text: 'Encontrados',
                        isSelected: _selectedFilter == 'Encontrados',
                        onTap: () => setState(() => _selectedFilter = 'Encontrados'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<DatosPersonas>>(
                future: _personasFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    final user = AppConstants.currentUser;
                    final isAdmin = user?.roles.contains('admin') ?? false;
                    return Center(child: Text(isAdmin 
                        ? 'No hay personas registradas' 
                        : 'No tienes ninguna persona registrada'));
                  }

                  final filteredList = _filterList(snapshot.data!);

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
                    itemCount: filteredList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _PersonCard(persona: filteredList[index]);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        )
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RegisterPersonScreen()),
          ).then((_) => _loadPersonas()); // Recargar lista al volver
        },
        backgroundColor: AppConstants.primaryColor,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: Text('Registrar Personas', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _PersonCard extends StatelessWidget {
  final DatosPersonas persona;
  const _PersonCard({required this.persona});

  @override
  Widget build(BuildContext context) {
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
          // Columna Izquierda: Imagen
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppConstants.primaryColor,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: Container(
                color: Colors.grey[200],
                child: persona.foto.isNotEmpty
                    ? Image.network(
                        // Ajusta la URL base si la foto es solo el nombre del archivo
                        persona.foto.startsWith('http') 
                            ? persona.foto 
                            : '${AppConstants.apiBaseUrl}/files/${persona.foto}',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.grey),
                      )
                    : const Icon(Icons.person, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Columna Centro: Información
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  persona.namePersona,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Alias: "${persona.alias}" • Nota: ${persona.notas}\nTel: ${persona.telefono}',
                  style: GoogleFonts.outfit(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  persona.encontrado ? 'Encontrado' : 'Desaparecida',
                  style: GoogleFonts.outfit(
                    color: persona.encontrado ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Columna Derecha: Botón
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PersonDetailScreen(
                    name: persona.namePersona,
                    alias: persona.alias,
                    notes: persona.notas,
                    requestedBy: persona.personaSolicitada,
                    phoneNumber: persona.telefono,
                    isFound: persona.encontrado,
                    photo: persona.foto,
                  ),
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
              child: const Icon(
                Icons.chevron_right,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}