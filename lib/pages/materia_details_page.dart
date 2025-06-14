// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:app_cuartados/controllers/materia_details_service.dart';

class MateriaDetailPage extends StatefulWidget {
  final String id;
  final String token;
  const MateriaDetailPage({super.key, required this.id, required this.token});

  @override
  State<MateriaDetailPage> createState() => _MateriaDetailPageState();
}

class _MateriaDetailPageState extends State<MateriaDetailPage> {
  Map<String, dynamic>? detalle;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    try {
      final result = await MateriaDetailsService.getMateriaDetalle(
        id: widget.id,
        token: widget.token,
      );
      setState(() {
        detalle = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Widget _infoRow(IconData icon, String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade700),
          const SizedBox(width: 10),
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Materia'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : detalle == null
              ? const Center(child: Text('No se pudo cargar el detalle'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                detalle!['nombre'] ?? 'Nombre no disponible',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const Divider(height: 30, thickness: 2),
                            _infoRow(Icons.book_outlined, 'Código', detalle!['codigo']),
                            _infoRow(Icons.person_outline, 'Docente', detalle!['docente']),
                            _infoRow(Icons.star, 'Créditos', detalle!['creditos']?.toString()),
                            _infoRow(Icons.check_circle_outline, 'Estado', detalle!['estado']),
                            _infoRow(Icons.rule_folder, 'Requisito', detalle!['requisito']?.toString()),
                            const SizedBox(height: 12),
                            if (detalle!.containsKey('descripcion') &&
                                detalle!['descripcion'] != null &&
                                detalle!['descripcion'].toString().isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Descripción:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    detalle!['descripcion'],
                                    style: const TextStyle(fontSize: 16, height: 1.4),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }
}
