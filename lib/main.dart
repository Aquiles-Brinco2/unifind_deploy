import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:objetos_perdidos/pages/home_admin.dart';
import 'package:objetos_perdidos/pages/login_screen.dart';
import 'package:objetos_perdidos/pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Importante para usar kIsWeb

void main() {
  debugPaintSizeEnabled = false;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Detectamos si estamos en un dispositivo web (pantallas más grandes)
    bool isWeb = MediaQuery.of(context).size.width > 600;

    return MaterialApp(
      title: 'Objetos Perdidos',
      theme: ThemeData(
        primaryColor: const Color(0xFFA50050),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Parkinsans'),
          bodyMedium: TextStyle(fontFamily: 'Parkinsans'),
          displayLarge: TextStyle(fontFamily: 'Parkinsans'),
          displayMedium: TextStyle(fontFamily: 'Parkinsans'),
        ),
        appBarTheme: const AppBarTheme(
          color: Color(0xFFA50050),
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            fontFamily: 'Parkinsans',
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFA50050),
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontFamily: 'Parkinsans',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 4,
            shadowColor: Colors.grey.withOpacity(0.3),
            minimumSize: const Size.fromHeight(50),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFA50050)),
          ),
          prefixIconColor: const Color(0xFFA50050),
        ),
      ),
      home: FutureBuilder<Map<String, dynamic>>(
        future: checkLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError ||
              !snapshot.hasData ||
              !snapshot.data!['loggedIn']) {
            return const LoginScreen();
          } else {
            final userType = snapshot.data!['userType'];
            if (userType == 'admin') {
              return const DashboardScreen(); // Redirige a DashboardScreen si es admin
            } else {
              // Añadimos un contenedor con un ancho máximo para web
              return Container(
                width: isWeb
                    ? 800
                    : double.infinity, // 800px de ancho máximo en web
                padding: const EdgeInsets.all(16),
                child:
                    const HomeScreen(), // Redirige a HomeScreen si no es admin
              );
            }
          }
        },
      ),
    );
  }

  // Función para verificar si el usuario está logueado y obtener su tipo
  Future<Map<String, dynamic>> checkLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();

    // Verifica si el token existe, lo cual indica que el usuario está logueado
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      return {
        'loggedIn': false,
        'userType': ''
      }; // Si no está logueado, devuelve false y un userType vacío
    }

    // Si está logueado, obtiene el tipo de usuario
    final userType = prefs.getString('user_type') ??
        ''; // Obtiene el tipo de usuario ('admin' o no)

    return {
      'loggedIn': true,
      'userType': userType
    }; // Devuelve que está logueado y el tipo de usuario
  }
}
