import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../models/servicios/servicio_model.dart';
import '../../models/horario/horario_model.dart';
import '../../services/servicio_service.dart';
import '../../services/user_preferences.dart';
import '../../config/api_config.dart';

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

  List<Map<String, dynamic>> _bloquesFinales = [];
  List<String> _diasConPlazas = []; // Equivale a tu lista de C#
  bool _estaCargando = false;

  final Color naranjaLogo = const Color(0xFFFF6B00);
  final Color grisFondo = const Color(0xFFF4F7F9);
  final Color negroSuave = const Color(0xFF2D2D2D);

  @override
  void initState() {
    super.initState();
    _diaSeleccionado = _diaEnfocado;
    _inicializarDatos();
  }

  // --- LÓGICA TIPO C# ---

  Future<void> _inicializarDatos() async {
    // 1. Cargamos los horarios para saber qué días poner en negrita (pintarDiasDisponibles)
    await _obtenerConfiguracionDias();
    // 2. Cargamos los bloques del día actual
    await _cargarDatosDia(_diaSeleccionado!);
  }

  Future<void> _obtenerConfiguracionDias() async {
    try {
      // Buscamos los horarios semanales del servicio
      final horariosBase = await _servicioService.buscarHorariosPorServicio(
        widget.servicio.idServicio,
      );

      setState(() {
        // Extraemos los nombres de los días (Lunes, Martes...) que tienen plazas >= 1
        _diasConPlazas = horariosBase
            .where((h) => h.plazas >= 1)
            .map((h) => _normalizarNombreDia(h.diaSemana))
            .toSet()
            .toList();
      });
    } catch (e) {
      print("Error en configuración inicial: $e");
    }
  }

  // --- LÓGICA DE API BLOQUES ---

  Future<void> _cargarDatosDia(DateTime date) async {
    setState(() => _estaCargando = true);
    final String fechaStr = DateFormat('yyyy-MM-dd').format(date);

    try {
      final token = await _prefs.token;
      // Buscamos horarios específicos para ese día de la semana
      final horariosBase = await _servicioService.buscarHorariosPorDiaYServicio(
        _getDiaBackend(date),
        widget.servicio.idServicio,
      );

      List<Map<String, dynamic>> listaTemporal = [];

      for (var h in horariosBase) {
        final url = Uri.parse(ApiConfig.getDisponibilidad(fechaStr, h.id));
        final response = await http.get(
          url,
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          Map<String, dynamic> bloquesMap = jsonDecode(response.body);
          bloquesMap.forEach((hora, plazas) {
            if (plazas > 0) {
              // Solo añadimos si hay plazas (como en tu C#)
              listaTemporal.add({
                'hora': hora,
                'plazas': plazas,
                'horarioObj': h,
              });
            }
          });
        }
      }

      listaTemporal.sort((a, b) => a['hora'].compareTo(b['hora']));

      setState(() {
        _bloquesFinales = listaTemporal;
        _estaCargando = false;
      });
    } catch (e) {
      setState(() => _estaCargando = false);
      _mostrarSnackBar("Error al conectar con el servidor", Colors.redAccent);
    }
  }

  // --- ACCIÓN DE RESERVAR (POST) ---

  Future<void> _confirmarReserva(HorarioSemanal h, String horaBloque) async {
    final int? clienteId = await _prefs.userId;
    final String fechaStr = DateFormat('yyyy-MM-dd').format(_diaSeleccionado!);
    final String horaLimpia = horaBloque.substring(0, 5);

    if (clienteId == null) return;

    setState(() => _estaCargando = true);

    try {
      final bool exito = await _servicioService.crearReserva(
        clienteId,
        h.id,
        fechaStr,
        horaLimpia,
      );

      if (exito) {
        _mostrarSnackBar("¡Reserva confirmada!", Colors.green);
        Navigator.pop(context, true);
      } else {
        _mostrarSnackBar("No se pudo completar la reserva", Colors.orange);
      }
    } catch (e) {
      _mostrarSnackBar("Error inesperado", Colors.redAccent);
    } finally {
      if (mounted) setState(() => _estaCargando = false);
    }
  }

  // --- INTERFAZ (UI COMPATIBLE) ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grisFondo,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: naranjaLogo,
        title: const Text(
          "Reserva tu cita",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildCalendarioHeader(),
          const Padding(
            padding: EdgeInsets.fromLTRB(25, 20, 25, 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "BLOQUES DISPONIBLES",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          Expanded(
            child: _estaCargando
                ? Center(child: CircularProgressIndicator(color: naranjaLogo))
                : _buildListaBloques(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarioHeader() {
    return Container(
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
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              widget.servicio.nombre.toUpperCase(),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: negroSuave,
              ),
            ),
          ),
          TableCalendar(
            locale: 'es_ES',
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(const Duration(days: 60)),
            focusedDay: _diaEnfocado,
            startingDayOfWeek: StartingDayOfWeek.monday,
            selectedDayPredicate: (day) => isSameDay(_diaSeleccionado, day),

            // FILTRO C#: Solo habilitar si el día tiene plazas configuradas
            enabledDayPredicate: (day) {
              return _diasConPlazas.contains(_getNombreDiaEspanol(day));
            },

            // ESTILO C# (AddBoldedDates): Pintar días disponibles en Negrita
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                if (_diasConPlazas.contains(_getNombreDiaEspanol(day))) {
                  return Center(
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        color: naranjaLogo,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  );
                }
                return null;
              },
            ),

            calendarFormat: CalendarFormat.month,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: naranjaLogo,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: naranjaLogo.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              disabledTextStyle: const TextStyle(color: Colors.black26),
            ),
            onDaySelected: (sel, foc) {
              setState(() {
                _diaSeleccionado = sel;
                _diaEnfocado = foc;
              });
              _cargarDatosDia(sel);
            },
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _buildListaBloques() {
    if (_bloquesFinales.isEmpty) {
      return const Center(
        child: Text(
          "No hay turnos disponibles.",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _bloquesFinales.length,
      itemBuilder: (context, i) {
        final bloque = _bloquesFinales[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
            title: Text(
              bloque['hora'].substring(0, 5),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Text(
              "${bloque['plazas']} plazas libres",
              style: const TextStyle(color: Colors.green),
            ),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: naranjaLogo),
              onPressed: () =>
                  _confirmarReserva(bloque['horarioObj'], bloque['hora']),
              child: const Text(
                "RESERVAR",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- HELPERS ---

  String _getNombreDiaEspanol(DateTime date) {
    List<String> dias = [
      "Lunes",
      "Martes",
      "Miércoles",
      "Jueves",
      "Viernes",
      "Sábado",
      "Domingo",
    ];
    return dias[date.weekday - 1];
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

  String _normalizarNombreDia(String dia) {
    // Convierte "MIERCOLES" o "miércoles" a "Miércoles" para comparar con el calendario
    if (dia.isEmpty) return "";
    String d = dia.toLowerCase();
    if (d.contains("miercoles")) return "Miércoles";
    if (d.contains("sabado")) return "Sábado";
    return d[0].toUpperCase() + d.substring(1);
  }

  void _mostrarSnackBar(String mensaje, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje), backgroundColor: color));
  }
}
