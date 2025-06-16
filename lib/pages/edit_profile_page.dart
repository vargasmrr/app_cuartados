// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:app_cuartados/controllers/update_service.dart';

class UpdateUserPage extends StatefulWidget {
  final String token;
  const UpdateUserPage({super.key, required this.token});

  @override
  State<UpdateUserPage> createState() => _UpdateUserPageState();
}

class _UpdateUserPageState extends State<UpdateUserPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late String originalName;
  late String originalEmail;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      final user = await UserService.getUserInfo(token: widget.token);
      _nameController.text = user['name'] ?? '';
      _emailController.text = user['email'] ?? '';
      originalName = user['name'] ?? '';
      originalEmail = user['email'] ?? '';
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cargar el usuario')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> updateUser() async {
    if (!_formKey.currentState!.validate()) return;

    final newName = _nameController.text.trim();
    final newEmail = _emailController.text.trim();
    final newPassword = _passwordController.text;

    final noNameChange = newName == originalName;
    final noEmailChange = newEmail == originalEmail;
    final noPasswordChange = newPassword.isEmpty;

    if (noNameChange && noEmailChange && noPasswordChange) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se detectaron cambios para actualizar')),
      );
      return;
    }

    try {
      await UserService.updateUser(
        token: widget.token,
        name: newName,
        email: newEmail,
        password: newPassword.isEmpty ? null : newPassword,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario actualizado con éxito')),
      );

      originalName = newName;
      originalEmail = newEmail;
      _passwordController.clear();

      await Future.delayed(const Duration(milliseconds: 800));
      Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error actualizando: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Icon(Icons.person, size: 100, color: Colors.blue.shade700),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingrese un nombre';
                        }
                        if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                          return 'El nombre solo puede contener letras';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingrese un correo';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$')
                            .hasMatch(value)) {
                          return 'Correo no válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Nueva contraseña (opcional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                      validator: (value) {
                        if (value != null &&
                            value.isNotEmpty &&
                            value.length < 8) {
                          return 'La contraseña debe tener al menos 8 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: updateUser,
                        icon: const Icon(Icons.save, color: Colors.white),
                        label: const Text(
                          'Guardar Cambios',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
