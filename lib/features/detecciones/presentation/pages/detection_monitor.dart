import 'dart:async';
import 'dart:convert';

import 'package:deteccion_persona_f/core/common/constants/app_constants.dart';
import 'package:deteccion_persona_f/features/detecciones/data/captura_persona_service.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Monitorea eventos del sistema y nuevas detecciones.
///
/// Debe colocarse en la raíz de la aplicación para que las notificaciones
/// puedan visualizarse desde cualquier pantalla.
class DetectionMonitor extends StatefulWidget {
  final Widget child;

  const DetectionMonitor({super.key, required this.child});

  @override
  State<DetectionMonitor> createState() => _DetectionMonitorState();
}

class _DetectionMonitorState extends State<DetectionMonitor> {
  static const Duration _pollingInterval = Duration(seconds: 10);
  static const Duration _detectingDelay = Duration(seconds: 1);
  static const Duration _reconnectionDelay = Duration(seconds: 5);

  final CapturaPersonaService _service = CapturaPersonaService();

  Timer? _pollingTimer;
  Timer? _detectingTimer;
  Timer? _reconnectionTimer;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _webSocketSubscription;

  ToastificationItem? _detectingToast;

  String? _lastDetectionId;
  bool _isFirstLoad = true;
  bool _isCheckingDetections = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();

