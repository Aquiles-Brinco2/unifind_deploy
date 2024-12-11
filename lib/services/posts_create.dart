import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:objetos_perdidos/services/token.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, dynamic>> createPublication(
    String name,
    String description,
    String image,
    String category,
    String location,
    String career,
    String status) async {
  final url = Uri.parse('$ngrokLink/api/lost-items/create');

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
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'description': description,
        'image': image,
        'category': category,
        'location': location,
        'career': career,
        'status': status,
        'user': userId,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return {
        'success': true,
        'message': 'Publicación creada con éxito',
        'publication': data,
      };
    } else {
      final data = jsonDecode(response.body);
      return {
        'success': false,
        'message': data['message'],
      };
    }
  } catch (e) {
    return {
      'success': false,
      'message': 'Error de conexión',
    };
  }
}
