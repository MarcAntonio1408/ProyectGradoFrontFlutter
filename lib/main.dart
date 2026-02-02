import 'package:deteccion_persona_f/features/auth/data/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:deteccion_persona_f/splash_screen.dart';

void main() async {
  // Asegura que los bindings de Flutter estén inicializados antes de cualquier operación asíncrona.
  WidgetsFlutterBinding.ensureInitialized();

  // Realiza la comprobación de conexión con el backend y muestra los logs.
  await AuthService().checkBackendConnection();

  runApp(const DeteccionPersona());
}

class DeteccionPersona extends StatelessWidget {
  const DeteccionPersona({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Detector de Personas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: SplashScreen(),
    );
  }
}