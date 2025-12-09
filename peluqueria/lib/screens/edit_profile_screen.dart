import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/cliente_provider.dart';
import '../shared_prefs/user_preferences.dart';
import '../widgets/widget.dart'; // 👈 importa todos tus widgets reutilizables
import 'change_password_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _usernameCtrl;
  late TextEditingController _nombreCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _telefonoCtrl;
  late TextEditingController _direccionCtrl;
  late TextEditingController _alergenosCtrl;
  late TextEditingController _observacionCtrl;

  File? _avatarFile;
  String? _base64Image;

  @override
  void initState() {
    super.initState();
    final cliente = context.read<ClienteProvider>().cliente;
    _usernameCtrl = TextEditingController(text: cliente?.username ?? '');
    _nombreCtrl = TextEditingController(text: cliente?.nombre ?? '');
    _emailCtrl = TextEditingController(text: cliente?.email ?? '');
    _telefonoCtrl = TextEditingController(text: cliente?.telefono.toString());
    _direccionCtrl = TextEditingController(text: cliente?.direccion ?? '');
    _alergenosCtrl = TextEditingController(text: cliente?.alergenos ?? '');
    _observacionCtrl = TextEditingController(text: cliente?.observacion ?? '');
    _base64Image = cliente?.imagen != null ? base64Encode(cliente!.imagen!) : '';
  }

  Future<void> _pickLocalImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _avatarFile = File(picked.path);
      });
      final bytes = await _avatarFile!.readAsBytes();
      _base64Image = base64Encode(bytes);
    }
  }

  void _guardarCambios() async {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<ClienteProvider>();
      final prefs = UserPreferences();

      final clienteActualizado = {
        "id": prefs.clienteId,
        "username": _usernameCtrl.text,
        "nombre": _nombreCtrl.text,
        "email": _emailCtrl.text,
        "telefono": int.tryParse(_telefonoCtrl.text) ?? 0,
        "estado": provider.cliente!.estado,
        "role": provider.cliente!.role,
        "alergenos": _alergenosCtrl.text,
        "direccion": _direccionCtrl.text,
        "observacion": _observacionCtrl.text,
        "imagen": _base64Image ?? ""
      };

      await provider.actualizarCliente(clienteActualizado);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Perfil actualizado correctamente")),
      );
      Navigator.pop(context);
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
          "Editar Perfil",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: _guardarCambios,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Avatar
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: primary.withOpacity(0.2),
                        backgroundImage: _avatarFile != null
                            ? FileImage(_avatarFile!)
                            : (_base64Image != null && _base64Image!.isNotEmpty
                                ? MemoryImage(base64Decode(_base64Image!))
                                : null),
                        child: (_avatarFile == null && (_base64Image == null || _base64Image!.isEmpty))
                            ? const Icon(Icons.person, size: 60, color: primary)
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _pickLocalImage,
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: primary,
                          child: const Icon(Icons.camera_alt, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Campos usando CustomTextField
                CustomTextField(controller: _usernameCtrl, label: "Username", icon: Icons.account_circle),
                CustomTextField(controller: _nombreCtrl, label: "Nombre", icon: Icons.person),
                CustomTextField(controller: _emailCtrl, label: "Email", icon: Icons.email),
                CustomTextField(controller: _telefonoCtrl, label: "Teléfono", icon: Icons.phone),
                CustomTextField(controller: _direccionCtrl, label: "Dirección", icon: Icons.home),
                CustomTextField(controller: _alergenosCtrl, label: "Alérgenos", icon: Icons.warning),
                CustomTextField(controller: _observacionCtrl, label: "Observación", icon: Icons.note),

                const SizedBox(height: 30),

                // Botón Guardar usando PrimaryButton
                PrimaryButton(text: "Guardar cambios", onPressed: _guardarCambios),

                const SizedBox(height: 16),

                // Botón Cambiar contraseña (puedes crear OutlinedPrimaryButton si quieres reutilizar)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: primary, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                      );
                    },
                    icon: const Icon(Icons.lock, color: primary),
                    label: const Text(
                      "Cambiar contraseña",
                      style: TextStyle(color: primary, fontSize: 16),
                    ),
                  ),
                ),

                // Espaciado dinámico para evitar que los botones queden ocultos
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
