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

  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _telefonoCtrl = TextEditingController();
  final TextEditingController _direccionCtrl = TextEditingController();
  final TextEditingController _alergenosCtrl = TextEditingController();

  String? _base64Image;
  File? _avatarFile;
  bool _cargando = true;
  bool _enviando = false;

  final Color naranjaLogo = const Color(0xFFFF6B00);
  final Color negroSuave = const Color(0xFF2D2D2D);

  @override
  void initState() {
    super.initState();
    _fetchDatosUsuario();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _emailCtrl.dispose();
    _telefonoCtrl.dispose();
    _direccionCtrl.dispose();
    _alergenosCtrl.dispose();
    super.dispose();
  }

  // --- LÓGICA DE IMAGEN ---

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 40, // Comprimimos para que el Base64 no sea gigante
      );

      if (pickedFile != null) {
        final File file = File(pickedFile.path);
        final List<int> imageBytes = await file.readAsBytes();

        setState(() {
          _avatarFile = file;
          _base64Image = base64Encode(imageBytes);
        });
      }
    } catch (e) {
      debugPrint("Error seleccionando imagen: $e");
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "CAMBIAR FOTO DE PERFIL",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.camera_alt, color: naranjaLogo),
                title: const Text("Tomar foto"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: naranjaLogo),
                title: const Text("Elegir de galería"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- API Y PERSISTENCIA ---

  Future<void> _fetchDatosUsuario() async {
    try {
      setState(() => _cargando = true);
      final String tokenActual = await prefs.token;

      final response = await http
          .get(
            Uri.parse('http://10.217.44.95:8082/api/auth/me'),
            headers: {'Authorization': 'Bearer $tokenActual'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        cliente = ClienteModel.fromJson(decodedData);

        _nombreCtrl.text = cliente?.nombre ?? '';
        _emailCtrl.text = cliente?.email ?? '';
        _telefonoCtrl.text = cliente?.telefono?.toString() ?? '';
        _direccionCtrl.text = cliente?.direccion ?? '';
        _alergenosCtrl.text = cliente?.alergenos ?? '';
        _base64Image = cliente?.imagen;
      }
    } catch (e) {
      _mostrarMsg("Error cargando perfil", Colors.red);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _enviando = true);

    try {
      final String tokenActual = await prefs.token;
      final String passActual = await prefs.passwordSegura;
      final int idUsuario = await prefs.userId;

      final Map<String, dynamic> body = {
        "id": idUsuario,
        "username": cliente?.username,
        "nombre": _nombreCtrl.text.trim(),
        "email": _emailCtrl.text.trim(),
        "telefono": int.tryParse(_telefonoCtrl.text.trim()) ?? 0,
        "direccion": _direccionCtrl.text.trim(),
        "imagen": _base64Image ?? "",
        "contrasenya": passActual,
        "role": cliente?.role,
        "estado": cliente?.estado,
        "alergenos": _alergenosCtrl.text.trim(),
        "observacion": cliente?.observacion,
      };

      // Nota: Cambiado a la IP de tu server, asegúrate que localhost no sea el problema
      final response = await http.put(
        Uri.parse('http://10.50.183.95:8082/clientes/$idUsuario'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $tokenActual',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await prefs.actualizarPerfilLocal(
          nombre: _nombreCtrl.text.trim(),
          imagen: _base64Image ?? "",
          email: _emailCtrl.text.trim(),
          telefono: _telefonoCtrl.text.trim(),
          direccion: _direccionCtrl.text.trim(),
        );

        if (mounted) {
          _mostrarMsg("✅ Perfil actualizado", Colors.green);
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      _mostrarMsg("Error al conectar con el servidor", Colors.red);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  void _mostrarMsg(String t, Color c) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(t), backgroundColor: c));
  }

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
        title: const Text(
          "EDITAR PERFIL",
          style: TextStyle(
            color: Color(0xFF2D2D2D),
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: _cargando
          ? Center(child: CircularProgressIndicator(color: naranjaLogo))
          : SafeArea(
              child: SingleChildScrollView(
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
            ),
    );
  }

  Widget _buildAvatarPicker() {
    ImageProvider? imageProvider;
    if (_avatarFile != null) {
      imageProvider = FileImage(_avatarFile!);
    } else if (_base64Image != null && _base64Image!.isNotEmpty) {
      try {
        imageProvider = MemoryImage(base64Decode(_base64Image!));
      } catch (e) {
        imageProvider = null;
      }
    }

    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 65,
            backgroundColor: const Color(0xFFF7F7F7),
            backgroundImage: imageProvider,
            child: imageProvider == null
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
              onTap: _showPickerOptions,
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
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _guardarCambios,
        style: ElevatedButton.styleFrom(
          backgroundColor: naranjaLogo,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
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
}
