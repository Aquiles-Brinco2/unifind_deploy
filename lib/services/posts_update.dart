import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:objetos_perdidos/services/token.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> updateLostItem({
  required String lostItemId,
  required String name,
  required String description,
  required String image,
  required bool found, // El estado de encontrado
  required String status, // El estado del objeto ("Perdido" o "Encontrado")
  required String category,
  required String location,
  required String career,
}) async {
  final url = Uri.parse('$ngrokLink/api/lost-items/$lostItemId');

  // Obtener el token de SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  // Si no se proporciona un 'status', lo configuramos según el valor de 'found'
  String updatedStatus =
      status.isEmpty ? (found ? 'Encontrado' : 'Perdido') : status;

  final response = await http.put(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'ngrok-skip-browser-warning': 'true',
    },
    body: jsonEncode({
      "name": name.isEmpty
          ? ""
          : name, // Si no se proporciona nombre, se envía vacío
      "description":
          description.isEmpty ? "" : description, // Lo mismo con la descripción
      "image": image.isEmpty
          ? ""
          : image, // Si no se proporciona imagen, se envía vacío
      "found": found, // Estado de encontrado
      "status": updatedStatus, // Estado basado en 'found'
      "category": category.isEmpty
          ? ""
          : category, // Si no se proporciona categoría, se envía vacío
      "location": location.isEmpty ? "" : location, // Lo mismo con la ubicación
      "career": career.isEmpty ? "" : career, // Lo mismo con la carrera
    }),
  );

  if (response.statusCode == 200) {
    print('Objeto perdido actualizado con éxito: ${response.body}');
  } else {
    throw Exception('Error al actualizar el objeto perdido: ${response.body}');
  }
}
