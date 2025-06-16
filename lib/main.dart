import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/home_page.dart';
import 'pages/onbording_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Necesario antes de usar SharedPreferences

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  runApp(MyApp(token: token));
}

class MyApp extends StatelessWidget {
  final String? token;

  const MyApp({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      // Si hay token, vamos a HomePage. Si no, mostramos OnboardingPage.
      home: token != null ? HomePage(token: token!) : const OnboardingPage(),
    );
  }
}
