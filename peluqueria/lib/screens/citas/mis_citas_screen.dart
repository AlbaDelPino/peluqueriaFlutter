import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/user_preferences.dart';
import 'detalle_cita_screen.dart';
import 'package:intl/intl.dart';

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
    final int? clienteId = await _prefs.userId;
    final String? token = await _prefs.token;

    try {
      final response = await http.get(
        Uri.parse('http://10.217.44.95:8082/citas/cliente/$clienteId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _citas = json.decode(response.body);
          _citas.sort((a, b) => b['fecha'].compareTo(a['fecha']));
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
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 100.0,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: naranjaBernat,
            // Quitamos el título de aquí para que quede más limpio
            flexibleSpace: FlexibleSpaceBar(
              background: Container(color: naranjaBernat),
            ),
          ),

          _isLoading
              ? const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF6B00)),
                  ),
                )
              : _citas.isEmpty
              ? SliverFillRemaining(child: _buildEmptyState())
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildModernCitaCard(_citas[index]),
                      childCount: _citas.length,
                    ),
                  ),
                ),
        ],
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
    DateTime fechaParsed = DateTime.parse(cita['fecha']);
    String diaSemana = DateFormat(
      "EEEE",
      'es',
    ).format(fechaParsed).toUpperCase();
    String diaMes = DateFormat("d 'de' MMMM", 'es').format(fechaParsed);
    String hora = cita['horario']['horaInicio'].substring(0, 5);

    // OBTENEMOS EL NOMBRE DEL SERVICIO DESDE EL JSON ANIDADO
    // Asegúrate de que tu JSON de Spring Boot tiene: "servicio": { "nombre": "Corte de pelo" }
    String nombreServicio = cita['servicio'] != null
        ? cita['servicio']['nombre']
        : "Servicio";

    bool estaConfirmada = cita['estado'] == true || cita['estado'] == "true";

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
              Container(
                width: 5,
                color: estaConfirmada ? Colors.green : Colors.redAccent,
              ),
              Expanded(
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetalleCitaScreen(cita: cita),
                    ),
                  ),
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
                            _buildStatusBadge(cita['estado']),
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
                              size: 15,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              "$hora h",
                              style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 15),
                            const Icon(
                              Icons.content_cut_rounded,
                              size: 15,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 5),
                            // AQUÍ SE MUESTRA EL NOMBRE REAL DEL SERVICIO
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

  Widget _buildStatusBadge(dynamic estado) {
    bool activo = estado == true || estado == "true";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: activo
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        activo ? "CONFIRMADA" : "CANCELADA",
        style: TextStyle(
          color: activo ? Colors.green[700] : Colors.red[700],
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
