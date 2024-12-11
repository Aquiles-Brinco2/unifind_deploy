import 'package:http/http.dart' as http;
import 'package:objetos_perdidos/services/token.dart'; // Si tienes un archivo de tokens

class UsersDelete {
  // Método para eliminar un usuario
  Future<bool> deleteUser(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$ngrokLink/api/users/user/$userId'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      if (response.statusCode == 200) {
        return true; // El usuario fue eliminado con éxito
      } else {
        throw Exception('Error al eliminar usuario');
      }
    } catch (e) {
      throw Exception('Error eliminando usuario: $e');
    }
  }
}
