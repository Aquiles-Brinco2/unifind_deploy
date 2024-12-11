import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:objetos_perdidos/services/token.dart';

Future<List<Map<String, dynamic>>> fetchLostItemsByMonth() async {
  final response = await http.get(
    Uri.parse('$ngrokLink/api/lost-items/stats/month'),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    },
  );

  if (response.statusCode == 200) {
    return List<Map<String, dynamic>>.from(json.decode(response.body));
  } else {
    throw Exception('Error: ${response.statusCode} - ${response.body}');
  }
}
