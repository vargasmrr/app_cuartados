// ignore_for_file: use_build_context_synchronously, deprecated_member_use
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'login_page.dart';
import 'materia_details_page.dart';
import 'package:app_cuartados/pages/edit_profile_page.dart';

class HomePage extends StatefulWidget {
  final String token;
  const HomePage({super.key, required this.token});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> materias = [];
  List<dynamic> materiasFiltradas = [];
  bool isLoading = true;
  String query = '';

  @override
  void initState() {
    super.initState();
    fetchMaterias();
  }

  Future<void> fetchMaterias() async {
    final url =
        Uri.parse('https://app-iv-ii-main-td0mcu.laravel.cloud/api/materias');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          materias = data['materias'];
          materiasFiltradas = materias;
          isLoading = false;
        });
      } else {
        throw Exception(data['message'] ?? 'Error al cargar materias');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void filtrarMaterias(String text) {
    setState(() {
      query = text;
      materiasFiltradas = materias.where((materia) {
        final nombre = materia['nombre']?.toLowerCase() ?? '';
        final docente = materia['docente']?.toLowerCase() ?? '';
        return nombre.contains(text.toLowerCase()) ||
            docente.contains(text.toLowerCase());
      }).toList();
    });
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final url =
        Uri.parse('https://app-iv-ii-main-td0mcu.laravel.cloud/api/logout');

    await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
    );

    await prefs.remove('token');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Mis Materias'),
        backgroundColor: Colors.blue.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Editar perfil',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UpdateUserPage(token: widget.token),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: logout,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 180,
                          color: Colors.grey.shade300,
                          child: Image.asset(
                            'assets/ucem.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(
                                    child: Icon(Icons.broken_image,
                                        size: 80, color: Colors.grey)),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          height: 180,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                            color: Colors.blue.shade700.withOpacity(0.35),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Buscar por nombre o docente...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: filtrarMaterias,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Expanded(
                    child: materiasFiltradas.isEmpty
                        ? const Center(child: Text('No hay materias encontradas'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            itemCount: materiasFiltradas.length,
                            itemBuilder: (context, index) {
                              final materia = materiasFiltradas[index];
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 4,
                                margin:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.blue.shade100,
                                    child: Icon(Icons.book_rounded,
                                        color: Colors.blue.shade700),
                                  ),
                                  title: Text(
                                    materia['nombre'] ?? 'Sin nombre',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Docente: ${materia['docente'] ?? 'No asignado'}',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  trailing: Icon(Icons.arrow_forward_ios,
                                      size: 16, color: Colors.blue.shade700),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => MateriaDetailPage(
                                          id: materia['id'].toString(),
                                          token: widget.token,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
