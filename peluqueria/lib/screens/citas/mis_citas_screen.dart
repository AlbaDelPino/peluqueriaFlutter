import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/user_preferences.dart';
import 'detalle_cita_screen.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class MisCitasScreen extends StatefulWidget {
  const MisCitasScreen({super.key});

  @override
  State<MisCitasScreen> createState() => _MisCitasScreenState();
}

class _MisCitasScreenState extends State<MisCitasScreen> {
  final UserPreferences _prefs = UserPreferences();
  List<dynamic> _citas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCitas();
  }

  Future<void> _fetchCitas() async {
    final int? clienteId = await _prefs.userId;
    final String? token = await _prefs.token;

    try {
      final response = await http.get(
        // Asegúrate de que esta ruta existe en tu CitaController de Spring
        Uri.parse('http://10.50.183.95:8082/citas/cliente/$clienteId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _citas = json.decode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Mis Reservas",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFFF6B00),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF6B00)),
            )
          : _citas.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: _citas.length,
              itemBuilder: (context, index) {
                final cita = _citas[index];
                return _buildCitaCard(cita);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 10),
          const Text(
            "No tienes citas programadas",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildCitaCard(dynamic cita) {
    // 1. Convertimos el string "2026-01-05" a un objeto DateTime
    DateTime fechaParsed = DateTime.parse(cita['fecha']);

    // 2. Definimos el formato (EEEE: día semana, d: número, MMMM: mes)
    // 'es' para español.
    // Nota: Debes inicializar los datos locales (ver más abajo)
    String fechaFormateada = DateFormat(
      "EEEE d 'de' MMMM",
      'es',
    ).format(fechaParsed);

    // 3. Capitalizar la primera letra (opcional)
    fechaFormateada =
        fechaFormateada[0].toUpperCase() + fechaFormateada.substring(1);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 4,
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetalleCitaScreen(cita: cita),
            ),
          );
        },
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.content_cut, color: Color(0xFFFF6B00)),
        ),
        title: Text(
          fechaFormateada, // <--- Aquí usamos la fecha nueva
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Text("Hora: ${cita['horario']['horaInicio'].substring(0, 5)} h"),
            const SizedBox(height: 5),
            _buildStatusBadge(cita['estado']),
          ],
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(dynamic estado) {
    // Si tu estado es booleano o String, ajusta esta lógica
    bool activo = estado == true || estado == "true";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: activo
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        activo ? "CONFIRMADA" : "CANCELADA",
        style: TextStyle(
          color: activo ? Colors.green : Colors.red,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
