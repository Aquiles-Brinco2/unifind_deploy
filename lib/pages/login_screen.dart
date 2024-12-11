import 'package:flutter/material.dart';
import 'package:objetos_perdidos/pages/home_admin.dart';
import 'package:objetos_perdidos/pages/register_screen.dart';
import 'package:objetos_perdidos/pages/home_page.dart';
import 'package:objetos_perdidos/services/login_user.dart';
import 'package:objetos_perdidos/services/resend.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // Importante para usar kIsWeb

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Detectar si estamos en un entorno web
    bool isWeb = kIsWeb;

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
      home: isWeb
          ? const Scaffold(
              body: Center(
                child: SizedBox(
                  width: 900, // Define un ancho máximo para web
                  child: LoginScreen(), // Cambia la pantalla según necesites
                ),
              ),
            )
          : const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> handleLogin() async {
    setState(() {
      isLoading = true;
    });

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        isLoading = false;
      });
      _showError('Por favor, completa todos los campos');
      return;
    }

    print({
      'email': email,
      'password': password,
    });

    final result = await loginUser(email, password);

    if (result['success']) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', result['token']);
      final user = result['user'];
      print("hola1");

      await prefs.setString('user_name', user['username']);
      await prefs.setString('user_carrera', user['carrera']);
      await prefs.setString('user_image', user['image']);
      await prefs.setString('user_email', user['email']);
      await prefs.setString('user_phone', user['phone']);
      await prefs.setString('user_type', user['userType']);
      await prefs.setString('user_id', user['userId']);

      // Aquí agregamos la lógica para verificar el userType y redirigir a la pantalla correspondiente
      String userType = user['userType'];

      if (userType == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  const DashboardScreen()), // Redirige a HomeScreen
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  const HomeScreen()), // Redirige a HomeScreen
        );
      }
    } else {
      _showError(result['message'] ?? 'Error desconocido');
    }

    setState(() {
      isLoading = false;
    });
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.grey,
        title: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFA50050), Color(0xFFB24063)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Error',
            style: TextStyle(
              fontFamily: 'Parkinsans',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Parkinsans',
            fontSize: 16,
            color: Color(0xFFA50050),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(
                fontFamily: 'Parkinsans',
                fontWeight: FontWeight.bold,
                color: Color(0xFFA50050),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Función para mostrar el diálogo de recuperación de contraseña
  void _showForgotPasswordDialog() {
    final TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Recuperar Contraseña'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  hintText: 'Ingresa tu correo electrónico',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                final email = emailController.text.trim();
                if (email.isEmpty) {
                  _showError('Por favor ingresa tu correo electrónico');
                  return;
                }

                final forgotPasswordService = ForgotPasswordService();
                final result =
                    await forgotPasswordService.sendForgotPasswordEmail(email);

                if (result == 'Correo enviado exitosamente.') {
                  Navigator.pop(context);
                  _showError(
                      'Correo enviado exitosamente. Revisa tu bandeja de entrada.');
                } else {
                  _showError(result);
                }
              },
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Detectar si estamos en un entorno web
    bool isWeb = kIsWeb;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: SizedBox(
                width: isWeb ? 600 : double.infinity, // Limitar ancho para Web
                child: Column(
                  children: [
                    Image.asset(
                      'assets/Icono.png',
                      height: 120,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Bienvenido',
                      style: TextStyle(
                        fontFamily: 'Parkinsans',
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFA50050),
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildTextField(
                      controller: emailController,
                      hint: 'Correo electrónico',
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: passwordController,
                      hint: 'Contraseña',
                      icon: Icons.lock_outline,
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),
                    isLoading
                        ? const CircularProgressIndicator(
                            color: Color(0xFFA50050))
                        : ElevatedButton(
                            onPressed: handleLogin,
                            child: const Text(
                              'Iniciar Sesión',
                              style: TextStyle(fontFamily: 'Parkinsans'),
                            ),
                          ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        '¿No tienes cuenta? Regístrate',
                        style: TextStyle(
                          fontFamily: 'Parkinsans',
                          color: Color(0xFFA50050),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed:
                          _showForgotPasswordDialog, // Mostrar el diálogo de recuperación de contraseña
                      child: const Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(
                          fontFamily: 'Parkinsans',
                          color: Color(0xFFA50050),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
