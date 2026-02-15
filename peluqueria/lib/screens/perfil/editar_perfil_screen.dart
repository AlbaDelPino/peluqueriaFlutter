import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/usuario/cliente_model.dart';
import '../../services/user_preferences.dart';
import '../../config/api_config.dart';
import '../../services/auth_service.dart';
import 'package:peluqueria/widget/texto_automatico.dart';
import 'package:translator/translator.dart';
import 'package:peluqueria/config/traducciones.dart'; // <--- ESTO ARREGLA EL ERROR

class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _prefs = UserPreferences();
  final _authService = AuthService(); // Servicio centralizado
  ClienteModel? cliente;

  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _telefonoCtrl = TextEditingController();
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
              const TextoAutomatico(
                "CAMBIAR FOTO DE PERFIL",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.camera_alt, color: naranjaLogo),
                title: const TextoAutomatico("Tomar foto"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: naranjaLogo),
                title: const TextoAutomatico("Elegir de galería"),
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
   
      setState(() => _cargando = true);
     final perfil = await _authService.getProfile();
      if (perfil != null) {
          setState(() {
            cliente = perfil;
            _nombreCtrl.text = cliente?.nombre ?? '';
            _emailCtrl.text = cliente?.email ?? '';
            _telefonoCtrl.text = cliente?.telefono?.toString() ?? '';
            _alergenosCtrl.text = cliente?.alergenos ?? '';
            _base64Image = cliente?.imagen;
          });
        } else {
          _mostrarMsg("Error cargando perfil", Colors.red);
        }
        if (mounted) setState(() => _cargando = false);
  
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _enviando = true);

    try {
      final String passActual = await _prefs.passwordSegura;
      final int idUsuario = await _prefs.userId;

      // Preparamos el mapa de datos para el servicio
      final Map<String, dynamic> datosActualizados = {
        "id": idUsuario,
        "username": cliente?.username,
        "nombre": _nombreCtrl.text.trim(),
        "email": _emailCtrl.text.trim(),
        "telefono": int.tryParse(_telefonoCtrl.text.trim()) ?? 0,
        
        "imagen": _base64Image ?? "",
        "contrasenya": passActual,
        "role": cliente?.role,
        "estado": cliente?.estado,
        "alergenos": _alergenosCtrl.text.trim(),
        "observacion": cliente?.observacion,
      };

      final exito = await _authService.updateProfile(datosActualizados);

      if (exito) {
        await _prefs.actualizarPerfilLocal(
          nombre: _nombreCtrl.text.trim(),
          imagen: _base64Image ?? "",
          email: _emailCtrl.text.trim(),
          telefono: _telefonoCtrl.text.trim(),
        );

        if (mounted) {
          _mostrarMsg("✅ Perfil actualizado", Colors.green);
          Navigator.pop(context, true);
        }
      } else {
        _mostrarMsg("Error al actualizar perfil", Colors.red);
      }
    } catch (e) {
      _mostrarMsg("Error de conexión", Colors.red);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  void _mostrarMsg(String t, Color c) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: TextoAutomatico(t), backgroundColor: c));
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
        title: const TextoAutomatico(
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
                        const TextoAutomatico("Nombre completo"),
                        Icons.person_outline,
                      ),
                      _buildInput(
                        _emailCtrl,
                        const TextoAutomatico("Correo electrónico"),
                        Icons.mail_outline,
                        k: TextInputType.emailAddress,
                      ),
                      _buildInput(
                        _telefonoCtrl,
                        const TextoAutomatico("Teléfono móvil"),
                        Icons.phone_iphone_rounded,
                        k: TextInputType.phone,
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
    Widget labelWidget, // <--- Ahora acepta el Widget TextoAutomatico directamente
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
            // USAMOS 'label' porque acepta el widget que le pasamos
            label: labelWidget, 
            prefixIcon: Icon(i, color: enabled ? naranjaLogo : Colors.grey),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 20,
            ),
          ),
          validator: (v) => (enabled && (v == null || v.isEmpty))
              ? "Campo obligatorio".tr(context) // El validador siempre devuelve String
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
        child: const TextoAutomatico(
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
