import 'package:flutter/material.dart';
import 'package:deteccion_persona_f/splash_screen.dart';

void main() {
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