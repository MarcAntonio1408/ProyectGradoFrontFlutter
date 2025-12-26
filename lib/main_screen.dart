import 'package:deteccion_persona_f/core/common/constants/app_constants.dart';
import 'package:deteccion_persona_f/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:deteccion_persona_f/features/detecciones/presentation/pages/detecciones_pages.dart';
import 'package:deteccion_persona_f/features/dispositivos/presentation/pages/dispositivo_page.dart';
import 'package:deteccion_persona_f/features/personas/presentation/pages/personas_pages.dart';
import 'package:deteccion_persona_f/features/profile/presentation/pages/perfil_pages.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _screens.addAll([
      DashboardPage(
        // onNavigationToTab: _onItemTapped,
      ),
      PersonasPages(),
      DeteccionesPages(),
      DispositivoPage(),
      PerfilPages(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: _screens),
        bottomNavigationBar: Container(
          margin: EdgeInsets.only(left: 16, right: 16, bottom: 18),
          padding: EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.2),
                spreadRadius: 1,
                blurRadius: 10,
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildnavItem(
                  0,
                  FluentSystemIcons.ic_fluent_data_histogram_regular,
                  FluentSystemIcons.ic_fluent_data_histogram_filled,
                  'Dashboard',
                ),
                _buildnavItem(
                  1,
                  FluentSystemIcons.ic_fluent_people_search_regular,
                  FluentSystemIcons.ic_fluent_people_search_filled,
                  'Personas',
                ),
                _buildnavItem(
                  2,
                  FluentSystemIcons.ic_fluent_person_block_filled,
                  FluentSystemIcons.ic_fluent_person_block_filled,
                  'Detecciones',
                ),
                _buildnavItem(
                  3,
                  FluentSystemIcons.ic_fluent_phone_laptop_regular,
                  FluentSystemIcons.ic_fluent_phone_laptop_filled,
                  'Dispositivos',
                ),
                _buildnavItem(
                  4,
                  FluentSystemIcons.ic_fluent_person_regular,
                  FluentSystemIcons.ic_fluent_person_filled,
                  'Perfil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildnavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppConstants.primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: AppConstants.primaryColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: AppConstants.primaryColor,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
