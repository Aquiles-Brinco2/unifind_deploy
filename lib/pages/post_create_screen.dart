import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:objetos_perdidos/services/posts_create.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_io/io.dart'; // Para detectar la plataforma
// Necesario para usar kIsWeb

class CreatePublicationScreen extends StatefulWidget {
  const CreatePublicationScreen({super.key});

  @override
  State<CreatePublicationScreen> createState() =>
      _CreatePublicationScreenState();
}

class _CreatePublicationScreenState extends State<CreatePublicationScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController careerController = TextEditingController();

  String? base64Image;
  String? selectedCategory;
  String? selectedLocation;
  String? selectedStatus = 'Perdido'; // Valor por defecto
  bool isLoading = false;

  // Listas para los dropdowns
  final List<String> categories = [
    'Ropa',
    'Electrónico',
    'Material',
    'Documentos',
    'Otros'
  ];
  final List<String> locations = [
    'Recepción',
    'Aulas PG',
    'Cafetería',
    'Aulas T',
    'Aulas M',
    'Estacionamiento',
    'Entrada',
  ];
  final List<String> statusOptions = [
    'Perdido',
    'Encontrado'
  ]; // Opciones para el estado

  @override
  void initState() {
    super.initState();
    _loadUserCareer();
  }

  Future<void> _loadUserCareer() async {
    final prefs = await SharedPreferences.getInstance();
    final userCareer = prefs.getString('user_carrera');
    if (userCareer != null) {
      careerController.text =
          userCareer; // Prellenar el campo con la carrera guardada
    }
  }

  Future<void> handleCreatePublication() async {
    setState(() {
      isLoading = true;
    });

    final name = nameController.text.trim();
    final description = descriptionController.text.trim();
    final career = careerController.text.trim();
    final status = selectedStatus!; // Obtener el valor del estado seleccionado

    print('Nombre: $name');
    print('Descripción: $description');
    print('Carrera: $career');
    print('Estado: $status');
    print('Categoría: $selectedCategory');
    print('Ubicación: $selectedLocation');
    print('Imagen base64: $base64Image');

    if (name.isEmpty ||
        description.isEmpty ||
        career.isEmpty ||
        status.isEmpty ||
        selectedCategory == null ||
        selectedLocation == null ||
        base64Image == null) {
      setState(() {
        isLoading = false;
      });
      _showError('Por favor, completa todos los campos');
      return;
    }
    final result = await createPublication(
      name,
      description,
      base64Image!,
      selectedCategory!,
      selectedLocation!,
      career,
      status,
    );

    if (result['success']) {
      _showSuccess(result['message']);
    } else {
      _showError(result['message']);
    }

    setState(() {
      isLoading = false;
    });
  }

  void _showSuccess(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Éxito'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Método para seleccionar imágenes
  Future<void> pickImage() async {
    if (kIsWeb) {
      // Si estamos en la web, usamos file_picker
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(type: FileType.image);

      if (result != null) {
        final file = result.files.single;
        final bytes = file.bytes;

        if (bytes != null) {
          setState(() {
            base64Image = base64Encode(Uint8List.fromList(bytes));
          });
        }
      }
    } else if (Platform.isIOS || Platform.isAndroid) {
      // Si estamos en móvil, usamos image_picker
      final picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();

        setState(() {
          base64Image = base64Encode(Uint8List.fromList(bytes));
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determinar si la aplicación se está ejecutando en un dispositivo web
    bool isWeb = kIsWeb;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Publicación'),
      ),
      body: SafeArea(
        child: Padding(
          padding: isWeb
              ? const EdgeInsets.symmetric(
                  horizontal: 600.0) // Más márgenes para web
              : const EdgeInsets.all(20.0), // Márgenes por defecto para móvil
          child: ListView(
            children: [
              const Text(
                'Crea una nueva publicación',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // Ajustar el ancho de los campos de texto según el dispositivo
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del objeto perdido',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: categories
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => selectedCategory = value),
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedLocation,
                items: locations
                    .map((location) => DropdownMenuItem(
                          value: location,
                          child: Text(location),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => selectedLocation = value),
                decoration: const InputDecoration(
                  labelText: 'Ubicación',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: careerController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Carrera',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Campo para el estado
              DropdownButtonFormField<String>(
                value: selectedStatus,
                items: statusOptions
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(
                              status[0].toUpperCase() + status.substring(1)),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => selectedStatus = value),
                decoration: const InputDecoration(
                  labelText: 'Estado',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: pickImage,
                child: const Text('Seleccionar Imagen'),
              ),
              const SizedBox(height: 16),
              if (base64Image != null)
                const Text('Imagen seleccionada',
                    style: TextStyle(color: Colors.green)),
              const SizedBox(height: 24),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: handleCreatePublication,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Crear Publicación'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
