import 'dart:io';
import 'package:deteccion_persona_f/core/common/constants/app_constants.dart';
import 'package:deteccion_persona_f/features/auth/presentation/widgets/auth_widgets.dart';
import 'package:deteccion_persona_f/features/personas/data/personas_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class RegisterPersonScreen extends StatefulWidget {
  const RegisterPersonScreen({super.key});

  @override
  State<RegisterPersonScreen> createState() => _RegisterPersonScreenState();
}

class _RegisterPersonScreenState extends State<RegisterPersonScreen> {
  final _formKey = GlobalKey<FormState>();
  final PersonasService _personasService = PersonasService();
  
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  // Controladores
  final _nameController = TextEditingController();
  final _aliasController = TextEditingController();
  final _notesController = TextEditingController();
  final _requestedByController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dateFoundController = TextEditingController();
  

  @override
  void dispose() {
    _nameController.dispose();
    _aliasController.dispose();
    _notesController.dispose();
    _requestedByController.dispose();
    _phoneController.dispose();
    _dateFoundController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
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
          'Registrar Persona',
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
              // Placeholder para Foto
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey[300]!),
                      image: _selectedImage != null
                          ? DecorationImage(
                              image: FileImage(_selectedImage!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _selectedImage == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, size: 40, color: Colors.grey[400]),
                              const SizedBox(height: 4),
                              Text(
                                'Añadir Foto',
                                style: GoogleFonts.outfit(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              AuthTextField(
                label: 'Nombre de la Persona',
                hint: 'Ingrese el nombre completo',
                controller: _nameController,
                validator: (value) => (value == null || value.isEmpty) ? 'El nombre es requerido' : null,
              ),
              const SizedBox(height: 16),

              AuthTextField(
                label: 'Alias',
                hint: 'Ingrese el alias (Opcional)',
                controller: _aliasController,
                validator: (value) => (value != null && value.isNotEmpty && value.length < 3) ? 'Mínimo 3 caracteres' : null,
              ),
              const SizedBox(height: 16),

              AuthTextField(
                label: 'Notas',
                hint: 'Detalles adicionales (Opcional)',
                controller: _notesController,
                validator: (value) => (value != null && value.isNotEmpty && value.length < 3) ? 'Mínimo 3 caracteres' : null,
              ),
              const SizedBox(height: 16),

              AuthTextField(
                label: 'Persona Solicitada',
                hint: '¿Quién solicita la búsqueda?',
                controller: _requestedByController,
              ),
              const SizedBox(height: 16),

              AuthTextField(
                label: 'Teléfono',
                hint: 'Número de contacto',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              const SizedBox(height: 32),
              AuthButton(
                text: 'Registrar Persona',
                isLoading: _isLoading,
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() => _isLoading = true);
                    
                    try {
                      await _personasService.createPersona(
                        name: _nameController.text.trim(),
                        alias: _aliasController.text.trim(),
                        notes: _notesController.text.trim(),
                        requestedBy: _requestedByController.text.trim(),
                        phone: _phoneController.text.trim(),
                        image: _selectedImage,
                      );

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Persona registrada con éxito')),
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
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}