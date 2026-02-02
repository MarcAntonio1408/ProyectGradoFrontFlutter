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

  late final List<Widget> _screens;
  late final List<_BottomNavItem> _navItems;

  @override
  void initState() {
    super.initState();
    _setupNavigationForRole();
  }

  void _setupNavigationForRole() {
    final bool isAdmin = AppConstants.currentUser?.roles.contains('admin') ?? false;

    final dashboard = _BottomNavItem(
      screen: const DashboardPage(),
      icon: FluentSystemIcons.ic_fluent_data_histogram_regular,
      activeIcon: FluentSystemIcons.ic_fluent_data_histogram_filled,
      label: 'Dashboard',
    );

    final personas = _BottomNavItem(
      screen: const PersonasPages(),
      icon: FluentSystemIcons.ic_fluent_people_search_regular,
      activeIcon: FluentSystemIcons.ic_fluent_people_search_filled,
      label: 'Personas',
    );

    final detecciones = _BottomNavItem(
      screen: const DeteccionesPages(),
      icon: FluentSystemIcons.ic_fluent_person_block_regular,
      activeIcon: FluentSystemIcons.ic_fluent_person_block_filled,
      label: 'Detecciones',
    );

    final dispositivo = _BottomNavItem(
      screen: const DispositivoPage(),
      icon: FluentSystemIcons.ic_fluent_phone_laptop_regular,
      activeIcon: FluentSystemIcons.ic_fluent_phone_laptop_filled,
      label: 'Dispositivos',
    );

    final perfil = _BottomNavItem(
      screen: const PerfilPages(),
      icon: FluentSystemIcons.ic_fluent_person_regular,
      activeIcon: FluentSystemIcons.ic_fluent_person_filled,
      label: 'Perfil',
    );

    _navItems = isAdmin
        ? [dashboard, personas, detecciones, dispositivo, perfil]
        : [personas, perfil];

    _screens = _navItems.map((item) => item.screen).toList();
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
        body: _screens[_currentIndex],
        bottomNavigationBar: Container(
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 18),
          padding: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 10),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: List.generate(_navItems.length, (index) {
                  final item = _navItems[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: _buildnavItem(index, item.icon, item.activeIcon, item.label),
                  );
                }),
              ),
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppConstants.primaryColor.withOpacity(0.1) : Colors.transparent,
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

class _BottomNavItem {
  final Widget screen;
  final IconData icon;
  final IconData activeIcon;
  final String label;

  _BottomNavItem({
    required this.screen,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
