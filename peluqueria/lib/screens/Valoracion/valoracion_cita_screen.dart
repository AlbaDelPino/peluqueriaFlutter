import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import '../../../config/api_config.dart';
import '../../../services/user_preferences.dart';
import 'package:peluqueria/widget/texto_automatico.dart';

class ValoracionCitaScreen extends StatefulWidget {
  final dynamic cita;
  const ValoracionCitaScreen({super.key, required this.cita});

  @override
  State<ValoracionCitaScreen> createState() => _ValoracionCitaScreenState();
}

class _ValoracionCitaScreenState extends State<ValoracionCitaScreen> {
  final TextEditingController _commentController = TextEditingController();
  final UserPreferences _prefs = UserPreferences();
  
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  int trato = 0;
  int desarrollo = 0;
  int comunicacion = 0;
  int organizacion = 0;
  int puntuacionGeneral = 0;

  bool _isSending = false;
  final Color naranjaBernat = const Color(0xFFFF6B00);

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50, 
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _enviarValoracion() async {
    if (puntuacionGeneral == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Por favor, selecciona al menos una estrella en la puntuación General"),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    setState(() => _isSending = true);
    
    final int clienteId = await _prefs.userId;
    final String token = await _prefs.token;

    String? base64String;
    if (_selectedImage != null) {
      List<int> imageBytes = await _selectedImage!.readAsBytes();
      base64String = base64Encode(imageBytes);
    }

    final Map<String, dynamic> data = {
      "comentario": _commentController.text.isEmpty ? "Sin comentario" : _commentController.text,
      "puntuacion": puntuacionGeneral,
      "trato": trato,
      "desarrollo": desarrollo,
      "comunicacion": comunicacion,
      "organizacion": organizacion,
      "imagen": base64String, 
      "cita": {"id": widget.cita['id']}
    };

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.postValoracion(clienteId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("¡Gracias por tu valoración!"), backgroundColor: Colors.green),
          );
          
          // --- REDIRECCIÓN A MIS CITAS LIMPIANDO EL HISTORIAL ---
       
      Navigator.pushNamedAndRemoveUntil(
        context, 
        '/home', // <--- Asegúrate de que esta ruta coincida con la de tu main.dart
        (route) => false, 
      );
    
        }
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const TextoAutomatico("VALORACIÓN", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildStarRow("Trato personal", trato, (v) => setState(() => trato = v)),
            _buildStarRow("Desarrollo del servicio", desarrollo, (v) => setState(() => desarrollo = v)),
            _buildStarRow("Claridad en la comunicación", comunicacion, (v) => setState(() => comunicacion = v)),
            _buildStarRow("Limpieza y organización", organizacion, (v) => setState(() => organizacion = v)),
            _buildStarRow("Puntuación General", puntuacionGeneral, (v) => setState(() => puntuacionGeneral = v)),
            
            const SizedBox(height: 20),
            
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, color: naranjaBernat, size: 40),
                          const SizedBox(height: 8),
                          const TextoAutomatico("Añadir foto del resultado", 
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
              ),
            ),
            
            const SizedBox(height: 20),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Escribe un comentario (opcional)",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: naranjaBernat),
                ),
              ),
            ),

            const SizedBox(height: 30),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20), 
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: naranjaBernat,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isSending ? null : _enviarValoracion,
                    child: _isSending 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const TextoAutomatico("ENVIAR VALORACIÓN", 
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRow(String label, int value, Function(int) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextoAutomatico(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(5, (index) {
            return IconButton(
              onPressed: () => onChanged(index + 1),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              constraints: const BoxConstraints(),
              icon: Icon(
                index < value ? Icons.star : Icons.star_border,
                color: naranjaBernat,
                size: 32,
              ),
            );
          }),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}