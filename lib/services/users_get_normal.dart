import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:objetos_perdidos/services/token.dart';

class UsersGetNormal {
  // Método para obtener todos los usuarios con un filtro opcional por nombre
  Future<List<dynamic>> fetchUsers({String? name}) async {
    try {
      final Map<String, String> queryParameters =
          {}; // Definir el tipo adecuado

      // Si se proporciona el nombre, lo agregamos a los parámetros de consulta
      if (name != null && name.isNotEmpty) {
        queryParameters['name'] = name; // Añadir el nombre al mapa como String
      }

      final Uri uri = Uri.parse('$ngrokLink/api/users/users/normal')
          .replace(queryParameters: queryParameters);

      final response = await http.get(
        uri,
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
