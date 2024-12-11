import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:objetos_perdidos/services/token.dart';

// Obtener los puntos de un usuario
Future<int> getPointsCount(String userId) async {
  final url = Uri.parse('$ngrokLink/api/points/points/$userId');

  try {
    final response = await http.get(headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    }, url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['points'];
    } else {
      print('Error al obtener los puntos: ${response.body}');
      return 0;
    }
  } catch (e) {
    print('Error al obtener los puntos: $e');
    return 0;
  }
}
