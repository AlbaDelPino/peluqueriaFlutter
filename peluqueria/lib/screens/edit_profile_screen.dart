import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/cliente_provider.dart';
import '../shared_prefs/user_preferences.dart';

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

      debugPrint("➡️ Body enviado: ${json.encode(clienteActualizado)}");

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
      appBar: AppBar(
        backgroundColor: primary,
        title: const Text("Editar Perfil", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: _guardarCambios,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
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
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _pickLocalImage,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: primary,
                        child: const Icon(Icons.camera_alt, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(controller: _usernameCtrl, decoration: const InputDecoration(labelText: "Username")),
              TextFormField(controller: _nombreCtrl, decoration: const InputDecoration(labelText: "Nombre")),
              TextFormField(controller: _emailCtrl, decoration: const InputDecoration(labelText: "Email")),
              TextFormField(controller: _telefonoCtrl, decoration: const InputDecoration(labelText: "Teléfono")),
              TextFormField(controller: _direccionCtrl, decoration: const InputDecoration(labelText: "Dirección")),
              TextFormField(controller: _alergenosCtrl, decoration: const InputDecoration(labelText: "Alérgenos")),
              TextFormField(controller: _observacionCtrl, decoration: const InputDecoration(labelText: "Observación")),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: primary),
                onPressed: _guardarCambios,
                child: const Text("Guardar cambios", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
