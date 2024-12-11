import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:objetos_perdidos/services/token.dart';

Future<Map<String, dynamic>> createComment(
    String postId, String content) async {
  final url = Uri.parse('$ngrokLink/api/comments/create'); // Endpoint

  // Obtener el token y userId desde SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  String? userId = prefs.getString('user_id');

  try {
    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
      body: jsonEncode({
        'user': userId,
        'post': postId,
        'content': content,
      }),
    );

    if (response.statusCode == 201) {
      return {
        'success': true,
        'message': 'Comentario publicado con éxito',
      };
    } else {
      print(response.body);
      final data = jsonDecode(response.body);
      return {
        'success': false,
        'message': data['message'] ?? 'Error desconocido',
      };
    }
  } catch (e) {
    return {
      'success': false,
      'message': 'Error al conectar con el servidor: $e',
    };
  }
}
