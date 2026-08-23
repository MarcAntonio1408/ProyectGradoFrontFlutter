import 'package:deteccion_persona_f/features/auth/data/auth_service.dart';
import 'package:deteccion_persona_f/features/detecciones/presentation/pages/detection_monitor.dart';
import 'package:deteccion_persona_f/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await AuthService().checkBackendConnection();
  } catch (e) {
    debugPrint('No fue posible conectar con el backend: $e');
  }

  runApp(const GuardiIAApp());
}

class GuardiIAApp extends StatelessWidget {
  const GuardiIAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'GuardiIA',

        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF15656B),
          scaffoldBackgroundColor: const Color(0xFFF6F7F8),
          fontFamily: 'Outfit',
        ),

        home: const SplashScreen(),

        builder: (context, child) {
          return DetectionMonitor(child: child ?? const SizedBox.shrink());
        },
      ),
    );
  }
}
