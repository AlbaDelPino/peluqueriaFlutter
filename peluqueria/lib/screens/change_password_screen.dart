import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cliente_provider.dart';
import '../shared_prefs/user_preferences.dart';
<<<<<<< Updated upstream
import '../widgets/widget.dart'; // 👈 importa tus widgets reutilizables
=======
>>>>>>> Stashed changes

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
<<<<<<< Updated upstream
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
=======
  "id": prefs.clienteId,
  "username": provider.cliente!.username,
  "nombre": provider.cliente!.nombre,
  "email": provider.cliente!.email,
  "telefono": provider.cliente!.telefono,
  "contrasenya": _passwordCtrl.text, // 👈 solo aquí
  "estado": provider.cliente!.estado,
  "role": provider.cliente!.role,
  "alergenos": provider.cliente!.alergenos,
  "direccion": provider.cliente!.direccion,
  "observacion": provider.cliente!.observacion,
  "imagen": provider.cliente!.imagen,
};

>>>>>>> Stashed changes

      await provider.actualizarCliente(clienteActualizado);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Contraseña actualizada correctamente")),
      );

<<<<<<< Updated upstream
      Navigator.pop(context); // volver a EditProfileScreen
=======
      Navigator.pop(context); // 👈 volver a EditProfileScreen
>>>>>>> Stashed changes
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFFFF8B00);

    return Scaffold(
<<<<<<< Updated upstream
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
=======
      appBar: AppBar(
        backgroundColor: primary,
        title: const Text("Cambiar Contraseña", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _passwordCtrl,
                decoration: const InputDecoration(labelText: "Nueva contraseña"),
                obscureText: true,
                validator: (value) =>
                    value == null || value.isEmpty ? "Introduce una contraseña" : null,
              ),
              TextFormField(
                controller: _confirmCtrl,
                decoration: const InputDecoration(labelText: "Confirmar contraseña"),
                obscureText: true,
                validator: (value) =>
                    value == null || value.isEmpty ? "Confirma la contraseña" : null,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: primary),
                onPressed: _guardarNuevaPassword,
                child: const Text("Aceptar", style: TextStyle(color: Colors.white)),
              ),
            ],
>>>>>>> Stashed changes
          ),
        ),
      ),
    );
  }
}
