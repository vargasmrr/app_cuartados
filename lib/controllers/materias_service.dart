import 'dart:convert';
import 'package:http/http.dart' as http;

class MateriasService {
  static const String _baseUrl = 'https://app-iv-ii-main-td0mcu.laravel.cloud/api';

  /// Obtiene la lista de materias mediante POST, usando token para autorización
  static Future<List<dynamic>> getMaterias({required String token}) async {
    final url = Uri.parse('$_baseUrl/materias');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Asumiendo que el array de materias viene en la clave 'materias'
      return data['materias'] ?? [];
    } else {
      throw Exception('Error al cargar las materias: ${response.body}');
    }
  }
}
