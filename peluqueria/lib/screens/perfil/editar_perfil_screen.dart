import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../models/usuario/cliente_model.dart';
import '../../services/user_preferences.dart';

class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final prefs = UserPreferences();
  ClienteModel? cliente;

  late TextEditingController _nombreCtrl,
      _emailCtrl,
      _telefonoCtrl,
      _direccionCtrl,
      _alergenosCtrl;
  String? _base64Image;
  File? _avatarFile;
  bool _cargando = true, _enviando = false;

  final Color naranjaLogo = const Color(0xFFFF6B00);
  final Color negroSuave = const Color(0xFF2D2D2D);

  @override
  void initState() {
    super.initState();
    _fetchDatosUsuario();
  }

  Future<void> _fetchDatosUsuario() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.103.246.95:8082/api/auth/me'),
        headers: {'Authorization': 'Bearer ${prefs.token}'},
      );

      if (response.statusCode == 200) {
        cliente = ClienteModel.fromJson(jsonDecode(response.body));
        _nombreCtrl = TextEditingController(text: cliente!.nombre);
        _emailCtrl = TextEditingController(text: cliente!.email);
        _telefonoCtrl = TextEditingController(
          text: cliente!.telefono.toString(),
        );
        _direccionCtrl = TextEditingController(text: cliente!.direccion);
        _alergenosCtrl = TextEditingController(text: cliente!.alergenos ?? '');
        _base64Image = cliente!.imagen;
        setState(() => _cargando = false);
      }
    } catch (e) {
      _mostrarMsg("Error de conexión", Colors.red);
    }
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _enviando = true);

    try {
      final Map<String, dynamic> body = {
        "id": cliente!.id,
        "username": cliente!.username,
        "nombre": _nombreCtrl.text.trim(),
        "email": _emailCtrl.text.trim(),
        "telefono": int.tryParse(_telefonoCtrl.text.trim()) ?? 0,
        "direccion": _direccionCtrl.text.trim(),
        "imagen": _base64Image ?? "",
        "contrasenya": prefs.passwordSegura, // Recuperada de prefs
        "role": cliente!.role,
        "estado": cliente!.estado,
        "alergenos": _alergenosCtrl.text.trim(),
        "observacion": cliente!.observacion,
      };

      final response = await http.put(
        Uri.parse('http://10.103.246.95:8082/clientes/${cliente!.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${prefs.token}',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // 🔥 ACTUALIZAMOS TODO EN USER_PREFERENCES
        await prefs.actualizarPerfilLocal(
          nombre: _nombreCtrl.text.trim(),
          imagen: _base64Image ?? "",
          email: _emailCtrl.text.trim(),
          telefono: _telefonoCtrl.text.trim(),
          direccion: _direccionCtrl.text.trim(),
        );

        if (mounted) {
          _mostrarMsg("✅ Perfil actualizado correctamente", Colors.green);
          Navigator.pop(context, true);
        }
      } else {
        _mostrarMsg("Error al guardar: ${response.statusCode}", Colors.red);
      }
    } catch (e) {
      _mostrarMsg("Error de red", Colors.red);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  void _mostrarMsg(String t, Color c) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(t), backgroundColor: c));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: negroSuave),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "EDITAR PERFIL",
          style: TextStyle(
            color: negroSuave,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildAvatarPicker(),
                    const SizedBox(height: 40),
                    _buildInput(
                      _nombreCtrl,
                      "Nombre completo",
                      Icons.person_outline,
                    ),
                    _buildInput(
                      _emailCtrl,
                      "Correo electrónico",
                      Icons.mail_outline,
                      k: TextInputType.emailAddress,
                    ),
                    _buildInput(
                      _telefonoCtrl,
                      "Teléfono móvil",
                      Icons.phone_iphone_rounded,
                      k: TextInputType.phone,
                    ),
                    _buildInput(
                      _direccionCtrl,
                      "Dirección",
                      Icons.location_on_outlined,
                    ),
                    _buildInput(
                      _alergenosCtrl,
                      "Alérgenos (Solo lectura)",
                      Icons.warning_amber_rounded,
                      enabled: false,
                    ),
                    const SizedBox(height: 30),
                    _enviando
                        ? CircularProgressIndicator(color: naranjaLogo)
                        : _buildBotonGuardar(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInput(
    TextEditingController c,
    String l,
    IconData i, {
    bool enabled = true,
    TextInputType k = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFFF7F7F7) : const Color(0xFFEEEEEE),
          borderRadius: BorderRadius.circular(15),
        ),
        child: TextFormField(
          controller: c,
          enabled: enabled,
          keyboardType: k,
          decoration: InputDecoration(
            labelText: l,
            prefixIcon: Icon(i, color: enabled ? naranjaLogo : Colors.grey),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 20,
            ),
          ),
          validator: (v) => (enabled && (v == null || v.isEmpty))
              ? "Campo obligatorio"
              : null,
        ),
      ),
    );
  }

  Widget _buildBotonGuardar() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [naranjaLogo, const Color(0xFFFF8C32)],
        ),
        boxShadow: [
          BoxShadow(
            color: naranjaLogo.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _guardarCambios,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: const Text(
          "GUARDAR CAMBIOS",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarPicker() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 65,
            backgroundColor: const Color(0xFFF7F7F7),
            backgroundImage: _avatarFile != null
                ? FileImage(_avatarFile!)
                : (_base64Image != null && _base64Image!.isNotEmpty
                          ? MemoryImage(base64Decode(_base64Image!))
                          : null)
                      as ImageProvider?,
            child: _base64Image == null && _avatarFile == null
                ? Icon(
                    Icons.person,
                    size: 60,
                    color: naranjaLogo.withOpacity(0.3),
                  )
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () async {
                final p = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 40,
                );
                if (p != null) {
                  final bytes = await File(p.path).readAsBytes();
                  setState(() {
                    _avatarFile = File(p.path);
                    _base64Image = base64Encode(bytes);
                  });
                }
              },
              child: CircleAvatar(
                backgroundColor: negroSuave,
                radius: 20,
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
