import 'package:deteccion_persona_f/core/common/constants/app_constants.dart';
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
          IconButton(
            icon: const Icon(
              Icons.person_add_outlined,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterPersonScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
              const SizedBox(height: 24),
              const _PersonCard(),
            ],
          ),
        )
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RegisterPersonScreen()),
          );
        },
        backgroundColor: AppConstants.primaryColor,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: Text('Registrar Personas', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _PersonCard extends StatelessWidget {
  const _PersonCard();

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
                child: const Icon(Icons.person, color: Colors.grey),
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
                  'Juan Pérez',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Alias: "El Rápido" • Nota: Visto en el parque',
                  style: GoogleFonts.outfit(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  'Desaparecido',
                  style: GoogleFonts.outfit(
                    color: Colors.red,
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
                  builder: (context) => const PersonDetailScreen(
                    name: 'Juan Pérez',
                    alias: 'El Rápido',
                    notes: 'Visto en el parque',
                    requestedBy: 'Familia Pérez',
                    phoneNumber: '71234567',
                    isFound: false,
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
