// ignore_for_file: use_build_context_synchronously, deprecated_member_use
import 'package:app_cuartados/controllers/logout_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'materia_details_page.dart';
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
  String estadoSeleccionado = 'todos'; // Para controlar el filtro activo

  @override
  void initState() {
    super.initState();
    fetchMaterias(); // Traer todas las materias al inicio
  }

  // Función para obtener todas las materias (sin filtro)
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

  // Función para obtener materias filtradas por estado
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

  // Filtra las materias localmente según el texto de búsqueda
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

//FUNCION PARA CERRAR SESIÓN
  Future<void> logout() async {
  try {
    await logoutService(widget.token);

    // Borrar el token guardado
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    // Redirigir al Login
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


  // Barra con botones para filtrar por estado
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Mis Materias',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.blue.shade700,
        actions: [
          IconButton(
            icon: Icon(Icons.person_outline, color: Colors.white), // Cambiado
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
            icon: Icon(Icons.logout, color: Colors.white), // Cambiado
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

                  // Barra de filtro por estado
                  _buildEstadoBar(),

                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Buscar por nombre o codigo...',
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
