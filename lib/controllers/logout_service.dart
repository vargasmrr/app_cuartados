import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> logout() async {
  const String baseUrl =
      'https://app-iv-ii-main-td0mcu.laravel.cloud/api/logout';

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('accessToken');

  if (token == null) {
    return false;
  }

  final headers = {
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  final url = Uri.parse(baseUrl);

  try {
    final response = await http.post(url, headers: headers);

    if (response.statusCode == 204) {
      await prefs.remove('accessToken');
      return true;
    } else {
      return false;
    }
  } catch (e) {
    return false;
  }
}
