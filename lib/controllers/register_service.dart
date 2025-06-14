import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> register(String name, String email, String password) async {
  try {
    final response = await http.post(
      Uri.parse('https://app-iv-ii-main-td0mcu.laravel.cloud/api/register'),
      headers: {'Accept': 'application/json'},
      body: {
        'name': name,
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'success': true,
        'token': data['token_app'],
        'user': data['usuario'],
      };
    } else {
      final error = json.decode(response.body);
      return {
        'success': false,
        'message': error['message'] ?? 'Error en el registro',
      };
    }
  } catch (e) {
    return {
      'success': false,
      'message': 'Error de conexión: ${e.toString()}',
    };
  }
}
