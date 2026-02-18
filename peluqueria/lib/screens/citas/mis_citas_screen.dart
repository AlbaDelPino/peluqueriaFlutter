import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/user_preferences.dart';
import 'detalle_cita_screen.dart';
import '../Valoracion/valoracion_cita_screen.dart';
import 'package:intl/intl.dart';
import '../../config/api_config.dart';
import 'package:peluqueria/widget/texto_automatico.dart';

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
  final Color negroSuave = const Color(0xFF2D2D2D);

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
          _citas.sort((a, b) => b['fecha'].compareTo(a['fecha']));
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: TextoAutomatico("MIS CITAS", 
          style: TextStyle(color: negroSuave, fontWeight: FontWeight.w900, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: negroSuave),
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
                itemBuilder: (context, index) => _buildModernCitaCard(_citas[index]),
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_month_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          const TextoAutomatico("No tienes citas programadas", 
            style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildModernCitaCard(dynamic cita) {
    DateTime fechaParsed = DateTime.parse(cita['fecha']);
    String diaSemana = DateFormat("EEEE", 'es').format(fechaParsed).toUpperCase();
    String diaMes = DateFormat("d 'de' MMMM", 'es').format(fechaParsed);
    String hora = cita['horaInicio'].toString().substring(0, 5);
    String estado = cita['estado'] ?? "CONFIRMADO";
    
    // Lógica para saber si ya se ha valorado (ajusta 'valoracion' según tu JSON)
    bool yaValorada = cita['valoracion'] != null; 

    String nombreServicio = "Servicio";
    if (cita['horario'] != null && cita['horario']['servicio'] != null) {
      nombreServicio = cita['horario']['servicio']['nombre'];
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 6, color: _getStatusColor(estado)),
              Expanded(
                child: InkWell(
                  // COMPORTAMIENTO ORIGINAL: Click abre información de la cita
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DetalleCitaScreen(cita: cita)),
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
                            TextoAutomatico(diaSemana, 
                              style: TextStyle(color: naranjaBernat, fontWeight: FontWeight.w900, fontSize: 11)),
                            _buildStatusBadge(estado),
                          ],
                        ),
                        const SizedBox(height: 4),
                        TextoAutomatico(diaMes, 
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 16, color: Colors.grey),
                            const SizedBox(width: 5),
                            TextoAutomatico("$hora h", style: const TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(width: 15),
                            const Icon(Icons.content_cut_rounded, size: 16, color: Colors.grey),
                            const SizedBox(width: 5),
                            Expanded(child: TextoAutomatico(nombreServicio, overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                        
                        // LÓGICA DE VALORACIÓN: Solo si está COMPLETADO y NO valorada
                        // ... dentro de _buildModernCitaCard ...
// Buscamos la lógica de valoración:
              if (estado == "COMPLETADO" && cita['valoracion'] == null) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () async {
                      final res = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ValoracionCitaScreen(cita: cita)),
                      );
                      if (res == true) _fetchCitas(); // Refresca para ocultar el botón tras valorar
                    },
                    icon: const Icon(Icons.star, color: Colors.orangeAccent, size: 18),
                    label: const TextoAutomatico("VALORAR SERVICIO", 
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ],
                        
                        // Si ya está valorada, puedes mostrar un pequeño indicador opcional
                        if (yaValorada) ...[
                           const SizedBox(height: 8),
                           const TextoAutomatico("✓ Cita valorada", 
                            style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                        ]
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
      case "CONFIRMADO": return Colors.green;
      case "COMPLETADO": return Colors.blue;
      case "CANCELADO": return Colors.redAccent;
      default: return Colors.grey;
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
      child: TextoAutomatico(estado, 
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900)),
    );
  }
}