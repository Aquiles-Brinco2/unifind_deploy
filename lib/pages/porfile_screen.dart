import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:objetos_perdidos/services/logout.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:objetos_perdidos/pages/login_screen.dart'; // Importar la pantalla de Login

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Método para obtener la información del usuario almacenada en SharedPreferences
  Future<Map<String, String>> _getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('user_name');
    String? email = prefs.getString('user_email');
    String? phone = prefs.getString('user_phone');
    String? userType = prefs.getString('user_type');
    String? carrera = prefs.getString('user_carrera');
    String? userId = prefs.getString('user_id');
    String? image = prefs.getString('user_image'); // Imagen de usuario

    return {
      'username': username ?? 'No disponible',
      'email': email ?? 'No disponible',
      'phone': phone ?? 'No disponible',
      'userType': userType ?? 'No disponible',
      'carrera': carrera ?? 'No disponible',
      'userId': userId ?? 'No disponible',
      'image': image ?? '', // Si no hay imagen, será una cadena vacía
    };
  }

// Método para mostrar la imagen de usuario
  Widget _buildProfileImage(String imageBase64) {
    bool isWeb = kIsWeb; // Detecta si estamos en la web
    double imageRadius = isWeb ? 100 : 50; // Aumenta el tamaño en la web

    if (imageBase64.isNotEmpty) {
      try {
        // Si la imagen está en formato base64, la decodificamos
        Uint8List imageBytes = base64Decode(imageBase64);
        return CircleAvatar(
          radius: imageRadius, // Aplica el tamaño dinámico
          backgroundImage: MemoryImage(imageBytes),
        );
      } catch (e) {
        print("Error al decodificar la imagen base64: $e");
        return CircleAvatar(
          radius: imageRadius, // Aplica el tamaño dinámico
          backgroundImage: const AssetImage('assets/images/skibidihomero.png'),
        );
      }
    } else {
      // Si no hay imagen o no se pudo cargar, mostramos una imagen por defecto
      return CircleAvatar(
        radius: imageRadius, // Aplica el tamaño dinámico
        backgroundImage: const AssetImage('assets/images/skibidihomero.png'),
      );
    }
  }

  // Método para manejar el cierre de sesión
  Future<void> _handleLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
    String? token = prefs.getString('token'); // Obtener el token almacenado

    if (userId != null && token != null) {
      print(userId);
      print("logout");
      print(token);
      // Llamar al servicio de logout solo si tanto userId como token no son nulos
      AuthService authService = AuthService();
      bool logoutSuccess = await authService.logout(userId, token);

      if (logoutSuccess) {
        // Si el logout fue exitoso, limpiar las preferencias y navegar al login
        await authService.clearUserData(); // Limpiar los datos de usuario
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        // Si hubo un error al hacer logout
        print('Error al hacer logout en el servidor');
      }
    } else {
      print(userId);
      print("logout");
      print(token);
      // Si el token o el userId son nulos, no se puede hacer logout
      print('No se pudo hacer logout, el token o el userId son nulos');
      // Puedes agregar aquí un mensaje de error para el usuario
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    bool isWeb = kIsWeb; // Detecta si estamos en la web

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Usuario'),
      ),
      body: FutureBuilder<Map<String, String>>(
        future: _getUserInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar los datos'));
          } else {
            final userInfo = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Mostrar la imagen de perfil
                    _buildProfileImage(userInfo['image']!),

                    const SizedBox(height: 20),

                    // Nombre del usuario
                    Text(
                      userInfo['username']!,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Información adicional
                    Text(
                      'Correo Electrónico: ${userInfo['email']}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Teléfono: ${userInfo['phone']}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Carrera: ${userInfo['carrera']}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Tipo de Usuario: ${userInfo['userType']}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'ID de Usuario: ${userInfo['userId']}',
                      style: const TextStyle(fontSize: 18),
                    ),

                    // Botón de Cerrar Sesión
                    const SizedBox(height: 30),
                    SizedBox(
                      width: isWeb
                          ? 300
                          : double.infinity, // Reducir el ancho en la web
                      child: ElevatedButton(
                        onPressed: () => _handleLogout(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth > 600 ? 20 : 30, // Dinámico
                            vertical: screenWidth > 600 ? 10 : 12, // Dinámico
                          ),
                        ),
                        child: Text(
                          'Cerrar Sesión',
                          style: TextStyle(
                            fontSize:
                                screenWidth > 600 ? 14 : 16, // Ajusta el tamaño
                          ),
                        ),
                      ),
                    ),

                    // Botón "Salir" para redirigir al login sin salir de la app
                    const SizedBox(height: 20),
                    SizedBox(
                      width: isWeb
                          ? 300
                          : double.infinity, // Reducir el ancho en la web
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth > 600 ? 20 : 30, // Dinámico
                            vertical: screenWidth > 600 ? 10 : 12, // Dinámico
                          ),
                        ),
                        child: Text(
                          'Salir (Redirigir al Login)',
                          style: TextStyle(
                            fontSize:
                                screenWidth > 600 ? 14 : 16, // Ajusta el tamaño
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
