import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cliente_provider.dart';
import '../providers/auth_provider.dart';
import '../shared_prefs/user_preferences.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  static const String routeName = 'profile';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final prefs = UserPreferences();
      context.read<ClienteProvider>().cargarClientePorUsername(prefs.username);
    });
  }

  Widget _infoItem(IconData icon, String label, String value) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFFF8B00)),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value.isEmpty ? "Sin definir" : value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cliente = context.watch<ClienteProvider>().cliente;
    const primary = Color(0xFFFF8B00);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        title: const Text("Perfil", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: cliente == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: primary.withOpacity(0.2),
                    backgroundImage: cliente.imagen != null
                        ? MemoryImage(cliente.imagen!)
                        : null,
                    child: cliente.imagen == null
                        ? const Icon(Icons.person, size: 60, color: primary)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(cliente.nombre,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  _infoItem(Icons.account_circle, "Username", cliente.username),
                  _infoItem(Icons.email, "Email", cliente.email),
                  _infoItem(Icons.phone, "Teléfono", cliente.telefono.toString()),
                  _infoItem(Icons.home, "Dirección", cliente.direccion),
                  _infoItem(Icons.warning, "Alérgenos", cliente.alergenos),
                  _infoItem(Icons.note, "Observación", cliente.observacion),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 24),
                    ),
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text("Cerrar sesión",
                        style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      context.read<AuthProvider>().logout();
                      Navigator.pushReplacementNamed(context, '/');
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
