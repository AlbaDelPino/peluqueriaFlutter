import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cliente_provider.dart';
import '../shared_prefs/user_preferences.dart';

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

  Widget _buildPasswordField(TextEditingController controller, String label, IconData icon) {
    const primary = Color(0xFFFF8B00);
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: TextFormField(
        controller: controller,
        obscureText: true,
        validator: (value) =>
            value == null || value.isEmpty ? "Este campo es obligatorio" : null,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: primary),
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildPasswordField(_passwordCtrl, "Nueva contraseña", Icons.lock),
              _buildPasswordField(_confirmCtrl, "Confirmar contraseña", Icons.lock_outline),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _guardarNuevaPassword,
                  child: const Text(
                    "Aceptar",
                    style: TextStyle(color: Colors.white, fontSize: 16),
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
