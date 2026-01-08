import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/usuario/cliente_model.dart';
import '../../services/user_preferences.dart';
import '../../main.dart'; // Asegúrate de importar donde definiste el routeObserver

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

// Usamos RouteAware para detectar el regreso a la pantalla
class _PerfilScreenState extends State<PerfilScreen> with RouteAware {
  ClienteModel? cliente;
  bool _isLoading = true;
  final Color naranjaLogo = const Color(0xFFFF6B00);

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Registramos esta pantalla en el observador de rutas
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this); // Limpiamos al salir
    super.dispose();
  }

  // ESTO SE EJECUTA CUANDO VUELVES DE EDITAR (AL HACER POP)
  @override
  void didPopNext() {
    _fetchUserProfile(); // Refresco automático al regresar
  }

  Future<void> _fetchUserProfile() async {
    final prefs = UserPreferences();

    // Si ya tenemos datos, no mostramos el loader para que no parpadee
    if (cliente == null) setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('http://10.103.246.95:8082/api/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${prefs.token}',
        },
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            cliente = ClienteModel.fromJson(jsonDecode(response.body));
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "MI PERFIL",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: naranjaLogo,
        centerTitle: true,
      ),
      body: _isLoading && cliente == null
          ? Center(child: CircularProgressIndicator(color: naranjaLogo))
          : (cliente == null)
          ? const Center(child: Text("Error al cargar datos"))
          : RefreshIndicator(
              onRefresh: _fetchUserProfile,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildHeader(),
                    _buildInfoItem(Icons.person, "Usuario", cliente!.username),
                    _buildInfoItem(Icons.badge, "Nombre", cliente!.nombre),
                    _buildInfoItem(Icons.email, "Email", cliente!.email),
                    _buildInfoItem(
                      Icons.phone,
                      "Teléfono",
                      cliente!.telefono.toString(),
                    ),
                    _buildInfoItem(
                      Icons.location_on,
                      "Dirección",
                      cliente!.direccion,
                    ),
                    const SizedBox(height: 20),
                    _buildLogoutButton(),
                  ],
                ),
              ),
            ),
    );
  }

  // ... (Tus métodos _buildHeader, _buildInfoItem, _buildLogoutButton aquí)
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: naranjaLogo,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 55,
            backgroundColor: Colors.white,
            backgroundImage: cliente!.imagen.isNotEmpty
                ? MemoryImage(base64Decode(cliente!.imagen))
                : null,
            child: cliente!.imagen.isEmpty
                ? Icon(Icons.person, size: 60, color: naranjaLogo)
                : null,
          ),
          const SizedBox(height: 15),
          Text(
            cliente!.nombre.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(icon, color: naranjaLogo),
        title: Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: OutlinedButton(
        onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
        child: const Text("CERRAR SESIÓN"),
      ),
    );
  }
}
