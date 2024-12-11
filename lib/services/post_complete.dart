import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:objetos_perdidos/services/token.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Función para actualizar el estado de un post
Future<bool> updatePost(
    String postId, String postStatus, String completeWith) async {
  final url = Uri.parse(
      '$ngrokLink/api/posts/posts/forPoints/$postId'); // La URL de tu ruta PUT

  // El cuerpo de la solicitud con los parámetros que vamos a actualizar
  final body = json.encode({
    'postStatus': 'completado',
    'completeWith': completeWith,
  });

  final prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  try {
    final response = await http.put(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    // Verificamos si la respuesta fue exitosa
    if (response.statusCode == 200) {
      // Si la actualización fue exitosa
      return true;
    } else {
      // Si la actualización no fue exitosa
      return false;
    }
  } catch (error) {
    print('Error al actualizar el post: $error');
    return false;
  }
}
