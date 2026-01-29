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
  bool _estaCargando = false;

  final Color naranjaLogo = const Color(0xFFFF6B00);
  final Color grisFondo = const Color(0xFFF4F7F9);
  final Color negroSuave = const Color(0xFF2D2D2D);

  @override
  void initState() {
    super.initState();
    _diaSeleccionado = _diaEnfocado;
    _cargarDatosDia(_diaSeleccionado!);
  }

  // --- LÓGICA DE API ---

  Future<void> _cargarDatosDia(DateTime date) async {
    setState(() => _estaCargando = true);
    final String fechaStr = DateFormat('yyyy-MM-dd').format(date);

    try {
      final token = await _prefs.token;
      
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
            listaTemporal.add({
              'hora': hora,
              'plazas': plazas,
              'horarioObj': h,
            });
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

  Future<void> _confirmarReserva(HorarioSemanal h, String horaBloque) async {
    final int? clienteId = await _prefs.userId;
    final String fechaStr = DateFormat('yyyy-MM-dd').format(_diaSeleccionado!);

    if (clienteId == null) {
      _mostrarSnackBar("Error: Sesión no válida", Colors.redAccent);
      return;
    }

    final Map<String, dynamic> citaRequest = {
      "fecha": fechaStr,
      "horaInicio": horaBloque.substring(0, 5),
      "horario": {"id": h.id},
      "cliente": {"id": clienteId},
    };

    setState(() => _estaCargando = true);

    try {
      final token = await _prefs.token;
      final response = await http.post(
        Uri.parse('http://192.168.7.13:8082/citas/reservar'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(citaRequest),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _mostrarSnackBar("¡Reserva confirmada!", Colors.green);
        if (mounted) Navigator.pop(context, true);
      } else {
        _mostrarSnackBar("No se pudo realizar la reserva", Colors.orange);
      }
    } catch (e) {
      _mostrarSnackBar("Error de red", Colors.redAccent);
    } finally {
      if (mounted) setState(() => _estaCargando = false);
    }
  }

  // --- COMPONENTES DE CONFIRMACIÓN (BOTTOM SHEET) ---

  void _mostrarPantallaConfirmacion(HorarioSemanal h, String horaBloque) {
    final String fechaFormateada = DateFormat('dd/MM/yyyy').format(_diaSeleccionado!);
    final String horaLimpia = horaBloque.substring(0, 5);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(25),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              const Text("Confirmar Reserva", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 25),
              _buildDetalleFila(Icons.content_cut, "Servicio", widget.servicio.nombre),
              _buildDetalleFila(Icons.calendar_month, "Fecha", fechaFormateada),
              _buildDetalleFila(Icons.access_time, "Hora", "$horaLimpia H"),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancelar", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _confirmarReserva(h, horaBloque);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: naranjaLogo,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text("CONFIRMAR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetalleFila(IconData icono, String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icono, color: naranjaLogo, size: 24),
          const SizedBox(width: 15),
          Text("$titulo:", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(width: 10),
          Expanded(child: Text(valor, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  // --- INTERFAZ PRINCIPAL ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grisFondo,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: naranjaLogo,
        title: const Text("Reserva tu cita", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildCalendarioHeader(),
          const Padding(
            padding: EdgeInsets.fromLTRB(25, 20, 25, 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("BLOQUES DISPONIBLES", 
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
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
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(widget.servicio.nombre.toUpperCase(), 
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: negroSuave)),
          ),
          TableCalendar(
            locale: 'es_ES',
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(const Duration(days: 60)),
            focusedDay: _diaEnfocado,
            startingDayOfWeek: StartingDayOfWeek.monday,
            selectedDayPredicate: (day) => isSameDay(_diaSeleccionado, day),
            calendarFormat: CalendarFormat.month,
            headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(color: naranjaLogo, shape: BoxShape.circle),
              todayDecoration: BoxDecoration(color: naranjaLogo.withOpacity(0.2), shape: BoxShape.circle),
              todayTextStyle: TextStyle(color: naranjaLogo, fontWeight: FontWeight.bold),
            ),
            onDaySelected: (sel, foc) {
              setState(() { _diaSeleccionado = sel; _diaEnfocado = foc; });
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
      return const Center(child: Text("No hay turnos disponibles.", style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _bloquesFinales.length,
      itemBuilder: (context, i) {
        final bloque = _bloquesFinales[i];
        final String hora = bloque['hora'].substring(0, 5);
        final int plazas = bloque['plazas'];
        final bool disponible = plazas > 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            title: Text(hora, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            subtitle: Text(disponible ? "$plazas plazas libres" : "Agotado", 
              style: TextStyle(color: disponible ? Colors.green : Colors.red, fontWeight: FontWeight.w600)),
            trailing: ElevatedButton(
              onPressed: disponible ? () => _mostrarPantallaConfirmacion(bloque['horarioObj'], bloque['hora']) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: naranjaLogo,
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(disponible ? "RESERVAR" : "LLENO", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        );
      },
    );
  }

  String _getDiaBackend(DateTime date) {
    List<String> dias = ["LUNES", "MARTES", "MIERCOLES", "JUEVES", "VIERNES", "SABADO", "DOMINGO"];
    return dias[date.weekday - 1];
  }

  void _mostrarSnackBar(String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }
}