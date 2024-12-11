import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:objetos_perdidos/services/token.dart';

Future<Map<String, dynamic>> loginUser(
    String emailOrPhone, String password) async {
  final url =
      Uri.parse('$ngrokLink/api/auth/login'); // Cambia a la IP del backend

  try {
    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
      body: jsonEncode({
        'email': emailOrPhone,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'success': true,
        'token': data['token'],
        'user': data['user'],
      };
    } else {
      final data = jsonDecode(response.body);
      return {
        'success': false,
        'message': data['msg'],
      };
    }
  } catch (e) {
    return {
      'success': false,
      'message': 'Error de conexión',
    };
  }
}
