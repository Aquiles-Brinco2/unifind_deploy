import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:objetos_perdidos/services/main_class.dart';
import 'package:objetos_perdidos/services/token.dart';

// Servicio para obtener los posts con status "Perdido"
Future<List<Post>> fetchLostPosts({String? postStatus, String? name}) async {
  try {
    // Construimos la query de parámetros de acuerdo a los filtros de status y name
    String query = '';
    if (postStatus != null) {
      query += '?status=$postStatus';
    }
    if (name != null) {
      // Si ya hay otros parámetros, agregamos el filtro de name con "&"
      query += query.isEmpty ? '?name=$name' : '&name=$name';
    }

    final response = await http.get(
      Uri.parse('$ngrokLink/api/posts/lost$query'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((post) => Post.fromJson(post)).toList();
    } else {
      throw Exception(
          'Failed to load lost posts. Status code: ${response.statusCode}.');
    }
  } catch (e) {
    print('Error: $e');
    throw Exception('Failed to load lost posts: $e');
  }
}
