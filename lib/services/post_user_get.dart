import 'package:objetos_perdidos/services/main_class.dart';
import 'package:objetos_perdidos/services/token.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<Post>> fetchMyPosts() async {
  final prefs = await SharedPreferences.getInstance();
  String? userId = prefs.getString('user_id');

  final response = await http.get(
    Uri.parse('$ngrokLink/api/posts/user/$userId'), // Ajusta tu endpoint
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Post.fromJson(json)).toList();
  } else {
    throw Exception('Error al cargar las publicaciones del usuario');
  }
}
