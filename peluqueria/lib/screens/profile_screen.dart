import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  File? _avatarFile;
  String? _assetAvatar;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final prefs = UserPreferences();
      context.read<ClienteProvider>().cargarClientePorUsername(prefs.username);

      if (prefs.avatarPath.isNotEmpty) {
        _avatarFile = File(prefs.avatarPath);
      }
      if (prefs.assetAvatar.isNotEmpty) {
        _assetAvatar = prefs.assetAvatar;
      }
    });
  }

  Future<void> _pickLocalImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _avatarFile = File(picked.path);
        _assetAvatar = null;
      });
      final prefs = UserPreferences();
      prefs.avatarPath = picked.path;
    }
  }

  void _pickAssetAvatar(String assetPath) {
    setState(() {
      _assetAvatar = assetPath;
      _avatarFile = null;
    });
    final prefs = UserPreferences();
    prefs.assetAvatar = assetPath;
  }

  void _showAvatarOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text("Subir foto desde galería"),
              onTap: () {
                Navigator.pop(context);
                _pickLocalImage();
              },
            ),
            const SizedBox(height: 12),
            const Text("Elegir avatar predefinido",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _pickAssetAvatar('assets/avatar/avatar1.png');
                  },
                  child: const CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/avatar/avatar1.png'),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _pickAssetAvatar('assets/avatar/avatar2.png');
                  },
                  child: const CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/avatar/avatar2.png'),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _pickAssetAvatar('assets/avatar/avatar3.png');
                  },
                  child: const CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/avatar/avatar3.png'),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _pickAssetAvatar('assets/avatar/avatar4.png');
                  },
                  child: const CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/avatar/avatar4.png'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: primary.withOpacity(0.2),
                        backgroundImage: _avatarFile != null
                            ? FileImage(_avatarFile!)
                            : (_assetAvatar != null
                                ? AssetImage(_assetAvatar!)
                                : null) as ImageProvider?,
                        child: (_avatarFile == null && _assetAvatar == null)
                            ? const Icon(Icons.person, size: 60, color: primary)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: _showAvatarOptions,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: primary,
                            child: const Icon(Icons.camera_alt,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ],
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
