import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../shared_prefs/user_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static const String routeName = 'profile';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final prefs = UserPreferences();

  // 🔹 Avatares prediseñados con carpeta en minúscula
  final List<String> assetAvatars = [
    "assets/avatar/avatar1.png",
    "assets/avatar/avatar2.png",
    "assets/avatar/avatar3.png",
    "assets/avatar/avatar4.png",
  ];

  String? _avatarPath;

  @override
  void initState() {
    super.initState();
    // Avatar por defecto si no hay guardado
    _avatarPath = prefs.avatarPath.isEmpty ? "assets/avatar/avatar1.png" : prefs.avatarPath;
    prefs.lastPage = ProfileScreen.routeName;
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _avatarPath = picked.path;
        prefs.avatarPath = picked.path;
      });
    }
  }

  void _selectAssetAvatar(String path) {
    setState(() {
      _avatarPath = path;
      prefs.avatarPath = path;
    });
  }

  void _logout(BuildContext context) {
    // 👇 Ahora sí navega al Login, que está en la ruta '/'
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  void _editProfile(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función de edición pendiente')),
    );
  }

  // ---------------------------
  // Cuestionario (cabello y sensibilidades)
  // ---------------------------
  void _openQuestionnaire(BuildContext context) {
    final List<String> observacionesCabello = [
      "Cabello teñido",
      "Cabello con mechas",
      "Cabello rizado",
      "Cabello liso",
      "Cabello ondulado",
      "Cabello graso",
      "Cabello seco",
      "Sensibilidad cuero cabelludo",
      "Uso frecuente de plancha/secador",
    ];

    final List<String> sensibilidades = [
      "Reacción a tintes",
      "Reacción a keratina",
      "Reacción a permanentes",
      "Reacción a productos con alcohol",
      "Reacción a siliconas",
    ];

    final Map<String, bool> seleccionObservaciones = {
      for (var item in observacionesCabello) item: false,
    };
    final Map<String, bool> seleccionSensibilidades = {
      for (var item in sensibilidades) item: false,
    };

    if (prefs.caracteristicasCabello.isNotEmpty) {
      for (final v in prefs.caracteristicasCabello.split(", ").where((e) => e.isNotEmpty)) {
        if (seleccionObservaciones.containsKey(v)) seleccionObservaciones[v] = true;
      }
    }
    if (prefs.sensibilidades.isNotEmpty) {
      for (final v in prefs.sensibilidades.split(", ").where((e) => e.isNotEmpty)) {
        if (seleccionSensibilidades.containsKey(v)) seleccionSensibilidades[v] = true;
      }
    }

    final TextEditingController observacionesExtraController =
        TextEditingController(text: prefs.observacionesExtra);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Cuestionario de perfil"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Características del cabello:"),
                    ...observacionesCabello.map((item) {
                      return CheckboxListTile(
                        title: Text(item),
                        value: seleccionObservaciones[item],
                        onChanged: (value) {
                          setState(() {
                            seleccionObservaciones[item] = value ?? false;
                          });
                        },
                      );
                    }).toList(),
                    const Divider(),
                    const Text("Sensibilidades / Reacciones:"),
                    ...sensibilidades.map((item) {
                      return CheckboxListTile(
                        title: Text(item),
                        value: seleccionSensibilidades[item],
                        onChanged: (value) {
                          setState(() {
                            seleccionSensibilidades[item] = value ?? false;
                          });
                        },
                      );
                    }).toList(),
                    const Divider(),
                    TextField(
                      controller: observacionesExtraController,
                      decoration: const InputDecoration(
                        labelText: "Observaciones adicionales",
                        hintText: "Introduce observaciones extra",
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: () {
                    final seleccionCabelloFinal = seleccionObservaciones.entries
                        .where((e) => e.value)
                        .map((e) => e.key)
                        .join(", ");
                    final seleccionSensFinal = seleccionSensibilidades.entries
                        .where((e) => e.value)
                        .map((e) => e.key)
                        .join(", ");

                    prefs.caracteristicasCabello = seleccionCabelloFinal;
                    prefs.sensibilidades = seleccionSensFinal;
                    prefs.observacionesExtra = observacionesExtraController.text;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Guardado:\nCabello: ${prefs.caracteristicasCabello.isEmpty ? 'Ninguno' : prefs.caracteristicasCabello}\n"
                          "Sensibilidades: ${prefs.sensibilidades.isEmpty ? 'Ninguna' : prefs.sensibilidades}\n"
                          "Observaciones extra: ${prefs.observacionesExtra}",
                        ),
                      ),
                    );
                    Navigator.pop(context);
                    setState(() {}); // refrescar la pantalla
                  },
                  child: const Text("Guardar"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ---------------------------
  // Opciones de avatar (overlay)
  // ---------------------------
  void _showAvatarOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Elegir de galería"),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text("Seleccionar avatar prediseñado"),
                onTap: () {
                  Navigator.pop(context);
                  _showAssetAvatars(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAssetAvatars(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Selecciona un avatar"),
        content: SizedBox(
          height: 300, // 👈 más altura para que se vean bien
          width: double.maxFinite, // 👈 permite que ocupe todo el ancho
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: assetAvatars.length,
            itemBuilder: (context, index) {
              final path = assetAvatars[index];
              return GestureDetector(
                onTap: () {
                  _selectAssetAvatar(path);
                  Navigator.pop(context);
                },
                child: CircleAvatar(
                  backgroundImage: AssetImage(path),
                  radius: 40,
                ),
              );
            },
          ),
        ),
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFFFF8B00);

    return Scaffold(
  
     appBar: AppBar(
  backgroundColor: primary,
  title: const Text(
    "Perfil",
    style: TextStyle(color: Colors.white), // 👈 título en blanco
  ),
  actions: [
    IconButton(
      icon: const Icon(Icons.edit, color: Colors.white), // 👈 icono en blanco
      onPressed: () => _editProfile(context),
      tooltip: "Editar datos",
    ),
  ],
),

      body: SingleChildScrollView(
  child: Column(
    children: [
      const SizedBox(height: 12),

      // Avatar
      Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: primary,
            backgroundImage: _avatarPath != null && _avatarPath!.isNotEmpty
                ? (_avatarPath!.startsWith("assets/")
                    ? AssetImage(_avatarPath!)
                    : Image.file(File(_avatarPath!)).image)
                : const AssetImage("assets/avatar/avatar1.png"),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.camera_alt, color: Colors.black87),
                onPressed: () => _showAvatarOptions(context),
                tooltip: "Cambiar avatar",
              ),
            ),
          ),
        ],
      ),

      const SizedBox(height: 12),

      // Botón cuestionario
      TextButton.icon(
        onPressed: () => _openQuestionnaire(context),
        icon: const Icon(Icons.assignment),
        label: const Text("Cuestionario"),
      ),

      const Divider(height: 15),

      // Lista de info
      ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          _infoItem("Nombre del usuario", prefs.nombre.isEmpty ? "Sin definir" : prefs.nombre),
          _infoItem("Contraseña", "********"),
          _infoItem("Email", "usuario@ejemplo.com"),
          _infoItem("Nombre", prefs.nombre.isEmpty ? "Sin definir" : prefs.nombre),
          _infoItem("Alérgenos", prefs.sensibilidades),
          _infoItem("Dirección", prefs.direccion.isEmpty ? "Sin definir" : prefs.direccion),
          _infoItem("Observaciones", prefs.observacionesExtra),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar sesión'),
          ),
        ],
      ),
    ],
  ),
),

    );
  }

  Widget _infoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(value.isEmpty ? "Sin definir" : value,
              style: const TextStyle(fontSize: 15, color: Colors.black87)),
          const Divider(height: 24),
        ],
      ),
    );
  }
}
