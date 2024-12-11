import 'package:http/http.dart' as http;
import 'package:objetos_perdidos/services/token.dart';

// Eliminar todos los puntos de un usuario
Future<bool> deleteAllPoints(String userId) async {
  final url = Uri.parse('$ngrokLink/api/points/points/$userId');

  try {
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Error al eliminar los puntos: ${response.body}');
      return false;
    }
  } catch (e) {
    print('Error al eliminar los puntos: $e');
    return false;
  }
}
