import 'package:http/http.dart' as http;
import 'package:objetos_perdidos/services/token.dart';

Future<void> deleteComment(String commentId) async {
  final response = await http.delete(
    Uri.parse(
        '$ngrokLink/api/comments/delete/$commentId'), // Cambia la URL a la correcta
    headers: {
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
      // 'Authorization': 'Bearer $token', // Si necesitas autenticación con token, descomenta esta línea
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Error al eliminar el comentario');
  }
}
