import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _logout(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void _editProfile(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función de edición pendiente')),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFFFF8B00);

    final cliente = {
      "Nombre": "Pedro Lopez Garcia",
      "Teléfono": "654789123",
      "Email": "Pedroloezgarcia1@gmail.com",
      "Username": "Pedro123",
      "Contraseña": "********",
      "Alérgenos": "Ninguno",
      "Dirección": "Calle Mayor 12, Benissa",
      "Observaciones": "Prefiere citas por la tarde",
    };

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primary,
        automaticallyImplyLeading: false,
        title: const Align(
          alignment: Alignment.centerRight,
          child: Text('Perfil'),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),

          // Avatar con iniciales
          CircleAvatar(
            radius: 40,
            backgroundColor: primary,
            child: Text(
              cliente["Nombre"]!.substring(0, 2).toUpperCase(),
              style: const TextStyle(fontSize: 28, color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),

          // Nombre, teléfono, email
          Text(cliente["Nombre"]!, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(cliente["Teléfono"]!, style: const TextStyle(color: Colors.grey)),
          Text(cliente["Email"]!, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),

          // Botón editar
          TextButton.icon(
            onPressed: () => _editProfile(context),
            icon: const Icon(Icons.edit, color: Colors.black87),
            label: const Text('Editar', style: TextStyle(color: Colors.black87)),
          ),

          const Divider(height: 32),

          // Datos del cliente
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                _infoItem("Username", cliente["Username"]!),
                _infoItem("Contraseña", cliente["Contraseña"]!),
                _infoItem("Alérgenos", cliente["Alérgenos"]!),
                _infoItem("Dirección", cliente["Dirección"]!),
                _infoItem("Observaciones", cliente["Observaciones"]!),
              ],
            ),
          ),

          // Botón cerrar sesión
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar sesión'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 15, color: Colors.black87)),
        const Divider(height: 24),
      ]),
    );
  }
}
