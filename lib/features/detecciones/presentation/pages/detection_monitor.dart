import 'dart:async';
import 'package:deteccion_persona_f/core/common/constants/app_constants.dart';
import 'package:deteccion_persona_f/features/detecciones/data/captura_persona_model.dart';
import 'package:deteccion_persona_f/features/detecciones/data/captura_persona_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toastification/toastification.dart';

/// Widget que monitorea en segundo plano nuevas detecciones en el backend.
/// Al colocarlo en la raíz de la navegación, permite que los Toasts aparezcan
/// sin importar en qué pantalla se encuentre el usuario.
class DetectionMonitor extends StatefulWidget {
  final Widget child;

  const DetectionMonitor({super.key, required this.child});

  @override
  State<DetectionMonitor> createState() => _DetectionMonitorState();
}

class _DetectionMonitorState extends State<DetectionMonitor> {
  final CapturaPersonaService _service = CapturaPersonaService();
  Timer? _pollingTimer;
  String? _lastDetectionId;
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    // Consultar el backend cada 10 segundos para buscar nuevas capturas
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _checkNewDetections(),
    );
    // Verificación inicial inmediata
    _checkNewDetections();
  }

  Future<void> _checkNewDetections() async {
    try {
      final capturas = await _service.getAllCapturas();
      if (!mounted || capturas.isEmpty) return;

      final sorted = [...capturas]
        ..sort((a, b) {
          final dateA = a.fecha;
          final dateB = b.fecha;
          return dateB.compareTo(dateA); // más reciente primero
        });

      final latest = sorted.first;

      if (_isFirstLoad) {
        _lastDetectionId = latest.id;
        _isFirstLoad = false;
        return;
      }

      if (latest.id != _lastDetectionId) {
        _lastDetectionId = latest.id;
        _showToast(
          '🔍 Nueva detección: ${latest.nombrePersona}',
          ToastificationType.info,
        );
      }
    } catch (e) {
      debugPrint('Error en el monitor de detecciones: $e');
    }
  }

  void _showToast(String message, ToastificationType type) {
    if (!mounted) return;

    toastification.show(
      type: type,
      style: ToastificationStyle.flatColored,
      title: Text(message, textDirection: TextDirection.ltr),
      alignment: Alignment.topRight,
      autoCloseDuration: const Duration(seconds: 5),
      showProgressBar: true,
      direction: TextDirection.ltr,
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
