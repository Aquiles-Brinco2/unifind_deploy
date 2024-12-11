import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:objetos_perdidos/services/token.dart';

class UsersGetAll {
  // Método para obtener todos los usuarios
  Future<List<dynamic>> fetchUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$ngrokLink/api/users/users'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
  }
}
