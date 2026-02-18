import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart'; // Asegúrate de tenerlo en pubspec.yaml
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

  int trato = 5;
  int desarrollo = 5;
  int comunicacion = 5;
  int organizacion = 5;
  int puntuacionGeneral = 5;

  bool _isSending = false;
  final Color naranjaBernat = const Color(0xFFFF6B00);

  // --- LÓGICA DE SELECCIÓN DE IMAGEN ---
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50, // Reduce el peso para que el Base64 no sea gigante
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // --- LÓGICA DE ENVÍO ---
  Future<void> _enviarValoracion() async {
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
            const SnackBar(content: Text("¡Valoración guardada!"), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
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
            _buildStarRow("General", puntuacionGeneral, (v) => setState(() => puntuacionGeneral = v)),
            const SizedBox(height: 10),
            
            // --- SELECTOR DE IMAGEN VISUAL ---
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
            if (_selectedImage != null)
              TextButton(
                onPressed: () => setState(() => _selectedImage = null),
                child: const Text("Quitar foto", style: TextStyle(color: Colors.red)),
              ),
            
            const SizedBox(height: 20),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Escribe un comentario (opcional)",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
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
                  : const TextoAutomatico("ENVIAR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          children: List.generate(5, (index) {
            return IconButton(
              onPressed: () => onChanged(index + 1),
              icon: Icon(
                index < value ? Icons.star : Icons.star_border,
                color: naranjaBernat,
                size: 30,
              ),
            );
          }),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}