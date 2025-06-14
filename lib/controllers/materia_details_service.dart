import 'dart:convert';
import 'package:http/http.dart' as http;

class MateriaDetailsService {
  static Future<Map<String, dynamic>> getMateriaDetalle({
    required String id,
    required String token,
  }) async {
    final url = Uri.parse('https://app-iv-ii-main-td0mcu.laravel.cloud/api/materia/detalle/$id');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['materia'] != null) {
      return data['materia'];
    } else {
      throw Exception(data['message'] ?? 'Error al cargar el detalle de la materia');
    }
  }
}
