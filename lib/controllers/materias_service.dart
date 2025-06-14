// materias_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<dynamic>> materiasService(String token) async {
  final url = Uri.parse('https://app-iv-ii-main-td0mcu.laravel.cloud/api/materias');
  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  final data = jsonDecode(response.body);

  if (response.statusCode == 200) {
    return data['materias'];
  } else {
    throw Exception(data['message'] ?? 'Error al cargar materias');
  }
}
