import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:objetos_perdidos/services/main_class.dart';
import 'package:objetos_perdidos/services/token.dart';

Future<List<Post>> fetchFoundPosts() async {
  try {
    final response = await http.get(
      Uri.parse('$ngrokLink/api/posts/'), // Aquí va la URL del servidor
      headers: {
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    if (response.statusCode == 200) {
      // Decodifica la respuesta y transforma los datos a una lista de Posts
      List<dynamic> data = jsonDecode(response.body);

      // Filtra los posts para solo devolver los que tengan found == true
      List<Post> foundPosts = data
          .map((post) => Post.fromJson(post))
          .where((post) => post.lostItem.found == true)
          .toList();

      return foundPosts;
    } else {
      throw Exception(
          'Failed to load posts. Status code: ${response.statusCode}. Body: ${response.body}');
    }
  } catch (e, stackTrace) {
    print('Error: $e');
    print('Stack trace: $stackTrace');
    throw Exception('Failed to load posts: $e');
  }
}
