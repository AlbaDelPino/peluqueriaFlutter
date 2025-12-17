import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../shared_prefs/user_preferences.dart';
import '../../widgets/widget.dart'; // 👈 importa tus widgets reutilizables

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  void _guardarNuevaPassword() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordCtrl.text != _confirmCtrl.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Las contraseñas no coinciden")),
        );
        return;
      }

      final provider = context.read<ClienteProvider>();
      final prefs = UserPreferences();

      final clienteActualizado = {
        "id": prefs.clienteId,
        "username": provider.cliente!.username,
        "nombre": provider.cliente!.nombre,
        "email": provider.cliente!.email,
        "telefono": provider.cliente!.telefono,
        "contrasenya": _passwordCtrl.text, // 👈 nueva contraseña
        "estado": provider.cliente!.estado,
        "role": provider.cliente!.role,
        "alergenos": provider.cliente!.alergenos,
        "direccion": provider.cliente!.direccion,
        "observacion": provider.cliente!.observacion,
        "imagen": provider.cliente!.imagen,
      };

      await provider.actualizarCliente(clienteActualizado);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Contraseña actualizada correctamente")),
      );

      Navigator.pop(context); // volver a EditProfileScreen
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFFFF8B00);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primary,
        centerTitle: true,
        title: const Text(
          "Cambiar Contraseña",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Campos usando CustomTextField
                CustomTextField(
                  controller: _passwordCtrl,
                  label: "Nueva contraseña",
                  icon: Icons.lock,
                ),
                CustomTextField(
                  controller: _confirmCtrl,
                  label: "Confirmar contraseña",
                  icon: Icons.lock_outline,
                ),

                const SizedBox(height: 30),

                // Botón Aceptar usando PrimaryButton
                PrimaryButton(
                  text: "Aceptar",
                  onPressed: _guardarNuevaPassword,
                ),

                // Espaciado dinámico para evitar que el teclado tape el botón
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
