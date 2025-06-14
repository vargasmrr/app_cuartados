import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  static Future<Map<String, dynamic>> getUserInfo({required String token}) async {
    final url = Uri.parse('https://app-iv-ii-main-td0mcu.laravel.cloud/api/user');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Asegúrate que el backend devuelve directamente los campos del usuario, no dentro de 'user'
      return jsonDecode(response.body);
    } else {
      throw Exception('Error obteniendo usuario');
    }
  }

  static Future<Map<String, dynamic>> updateUser({
    required String token,
    String? name,
    String? email,
    String? password,
  }) async {
    final url = Uri.parse('https://app-iv-ii-main-td0mcu.laravel.cloud/api/edit');

    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (email != null) body['email'] = email;
    if (password != null && password.isNotEmpty) body['password'] = password;

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error actualizando usuario: ${response.body}');
    }
  }
}
