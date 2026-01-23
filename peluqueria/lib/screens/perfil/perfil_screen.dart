import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/usuario/cliente_model.dart';
import '../../services/user_preferences.dart';
import 'editar_perfil_screen.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final prefs = UserPreferences();
  ClienteModel? cliente;
  bool _cargando = true;

  final Color naranjaLogo = const Color(0xFFFF6B00);
  final Color negroSuave = const Color(0xFF2D2D2D);

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      // Forzamos el estado de carga al empezar
      setState(() => _cargando = true);

      final String tokenActual = await prefs.token;

      final response = await http
          .get(
            Uri.parse('http://localhost:8082/api/auth/me'),
            headers: {
              'Authorization': 'Bearer $tokenActual',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        // Mapeamos los datos al modelo
        cliente = ClienteModel.fromJson(decodedData);
      } else {
        debugPrint("Error servidor: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error de conexión en Perfil: $e");
    } finally {
      // ESTO ES LO QUE ARREGLA LA CARGA INFINITA:
      // Se ejecuta siempre, incluso si hay error o el servidor no responde.
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "MI PERFIL",
          style: TextStyle(
            color: negroSuave,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.edit_calendar_rounded, color: naranjaLogo),
            onPressed: () async {
              // Navegamos a editar y esperamos si hubo cambios
              final cambio = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditarPerfilScreen(),
                ),
              );
              if (cambio == true) {
                _cargarDatos(); // Refrescamos si se guardó algo
              }
            },
          ),
        ],
      ),
      body: _cargando
          ? Center(child: CircularProgressIndicator(color: naranjaLogo))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  _buildAvatarView(),
                  const SizedBox(height: 40),
                  _buildDato(
                    "Nombre completo",
                    cliente?.nombre ?? "No disponible",
                    Icons.person_outline,
                  ),
                  _buildDato(
                    "Correo electrónico",
                    cliente?.email ?? "No disponible",
                    Icons.mail_outline,
                  ),
                  _buildDato(
                    "Teléfono móvil",
                    cliente?.telefono?.toString() ?? "No disponible",
                    Icons.phone_iphone_rounded,
                  ),
                  _buildDato(
                    "Dirección",
                    cliente?.direccion ?? "No disponible",
                    Icons.location_on_outlined,
                  ),
                  _buildDato(
                    "Alérgenos",
                    cliente?.alergenos ?? "Ninguno",
                    Icons.warning_amber_rounded,
                  ),
                  const SizedBox(height: 30),
                  _buildBotonCerrarSesion(),
                ],
              ),
            ),
    );
  }

  // --- MANTENIENDO TU DISEÑO DE "DATO" ---
  Widget _buildDato(String label, String valor, IconData icono) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(icono, color: naranjaLogo),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  valor,
                  style: TextStyle(
                    color: negroSuave,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarView() {
    return Center(
      child: CircleAvatar(
        radius: 65,
        backgroundColor: const Color(0xFFF7F7F7),
        backgroundImage: (cliente?.imagen != null && cliente!.imagen.isNotEmpty)
            ? MemoryImage(base64Decode(cliente!.imagen))
            : null,
        child: (cliente?.imagen == null || cliente!.imagen.isEmpty)
            ? Icon(Icons.person, size: 60, color: naranjaLogo.withOpacity(0.3))
            : null,
      ),
    );
  }

  Widget _buildBotonCerrarSesion() {
    return TextButton(
      onPressed: () async {
        await prefs.logout();
        if (mounted) Navigator.pushReplacementNamed(context, 'login');
      },
      child: const Text(
        "CERRAR SESIÓN",
        style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
      ),
    );
  }
}
