import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<dynamic>> materiaEstadoService(String estado, String token) async {
  final url = Uri.parse('https://app-iv-ii-main-td0mcu.laravel.cloud/api/pendientes');

  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'estado': estado}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['materias'] ?? [];
  } else {
    final error = jsonDecode(response.body);
    throw Exception(error['message'] ?? 'Error al obtener materias por estado');
  }
}