    _startPolling();
    _connectWebSocket();

  }

  @override
  void dispose() {
    _isDisposed = true;

    _pollingTimer?.cancel();
    _detectingTimer?.cancel();
    _reconnectionTimer?.cancel();

    _webSocketSubscription?.cancel();
    _channel?.sink.close();

    _dismissDetectingToast();

    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // WEBSOCKET
  // ---------------------------------------------------------------------------

  Future<void> _connectWebSocket() async {
    if (_isDisposed) return;

    try {
      await _webSocketSubscription?.cancel();
      await _channel?.sink.close();

      final uri = Uri(
        scheme: 'ws',
        host: AppConstants.serverIp,
        port: 5001,
        queryParameters: const {'name': 'flutter'},
      );

      debugPrint('Conectando WebSocket: $uri');

      final channel = WebSocketChannel.connect(uri);
      _channel = channel;

      _webSocketSubscription = channel.stream.listen(
        _handleWebSocketMessage,
        onError: _handleWebSocketError,
        onDone: _handleWebSocketDone,
        cancelOnError: false,
      );
    } catch (error, stackTrace) {
      debugPrint('Error conectando WebSocket: $error');
      debugPrintStack(stackTrace: stackTrace);

      _scheduleWebSocketReconnection();
    }
  }

  void _handleWebSocketMessage(dynamic message) {
    if (_isDisposed) return;

    try {
      final decoded = jsonDecode(message.toString());

      if (decoded is! Map<String, dynamic>) {
        debugPrint('Mensaje WebSocket con formato inválido: $decoded');
        return;
      }

      final event = decoded['event']?.toString();
      final payload = decoded['payload'];

      switch (event) {
        case 'train:complete':
          _handleTrainComplete(payload);
          break;

        case 'worker:ready':
          _handleWorkerReady();
          break;

        default:
          debugPrint('Evento WebSocket no controlado: $event');
      }
    } on FormatException catch (error) {
      debugPrint('Mensaje WebSocket no es JSON válido: $error');
    } catch (error, stackTrace) {
      debugPrint('Error procesando mensaje WebSocket: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  void _handleTrainComplete(dynamic payload) {
    String description = 'El modelo terminó de entrenarse correctamente.';

    if (payload is Map<String, dynamic>) {
      final label = payload['label']?.toString().trim();

      if (label != null && label.isNotEmpty) {
        description = label;
      }
    }

    _dismissDetectingToast();

    _showNotification(
      title: '✅ Entrenamiento completado',
      description: description,
      type: ToastificationType.success,
    );

    // Después del entrenamiento vuelve a mostrar el estado de detección.
    _scheduleDetectingToast();
  }

  void _handleWorkerReady() {
    _dismissDetectingToast();

    _showNotification(
      title: '🟢 Reconocimiento facial activo',
      description: 'El sistema ya está procesando rostros en tiempo real.',
      type: ToastificationType.success,
    );

    // Después de informar que el worker está activo, muestra:
    // "🎯 Detectando rostro".
    _scheduleDetectingToast();
  }

  void _handleWebSocketError(Object error) {
    debugPrint('Error WebSocket: $error');
  }

  void _handleWebSocketDone() {
    if (_isDisposed) return;

    debugPrint('Conexión WebSocket cerrada');
    _scheduleWebSocketReconnection();
  }

  void _scheduleWebSocketReconnection() {
    if (_isDisposed || _reconnectionTimer?.isActive == true) {
      return;
    }

    _reconnectionTimer = Timer(_reconnectionDelay, _connectWebSocket);
  }

  // ---------------------------------------------------------------------------
  // NOTIFICACIÓN PERMANENTE DE DETECCIÓN
  // ---------------------------------------------------------------------------

  void _scheduleDetectingToast({Duration delay = _detectingDelay}) {
    _detectingTimer?.cancel();

    _detectingTimer = Timer(delay, () {
      if (!_isDisposed && mounted) {
        _showDetectingToast();
      }
    });
  }

  void _showDetectingToast() {
    if (!mounted || _isDisposed) return;

    // Evita notificaciones permanentes duplicadas.
    _dismissDetectingToast();

    _detectingToast = toastification.show(
      context: context,
      type: ToastificationType.info,
      style: ToastificationStyle.flatColored,
      alignment: Alignment.topRight,
      autoCloseDuration: null,
      showProgressBar: false,
      closeOnClick: false,
      dragToClose: false,
      title: const Text(
        '🎯 Detectando rostro',
        textDirection: TextDirection.ltr,
      ),
      description: const Text(
        'El sistema está analizando y registrando nuevas detecciones...',
        textDirection: TextDirection.ltr,
      ),
    );
  }

  void _dismissDetectingToast() {
    final detectingToast = _detectingToast;

    if (detectingToast != null) {
      toastification.dismiss(detectingToast);
      _detectingToast = null;
    }
  }

  // ---------------------------------------------------------------------------
  // POLLING DE DETECCIONES
  // ---------------------------------------------------------------------------

  void _startPolling() {
    _checkNewDetections();

    _pollingTimer = Timer.periodic(
      _pollingInterval,
      (_) => _checkNewDetections(),
    );
  }

  Future<void> _checkNewDetections() async {
    // Evita ejecutar varias peticiones simultáneamente.
    if (_isCheckingDetections || _isDisposed) return;

    _isCheckingDetections = true;

    try {
      final capturas = await _service.getAllCapturas();

      if (!mounted || _isDisposed || capturas.isEmpty) {
        return;
      }

      final capturasOrdenadas = [...capturas]
        ..sort((a, b) => b.fecha.compareTo(a.fecha));

      final latest = capturasOrdenadas.first;

      if (_isFirstLoad) {
        _lastDetectionId = latest.id;
        _isFirstLoad = false;
        return;
      }

      if (latest.id == _lastDetectionId) {
        return;
      }

      _lastDetectionId = latest.id;

      _dismissDetectingToast();

      _showNotification(
        title: '🔍 Nueva detección',
        description: latest.nombrePersona,
        type: ToastificationType.info,
      );

      _scheduleDetectingToast();
    } catch (error, stackTrace) {
      debugPrint('Error en el monitor de detecciones: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _isCheckingDetections = false;
    }
  }

  // ---------------------------------------------------------------------------
  // NOTIFICACIONES TEMPORALES
  // ---------------------------------------------------------------------------

  void _showNotification({
    required String title,
    required String description,
    required ToastificationType type,
  }) {
    if (!mounted || _isDisposed) return;

    toastification.show(
      context: context,
      type: type,
      style: ToastificationStyle.flatColored,
      alignment: Alignment.topRight,
      autoCloseDuration: const Duration(seconds: 5),
      showProgressBar: true,
      direction: TextDirection.ltr,
      title: Text(title, textDirection: TextDirection.ltr),
      description: Text(description, textDirection: TextDirection.ltr),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
