import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:objetos_perdidos/services/token.dart';

class ForgotPasswordService {
  final String apiUrl = '$ngrokLink/api/forgot-password'; // Cambiar a tu ruta

  Future<String> sendForgotPasswordEmail(String email) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['message']; // Mensaje de éxito
      } else {
        final error = jsonDecode(response.body);
        return error['error']; // Mensaje de error
      }
    } catch (e) {
      return 'Error al enviar el correo: $e';
    }
  }
}
