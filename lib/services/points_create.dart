import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:objetos_perdidos/services/token.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Crear un punto
Future<bool> createPoint(String userId, String postId) async {
  final url = Uri.parse('$ngrokLink/api/points/points');

  final body = json.encode({
    'userId': userId,
    'postId': postId,
  });

  final prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  try {
    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      print('Error al crear el punto: ${response.body}');
      return false;
    }
  } catch (e) {
    print('Error al crear el punto: $e');
    return false;
  }
}
