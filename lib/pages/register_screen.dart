import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:objetos_perdidos/pages/login_screen.dart';
import 'package:objetos_perdidos/services/register_user.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _carreraController = TextEditingController();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _selectedCarrera = 'Ing. Sistemas'; // Valor por defecto
  File? _selectedImageFile;
  Uint8List? _selectedImageBytes;
  String? _base64Image;

  // Carreras disponibles para el Dropdown
  final List<String> _carreras = [
    'Ing. Sistemas',
    'Medicina',
    'Diseño Gráfico',
  ];

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _base64Image = base64Encode(result.files.single.bytes!);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una imagen válida')),
      );
    }
  }

  bool _isValidName(String name) {
    final nameRegExp = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$');
    return nameRegExp.hasMatch(name);
  }

  bool _isValidEmail(String email) {
    return email.endsWith('univalle.edu');
  }

  bool _isValidPassword(String password) {
    // Expresión regular sin la validación de caracteres especiales
    final passwordRegExp = RegExp(
      r'^(?=.*[A-Z])(?=.*[0-9])(?=.{7,})',
    );
    return passwordRegExp.hasMatch(password);
  }

  Future<void> _registerUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final carrera = _selectedCarrera!;
    final name = _nameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final phone = _phoneController.text.trim();

    if (email.isEmpty ||
        password.isEmpty ||
        carrera.isEmpty ||
        name.isEmpty ||
        lastName.isEmpty ||
        phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    // Validaciones adicionales
    if (!_isValidName(name)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre no puede contener números')),
      );
      return;
    }

    if (!_isValidName(lastName)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El apellido no puede contener números')),
      );
      return;
    }

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('El correo debe terminar en @univalle.edu')),
      );
      return;
    }

    if (!_isValidPassword(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'La contraseña no es válida, debe contener una letra mayúscula y un número')),
      );
      return;
    }

    if (_base64Image == null || _base64Image!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una imagen')),
      );
      return;
    }

    final response = await registerUser(
        email, password, carrera, '$name $lastName', phone, _base64Image!);

    if (response['success']) {
      const SnackBar(content: Text('Registrado con éxito'));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Error al registrarse')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isWeb =
        MediaQuery.of(context).size.width > 600; // Detectar si estamos en web

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          // Centrar todo el contenido
          child: Container(
            constraints: BoxConstraints(
              maxWidth:
                  isWeb ? 600 : double.infinity, // Limitar el ancho en Web
            ),
            child: Column(
              children: [
                _buildTextField(_nameController, 'Nombre', true),
                const SizedBox(height: 16),
                _buildTextField(_lastNameController, 'Apellido', true),
                const SizedBox(height: 16),
                _buildTextField(_emailController, 'Correo electrónico', false),
                const SizedBox(height: 16),
                _buildDropdown(),
                const SizedBox(height: 16),
                _buildTextField(_phoneController, 'Teléfono', false),
                const SizedBox(height: 16),
                _buildTextField(_passwordController, 'Contraseña', true,
                    obscureText: true),
                const SizedBox(height: 16),
                _buildImageSelector(),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _registerUser,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Registrar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, bool allowAlphaOnly,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      inputFormatters: allowAlphaOnly
          ? [
              FilteringTextInputFormatter.allow(
                  RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$'))
            ] // Solo letras y espacios
          : [
              FilteringTextInputFormatter.digitsOnly
            ], // Solo dígitos si no es un campo de texto
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCarrera,
      onChanged: (String? newValue) {
        setState(() {
          _selectedCarrera = newValue!;
        });
      },
      items: _carreras.map<DropdownMenuItem<String>>((String carrera) {
        return DropdownMenuItem<String>(
          value: carrera,
          child: Text(carrera),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: 'Carrera',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildImageSelector() {
    return Row(
      children: [
        SizedBox(
          width: 150,
          child: ElevatedButton(
            onPressed: _pickImage,
            child: const Text('Seleccionar imagen'),
          ),
        ),
        const SizedBox(width: 16),
        if (_selectedImageBytes != null || _selectedImageFile != null)
          const Text(
            'Imagen seleccionada',
            style: TextStyle(color: Colors.green),
          ),
      ],
    );
  }
}
