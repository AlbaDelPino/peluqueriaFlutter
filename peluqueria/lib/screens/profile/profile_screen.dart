import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../shared_prefs/user_preferences.dart';
import '../../widgets/widget.dart'; // 👈 importa InfoCard y PrimaryButton
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

  @override
  Widget build(BuildContext context) {
    final cliente = context.watch<ClienteProvider>().cliente;
    const primary = Color(0xFFFF8B00);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: primary,
        centerTitle: true,
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
          : SafeArea(
              child: SingleChildScrollView(
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
                    Text(
                      cliente.nombre,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),
                    InfoCard(icon: Icons.account_circle, label: "Username", value: cliente.username),
                    InfoCard(icon: Icons.email, label: "Email", value: cliente.email),
                    InfoCard(icon: Icons.phone, label: "Teléfono", value: cliente.telefono.toString()),
                    InfoCard(icon: Icons.home, label: "Dirección", value: cliente.direccion),
                    InfoCard(icon: Icons.warning, label: "Alérgenos", value: cliente.alergenos),
                    InfoCard(icon: Icons.note, label: "Observación", value: cliente.observacion),
                    const SizedBox(height: 30),
                    PrimaryButton(
                      text: "Cerrar sesión",
                      onPressed: () {
                        context.read<AuthProvider>().logout();
                        Navigator.pushReplacementNamed(context, '/');
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
