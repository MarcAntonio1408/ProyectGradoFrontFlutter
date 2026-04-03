import 'package:deteccion_persona_f/features/auth/data/auth_service.dart';
import 'package:deteccion_persona_f/features/detecciones/presentation/pages/detection_monitor.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'package:deteccion_persona_f/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService().checkBackendConnection();
  runApp(const DeteccionPersona());
}

class DeteccionPersona extends StatelessWidget {
  const DeteccionPersona({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Detector de Personas',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: SplashScreen(),
        builder: (context, child) {
          return DetectionMonitor(child: child ?? const SizedBox.shrink());
        },
      ),
    );
  }
}
