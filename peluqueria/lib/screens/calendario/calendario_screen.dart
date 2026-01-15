import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Importaciones de tus modelos y servicios
import '../../models/servicios/servicio_model.dart';
import '../../models/horario/horario_model.dart';
import '../../services/servicio_service.dart';
import '../../services/user_preferences.dart';

class CalendarioScreen extends StatefulWidget {
  final Servicio servicio;
  const CalendarioScreen({super.key, required this.servicio});

  @override
  State<CalendarioScreen> createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> {
  final ServicioService _servicioService = ServicioService();
  final UserPreferences _prefs = UserPreferences();

  DateTime _diaEnfocado = DateTime.now();
  DateTime? _diaSeleccionado;
  List<HorarioSemanal> _horarios = [];
  Map<int, int> _plazasReales = {};
  bool _estaCargando = false;

  // Paleta de colores consistente con tu Login
  final Color naranjaLogo = const Color(0xFFFF6B00);
  final Color grisFondo = const Color(0xFFF4F7F9);
  final Color negroSuave = const Color(0xFF2D2D2D);

  @override
  void initState() {
    super.initState();
    _diaSeleccionado = _diaEnfocado;
    // Cargar datos iniciales si no es fin de semana
    if (_diaEnfocado.weekday < 6) {
      _cargarDatosDia(_diaSeleccionado!);
    }
  }

  // --- MÉTODOS DE API ---

  Future<void> _cargarDatosDia(DateTime date) async {
    setState(() => _estaCargando = true);
    final String fechaStr = DateFormat('yyyy-MM-dd').format(date);

    try {
      final horarios = await _servicioService.buscarHorariosPorDiaYServicio(
        _getDiaBackend(date),
        widget.servicio.idServicio,
      );

      Map<int, int> disponibilidad = {};
      for (var h in horarios) {
        int libres = await _consultarPlazasApi(fechaStr, h.id);
        disponibilidad[h.id] = libres;
      }

      setState(() {
        _horarios = horarios;
        _plazasReales = disponibilidad;
        _estaCargando = false;
      });
    } catch (e) {
      setState(() => _estaCargando = false);
      _mostrarSnackBar("Error al cargar horarios", Colors.redAccent);
    }
  }

  Future<int> _consultarPlazasApi(String fecha, int horarioId) async {
    try {
      final token = await _prefs.token;
      final url =
          'http://10.50.183.95:8082/citas/disponible?fecha=$fecha&horarioId=$horarioId';
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) return int.parse(response.body);
    } catch (e) {
      debugPrint("Error plazas: $e");
    }
    return 0;
  }

  // MÉTODO CLAVE: Envío del JSON mapeado para Spring Boot
  Future<void> _confirmarReserva(HorarioSemanal h) async {
    final int? clienteId = await _prefs.userId;
    final String fechaStr = DateFormat('yyyy-MM-dd').format(_diaSeleccionado!);

    if (clienteId == null) {
      _mostrarSnackBar(
        "Error: No se encontró el ID del usuario",
        Colors.redAccent,
      );
      return;
    }

    // MAPEO DEL JSON (Coincide con tu @RequestBody Cita en Java)
    final Map<String, dynamic> citaRequest = {
      "fecha": fechaStr,
      "estado": true,
      "horario": {"id": h.id},
      "cliente": {"id": clienteId},
    };

    setState(() => _estaCargando = true);

    try {
      final token = await _prefs.token;
      final response = await http.post(
        Uri.parse('http://10.50.183.95:8082/citas/reservar'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(citaRequest),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        _mostrarSnackBar("¡Cita reservada con éxito!", Colors.green);
        if (mounted) Navigator.pop(context, true);
        ;
      } else {
        _mostrarSnackBar("No se pudo realizar la reserva", Colors.orange);
      }
    } catch (e) {
      _mostrarSnackBar("Error de conexión con el servidor", Colors.redAccent);
    } finally {
      if (mounted) setState(() => _estaCargando = false);
    }
  }

  String _getDiaBackend(DateTime date) {
    List<String> dias = [
      "LUNES",
      "MARTES",
      "MIERCOLES",
      "JUEVES",
      "VIERNES",
      "SABADO",
      "DOMINGO",
    ];
    return dias[date.weekday - 1];
  }

  void _mostrarSnackBar(String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mensaje,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // --- DISEÑO DE INTERFAZ ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grisFondo,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: naranjaLogo,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SECCIÓN TÍTULO Y CALENDARIO (FONDO BLANCO)
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(25, 10, 25, 15),
                  child: Text(
                    widget.servicio.nombre.toUpperCase(),
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: negroSuave,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                TableCalendar(
                  locale: 'es_ES',
                  firstDay: DateTime.now(),
                  lastDay: DateTime.now().add(const Duration(days: 90)),
                  focusedDay: _diaEnfocado,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  calendarFormat: CalendarFormat.month,
                  headerStyle: const HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: false,
                    titleTextStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  selectedDayPredicate: (day) =>
                      isSameDay(_diaSeleccionado, day),
                  enabledDayPredicate: (day) => day.weekday < 6,
                  calendarStyle: CalendarStyle(
                    weekendTextStyle: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: naranjaLogo,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: naranjaLogo.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: TextStyle(
                      color: naranjaLogo,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onDaySelected: (sel, foc) {
                    setState(() {
                      _diaSeleccionado = sel;
                      _diaEnfocado = foc;
                    });
                    _cargarDatosDia(sel);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.fromLTRB(25, 25, 25, 10),
            child: Text(
              "HORARIOS DISPONIBLES",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1.1,
              ),
            ),
          ),

          Expanded(
            child: _estaCargando
                ? Center(child: CircularProgressIndicator(color: naranjaLogo))
                : _buildListaHorarios(),
          ),
        ],
      ),
    );
  }

  Widget _buildListaHorarios() {
    if (_horarios.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 50,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 10),
            const Text(
              "No hay turnos disponibles",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _horarios.length,
      itemBuilder: (context, i) {
        final h = _horarios[i];
        final libres = _plazasReales[h.id] ?? 0;
        return _buildCardHorario(h, libres);
      },
    );
  }

  Widget _buildCardHorario(HorarioSemanal h, int libres) {
    bool disponible = libres > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    h.horaInicio.substring(0, 5),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(
                        disponible ? Icons.check_circle : Icons.error_outline,
                        size: 14,
                        color: disponible
                            ? (libres == 1 ? Colors.orange : Colors.green)
                            : Colors.red,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        libres == 1 ? "1 cita libre" : "$libres citas libres",
                        style: TextStyle(
                          fontSize: 13,
                          color: disponible
                              ? (libres == 1
                                    ? Colors.orange[800]
                                    : Colors.green[700])
                              : Colors.red[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: disponible ? () => _confirmarReserva(h) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: naranjaLogo,
                disabledBackgroundColor: Colors.grey[200],
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: Text(
                disponible ? "RESERVAR" : "LLENO",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
