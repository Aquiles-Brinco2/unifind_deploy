import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:objetos_perdidos/pages/my_post_screen.dart';
import 'package:objetos_perdidos/services/posts_update.dart';
import 'package:objetos_perdidos/services/posts_delete.dart';
import 'package:objetos_perdidos/services/main_class.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // Necesario para usar kIsWeb

class EditPostScreen extends StatefulWidget {
  final Post post;

  const EditPostScreen({super.key, required this.post});

  @override
  _EditPostScreenState createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _careerController = TextEditingController();

  String? base64Image;
  String? selectedCategory;
  String? selectedLocation;
  bool isLoading = false;
  bool isAdmin = false; // Para verificar si el usuario es admin
  bool? found; // Ahora se utiliza 'found' en lugar de 'isStored'

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

  @override
  void initState() {
    super.initState();
    _initializeFields();
    _checkIfAdmin(); // Verificamos si el usuario es admin
  }

  void _initializeFields() {
    _nameController.text = widget.post.lostItem.name;
    _descriptionController.text = widget.post.lostItem.description;
    _careerController.text = widget.post.lostItem.career;
    selectedCategory = widget.post.lostItem.category;
    selectedLocation = widget.post.lostItem.location;
    found =
        widget.post.lostItem.found; // Asignamos el valor de 'found' al campo
  }

  // Verificar si el usuario es admin desde SharedPreferences
  Future<void> _checkIfAdmin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? role = prefs.getString(
        'user_type'); // Suponiendo que el rol está guardado bajo 'role'
    setState(() {
      isAdmin = role == 'admin';
    });
  }

  Future<void> _pickImage() async {
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
  }

  Future<void> _updateLostItem() async {
    setState(() {
      isLoading = true;
    });

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final career = _careerController.text.trim();

    // Usamos los valores actuales si los campos están vacíos
    final updatedName = name.isEmpty ? widget.post.lostItem.name : name;
    final updatedDescription =
        description.isEmpty ? widget.post.lostItem.description : description;
    final updatedCareer = career.isEmpty ? widget.post.lostItem.career : career;
    final updatedCategory = selectedCategory ?? widget.post.lostItem.category;
    final updatedLocation = selectedLocation ?? widget.post.lostItem.location;
    final updatedFound = found ??
        widget.post.lostItem.found; // Usar el valor de found actualizado
    final updatedStatus = updatedFound
        ? 'Encontrado'
        : 'Perdido'; // Actualizar el valor de status

    // Usamos la imagen actual si no se selecciona una nueva
    final updatedImage = base64Image ?? widget.post.lostItem.image;

    // Construir el payload dinámicamente con los valores actualizados
    final Map<String, dynamic> payload = {
      "name": updatedName,
      "description": updatedDescription,
      "image": updatedImage,
      "found": updatedFound, // Aquí está 'found' que es un bool
      "status": updatedStatus,
      "category": updatedCategory,
      "location": updatedLocation,
      "career": updatedCareer,
    };

    // Imprimir el payload para verificar que 'found' tiene el valor correcto
    print("Payload para la actualización: $payload");

    try {
      // Llamar al servicio para actualizar el objeto
      await updateLostItem(
        lostItemId: widget.post.lostItem.id,
        name: updatedName,
        description: updatedDescription,
        image: updatedImage,
        found: updatedFound,
        status: updatedStatus,
        category: updatedCategory,
        location: updatedLocation,
        career: updatedCareer,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Objeto actualizado con éxito')),
      );
      print(found);
      Navigator.pop(context);
    } catch (e) {
      _showError('Error al actualizar: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deletePost() async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('¿Estás seguro?'),
          content: const Text(
              '¿Estás seguro de que deseas eliminar esta publicación?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // El usuario cancela
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // El usuario confirma
              },
              child: const Text('Sí'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        await deletePost(widget.post.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Publicación eliminada con éxito')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MyPostsScreen(userId: ''),
          ),
        );
      } catch (e) {
        _showError('Error al eliminar: $e');
      }
    }
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

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Publicación'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: screenWidth > 600
                  ? 600
                  : double.infinity, // Limita ancho en web
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView(
                children: [
                  const Text(
                    'Edita la publicación',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del objeto perdido',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
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
                    onChanged: (value) =>
                        setState(() => selectedCategory = value),
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
                    onChanged: (value) =>
                        setState(() => selectedLocation = value),
                    decoration: const InputDecoration(
                      labelText: 'Ubicación',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _careerController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Carrera',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (isAdmin) const SizedBox(height: 16),
                  if (isAdmin)
                    DropdownButtonFormField<bool>(
                      value: found,
                      items: const [
                        DropdownMenuItem(
                          value: true,
                          child: Text('Sí'),
                        ),
                        DropdownMenuItem(
                          value: false,
                          child: Text('No'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          found = value!;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Almacenado',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text('Seleccionar Imagen'),
                  ),
                  const SizedBox(height: 16),
                  if (base64Image != null)
                    const Text('Imagen seleccionada',
                        style: TextStyle(color: Colors.green)),
                  const SizedBox(height: 24),
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _updateLostItem,
                                child: const Text('Guardar Cambios'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _deletePost,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('Eliminar'),
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
