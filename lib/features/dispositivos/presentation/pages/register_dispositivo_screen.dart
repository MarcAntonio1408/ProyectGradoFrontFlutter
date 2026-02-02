import 'package:deteccion_persona_f/core/common/constants/app_constants.dart';
import 'package:deteccion_persona_f/features/auth/presentation/widgets/auth_widgets.dart';
import 'package:deteccion_persona_f/features/dispositivos/data/dispositivo_model.dart';
import 'package:deteccion_persona_f/features/dispositivos/data/dispositivo_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterDispositivoScreen extends StatefulWidget {
  final DispositivoModel? dispositivo;
  const RegisterDispositivoScreen({super.key, this.dispositivo});

  @override
  State<RegisterDispositivoScreen> createState() => _RegisterDispositivoScreenState();
}

class _RegisterDispositivoScreenState extends State<RegisterDispositivoScreen> {
  final _formKey = GlobalKey<FormState>();
  final DispositivoService _dispositivoService = DispositivoService();
  bool _isLoading = false;

  // Controladores
  final _nombreController = TextEditingController();
  final _tipoController = TextEditingController();
  final _caracteristicasController = TextEditingController();
  final _tokenController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.dispositivo != null) {
      _nombreController.text = widget.dispositivo!.nombreDispositivo;
      _tipoController.text = widget.dispositivo!.tipoDispositivo;
      _caracteristicasController.text = widget.dispositivo!.caracteristicas;
      _tokenController.text = widget.dispositivo!.token;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _tipoController.dispose();
    _caracteristicasController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.dispositivo == null ? 'Agregar Dispositivo' : 'Editar Dispositivo',
          style: GoogleFonts.outfit(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AuthTextField(
                label: 'Nombre del Dispositivo',
                hint: 'Ej. Cámara Entrada Principal',
                controller: _nombreController,
                validator: (value) => (value == null || value.isEmpty) ? 'El nombre es requerido' : (value.length < 1 ? 'Mínimo 1 caracter' : null),
              ),
              const SizedBox(height: 16),

              AuthTextField(
                label: 'Tipo de Dispositivo',
                hint: 'Ej. Jetson Nano (Opcional)',
                controller: _tipoController,
                validator: (value) => (value != null && value.isNotEmpty && value.length < 3) ? 'Mínimo 3 caracteres' : null,
              ),
              const SizedBox(height: 16),

              AuthTextField(
                label: 'Características',
                hint: 'Ej. 4GB RAM, Lente 180° (Opcional)',
                controller: _caracteristicasController,
                validator: (value) => (value != null && value.isNotEmpty && value.length < 3) ? 'Mínimo 3 caracteres' : null,
              ),
              const SizedBox(height: 16),

              AuthTextField(
                label: 'Token',
                hint: 'Token de seguridad (Opcional)',
                controller: _tokenController,
                validator: (value) => (value != null && value.isNotEmpty && value.length < 3) ? 'Mínimo 3 caracteres' : null,
              ),
              const SizedBox(height: 16),

              const SizedBox(height: 32),

              AuthButton(
                text: widget.dispositivo == null ? 'Guardar Dispositivo' : 'Actualizar Dispositivo',
                isLoading: _isLoading,
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() => _isLoading = true);
                    
                    try {
                      if (widget.dispositivo == null) {
                        await _dispositivoService.createDispositivo(
                          nombreDispositivo: _nombreController.text.trim(),
                          tipoDispositivo: _tipoController.text.trim(),
                          caracteristicas: _caracteristicasController.text.trim(),
                          token: _tokenController.text.trim(),
                        );
                      } else {
                        await _dispositivoService.updateDispositivo(
                          widget.dispositivo!.id,
                          nombreDispositivo: _nombreController.text.trim(),
                          tipoDispositivo: _tipoController.text.trim(),
                          caracteristicas: _caracteristicasController.text.trim(),
                          token: _tokenController.text.trim(),
                        );
                      }

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(widget.dispositivo == null ? 'Dispositivo agregado con éxito' : 'Dispositivo actualizado con éxito')),
                        );
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${e.toString().replaceAll("Exception: ", "")}')),
                        );
                      }
                    } finally {
                      if (mounted) setState(() => _isLoading = false);
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}