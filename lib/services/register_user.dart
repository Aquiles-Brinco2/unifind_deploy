import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:objetos_perdidos/services/token.dart';

Future<Map<String, dynamic>> registerUser(String email, String password,
    String carrera, String name, String phone, String base64Image) async {
  final url = Uri.parse(
      '$ngrokLink/api/auth/register'); // Cambia a tu endpoint de registro

  try {
    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
        'carrera': carrera,
        'userType': 'normal',
        'name': name,
        'phone': phone,
        'image': base64Image,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return {
        'success': true,
        'user': data['user'],
      };
    } else {
      final data = jsonDecode(response.body);
      return {
        'success': false,
        'message': data['message'],
      };
    }
  } catch (e) {
    return {
      'success': false,
      'message': 'Error de conexión',
    };
  }
}
