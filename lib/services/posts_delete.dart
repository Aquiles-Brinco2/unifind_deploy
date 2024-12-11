import 'package:http/http.dart' as http;
import 'package:objetos_perdidos/services/token.dart';

Future<void> deletePost(String postId) async {
  final response = await http.delete(
    Uri.parse('$ngrokLink/api/posts/post/id/$postId'),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Error al eliminar la publicación');
  }
}
