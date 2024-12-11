import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:objetos_perdidos/services/token.dart';

// Eliminar un número aleatorio de puntos de un usuario
Future<bool> deleteRandomPoints(String userId, int numToDelete) async {
  final url = Uri.parse('$ngrokLink/api/points/points/random/$userId');

  final body = json.encode({'numToDelete': numToDelete});

  try {
    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data['message']);
      return true;
    } else {
      print('Error al eliminar puntos aleatorios: ${response.body}');
      return false;
    }
  } catch (e) {
    print('Error al eliminar puntos aleatorios: $e');
    return false;
  }
}
