import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DetalleCitaScreen extends StatefulWidget {
  final dynamic cita;
  const DetalleCitaScreen({super.key, required this.cita});

  @override
  State<DetalleCitaScreen> createState() => _DetalleCitaScreenState();
}

class _DetalleCitaScreenState extends State<DetalleCitaScreen> {
  final _comentarioController = TextEditingController();
  int _calificacion = 0;

  // Variable para almacenar la imagen seleccionada
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // Colores corporativos BERNAT
  final Color naranjaLogo = const Color(0xFFFF6B00);
  final Color negroSuave = const Color(0xFF2D2D2D);

  // Método para seleccionar imagen (Cámara o Galería)
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Error al seleccionar imagen: $e");
    }
  }

  // Menú inferior para elegir origen de la foto
  void _showImageSourceOptions() {
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
                "SELECCIONAR ORIGEN",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.camera_alt, color: naranjaLogo),
                title: const Text("Usar Cámara"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: naranjaLogo),
                title: const Text("Elegir de Galería"),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: negroSuave, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "DETALLE DE LA CITA",
          style: TextStyle(
            color: negroSuave,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      // SafeArea protege el contenido de notches y barras de navegación del móvil
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(25, 10, 25, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Información de la reserva"),
              const SizedBox(height: 15),
              _buildReadOnlyField(
                "FECHA",
                widget.cita['fecha'],
                Icons.calendar_today,
              ),
              const SizedBox(height: 15),
              _buildReadOnlyField(
                "HORA",
                "${widget.cita['horario']['horaInicio'].substring(0, 5)} h",
                Icons.access_time,
              ),

              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 20),

              _buildSectionTitle("Tu experiencia en Bernat"),
              const SizedBox(height: 20),

              // 1. Estrellas
              _buildStarRating(),

              const SizedBox(height: 25),

              // 2. Comentario
              const Text(
                "COMENTARIO",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
              _buildComentarioField(),

              const SizedBox(height: 25),

              // 3. Foto
              const Text(
                "FOTO DEL RESULTADO",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
              _buildFotoSelector(),

              const SizedBox(height: 40),

              // 4. Botón Guardar
              _buildBotonGuardar(),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS DE APOYO ---

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: negroSuave,
        fontSize: 18,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  color: negroSuave,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < _calificacion ? Icons.star : Icons.star_border,
            color: naranjaLogo,
            size: 40,
          ),
          onPressed: () => setState(() => _calificacion = index + 1),
        );
      }),
    );
  }

  Widget _buildComentarioField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: _comentarioController,
        maxLines: 3,
        decoration: const InputDecoration(
          hintText: "¿Qué te pareció el servicio?",
          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(15),
        ),
      ),
    );
  }

  Widget _buildFotoSelector() {
    return GestureDetector(
      onTap: _showImageSourceOptions,
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.grey.shade300,
            style: BorderStyle.solid,
          ),
        ),
        child: _imageFile != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.file(_imageFile!, fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_outlined, color: naranjaLogo, size: 40),
                  const SizedBox(height: 8),
                  const Text(
                    "Tocar para añadir foto",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
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
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          // Lógica para enviar datos
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Valoración guardada (Simulación)")),
          );
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: const Text(
          "GUARDAR VALORACIÓN",
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
