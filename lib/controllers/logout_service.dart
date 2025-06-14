// logout_service.dart
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<void> logoutService(String token) async {
  final url = Uri.parse('https://app-iv-ii-main-td0mcu.laravel.cloud/api/logout');

  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Error al cerrar sesión');
  }

  // Borrar token local
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('token');
}
