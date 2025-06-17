// ignore_for_file: use_build_context_synchronously, deprecated_member_use
import 'package:app_cuartados/controllers/logout_service.dart';
import 'package:app_cuartados/pages/materia_details_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'package:app_cuartados/pages/edit_profile_page.dart';
import 'package:app_cuartados/controllers/materia_estado_service.dart';
import 'package:app_cuartados/controllers/materias_service.dart';

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
  String estadoSeleccionado = 'todos';
  String nombreUsuario = '';

  @override
  void initState() {
    super.initState();
    fetchMaterias();
    obtenerNombreUsuario();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    obtenerNombreUsuario(); // Aquí actualiza el nombre del usuario
  }

  Future<void> obtenerNombreUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nombreUsuario = prefs.getString('name') ?? 'Estudiante';
    });
  }

  Future<void> fetchMaterias() async {
    setState(() => isLoading = true);
    try {
      final todasMaterias = await materiasService(widget.token);
      setState(() {
        materias = todasMaterias;
        materiasFiltradas = todasMaterias;
        isLoading = false;
        estadoSeleccionado = 'todos';
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> fetchMateriasPorEstado(String estado) async {
    setState(() => isLoading = true);
    try {
      final nuevasMaterias = await materiaEstadoService(estado, widget.token);
      setState(() {
        materias = nuevasMaterias;
        materiasFiltradas = nuevasMaterias;
        isLoading = false;
        estadoSeleccionado = estado;
      });
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
        final codigo = materia['codigo']?.toLowerCase() ?? '';
        return nombre.contains(text.toLowerCase()) ||
            codigo.contains(text.toLowerCase());
      }).toList();
    });
  }

  Future<void> logout() async {
    try {
      await logoutService(widget.token);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('nombre');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión: ${e.toString()}')),
      );
    }
  }

  Widget _buildEstadoBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildEstadoButton('todos', 'Todas'),
          _buildEstadoButton('pendiente', 'Pendientes'),
          _buildEstadoButton('aprobada', 'Aprobadas'),
          _buildEstadoButton('matriculada', 'Matriculadas'),
        ],
      ),
    );
  }

  Widget _buildEstadoButton(String estado, String texto) {
    final isSelected = estadoSeleccionado == estado;
    return ElevatedButton(
      onPressed: () {
        if (estado == 'todos') {
          fetchMaterias();
        } else {
          fetchMateriasPorEstado(estado);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isSelected ? Colors.blue.shade700 : Colors.grey.shade400,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(texto, style: const TextStyle(color: Colors.white)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: Colors.blue),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hola, $nombreUsuario',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Editar Perfil'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UpdateUserPage(token: widget.token),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar Sesión'),
              onTap: () {
                Navigator.pop(context);
                logout();
              },
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 180,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                          image: DecorationImage(
                            image: const AssetImage('assets/ucem.png'),
                            fit: BoxFit.contain,
                            onError: (exception, stackTrace) =>
                                const Icon(Icons.broken_image),
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: 180,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade700.withOpacity(0.2),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        top: 16,
                        child: Builder(
                          builder: (context) => IconButton(
                            icon: const Icon(Icons.menu, color: Colors.black),
                            onPressed: () => Scaffold.of(context).openDrawer(),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        bottom: 12,
                        child: Text(
                          'Bienvenido, $nombreUsuario',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  _buildEstadoBar(),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Buscar por nombre o código...',
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
                        ? const Center(
                            child: Text('No hay materias encontradas'))
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
                                margin: const EdgeInsets.symmetric(vertical: 8),
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
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => MateriaDetailPage(
                                          token: widget.token,
                                         id: materia['id'].toString(),
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
