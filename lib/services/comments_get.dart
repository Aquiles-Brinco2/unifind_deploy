import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:objetos_perdidos/services/main_class.dart';
import 'package:objetos_perdidos/services/token.dart';

Future<List<Comment>> fetchCommentsByPostId(String postId) async {
  try {
    final response = await http.get(
      Uri.parse('$ngrokLink/api/posts/$postId/comments'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    // Registra el estado y el cuerpo de la respuesta
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((comment) => Comment.fromJson(comment)).toList();
    } else {
      throw Exception(
          'Error al cargar comentarios: ${response.statusCode}. ${response.body}');
    }
  } catch (e) {
    throw Exception('Error al cargar comentarios: $e');
  }
}
