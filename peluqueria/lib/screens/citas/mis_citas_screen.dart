import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/user_preferences.dart';
import 'detalle_cita_screen.dart';
import 'package:intl/intl.dart';
import '../../config/api_config.dart';

class MisCitasScreen extends StatefulWidget {
  const MisCitasScreen({super.key});

  @override
  State<MisCitasScreen> createState() => _MisCitasScreenState();
}

class _MisCitasScreenState extends State<MisCitasScreen> {
  final UserPreferences _prefs = UserPreferences();
  List<dynamic> _citas = [];
  bool _isLoading = true;
  final Color naranjaBernat = const Color(0xFFFF6B00);

  @override
  void initState() {
    super.initState();
    _fetchCitas();
  }

  Future<void> _fetchCitas() async {
    final int clienteId = await _prefs.userId;
    final String token = await _prefs.token;

    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getCitasByCliente(clienteId)),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _citas = json.decode(response.body);
          // Ordenar por fecha descendente (más recientes primero)
          _citas.sort((a, b) => b['fecha'].compareTo(a['fecha']));
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Error fetching citas: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco para toda la pantalla
      appBar: AppBar(
        title: const Text(
          "Mis Citas",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: naranjaBernat, // Naranja Bernat
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // Flecha de retorno blanca
      ),
      body: RefreshIndicator(
        onRefresh: _fetchCitas,
        color: naranjaBernat,
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: naranjaBernat))
            : _citas.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                itemCount: _citas.length,
                itemBuilder: (context, index) =>
                    _buildModernCitaCard(_citas[index]),
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_month_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 20),
          Text(
            "No tienes citas programadas",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernCitaCard(dynamic cita) {
    // Parsing de fecha y hora desde el backend
    DateTime fechaParsed = DateTime.parse(cita['fecha']);
    String diaSemana = DateFormat(
      "EEEE",
      'es',
    ).format(fechaParsed).toUpperCase();
    String diaMes = DateFormat("d 'de' MMMM", 'es').format(fechaParsed);

    // La hora viene del objeto cita directamente como LocalTime (HH:mm:ss)
    String hora = cita['horaInicio'].toString().substring(0, 5);

    // Acceso correcto al servicio: cita -> horario -> servicio -> nombre
    String nombreServicio = "Servicio";
    if (cita['horario'] != null && cita['horario']['servicio'] != null) {
      nombreServicio = cita['horario']['servicio']['nombre'];
    }

    String estado = cita['estado'] ?? "CONFIRMADO";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 6, color: _getStatusColor(estado)),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    // Si regresamos de la pantalla de detalle, refrescamos por si se canceló la cita
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetalleCitaScreen(cita: cita),
                      ),
                    );
                    if (result == true) _fetchCitas();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              diaSemana,
                              style: TextStyle(
                                color: naranjaBernat,
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                                letterSpacing: 1.1,
                              ),
                            ),
                            _buildStatusBadge(estado),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          diaMes,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3436),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              "$hora h",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 15),
                            const Icon(
                              Icons.content_cut_rounded,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                nombreServicio,
                                style: const TextStyle(color: Colors.black87),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String estado) {
    switch (estado) {
      case "CONFIRMADO":
        return Colors.green;
      case "COMPLETADO":
        return Colors.blue;
      case "CANCELADO":
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStatusBadge(String estado) {
    Color color = _getStatusColor(estado);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        estado,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
