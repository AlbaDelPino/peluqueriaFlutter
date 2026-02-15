import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/servicios/servicio_model.dart';
import '../../models/horario/horario_model.dart';
import '../../services/horario_service.dart';
import '../../services/user_preferences.dart';
import '../../providers/locale_provider.dart';
import '../../widget/texto_automatico.dart';

class CalendarioScreen extends StatefulWidget {
  final Servicio servicio;
  const CalendarioScreen({super.key, required this.servicio});

  @override
  State<CalendarioScreen> createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> {
  final HorarioService _horarioService = HorarioService();
  final UserPreferences _prefs = UserPreferences();

  DateTime _diaEnfocado = DateTime.now();
  DateTime? _diaSeleccionado = DateTime.now();
  List<Map<String, dynamic>> _bloquesFinales = [];
  List<String> _diasConPlazas = []; 
  List<DateTime> _fechasBloqueadas = []; 
  bool _estaCargando = false;

  final Color naranjaLogo = const Color(0xFFFF6B00);
  final Color grisFondo = const Color(0xFFF4F7F9);

  @override
  void initState() {
    super.initState();
    _inicializarDatos();
  }

  Future<void> _inicializarDatos() async {
    setState(() => _estaCargando = true);
    await _obtenerConfiguracionDias(); // Configura días laborables del servicio
    await _obtenerBloqueos(); // Carga bloqueos de fecha
    await _cargarDatosDia(_diaSeleccionado!);
  }

  Future<void> _obtenerBloqueos() async {
    final bloqueos = await _horarioService.obtenerDiasBloqueados();
    setState(() => _fechasBloqueadas = bloqueos);
  }

  Future<void> _obtenerConfiguracionDias() async {
    final horarios = await _horarioService.buscarHorariosPorServicio(widget.servicio.idServicio);
    setState(() {
      _diasConPlazas = horarios
          .where((h) => h.plazas >= 1)
          .map((h) => _normalizarNombreDia(h.diaSemana))
          .toSet()
          .toList();
    });
  }

  // Lógica de habilitación específica para este servicio
  bool _esDiaHabilitado(DateTime day) {
    DateTime diaLimpio = DateTime(day.year, day.month, day.day);
    DateTime hoyLimpio = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    if (diaLimpio.isBefore(hoyLimpio)) return false;

    // Filtro 1: ¿El servicio abre ese día de la semana?
    bool atiendeEseDia = _diasConPlazas.contains(_getNombreDiaEspanol(day));
    if (!atiendeEseDia) return false;

    // Filtro 2: ¿La fecha está bloqueada en el sistema?
    bool estaBloqueado = _fechasBloqueadas.any((d) => 
      d.year == diaLimpio.year && d.month == diaLimpio.month && d.day == diaLimpio.day);
    
    return !estaBloqueado;
  }

  Future<void> _cargarDatosDia(DateTime date) async {
    setState(() => _estaCargando = true);
    final String fechaApi = DateFormat('dd/MM/yyyy').format(date);
    
    try {
      final horarios = await _horarioService.buscarHorariosPorDiaYServicio(
        _getDiaBackend(date), 
        widget.servicio.idServicio
      );

      List<Map<String, dynamic>> temp = [];
      for (var h in horarios) {
        final plazasMap = await _horarioService.obtenerPlazasDisponibles(fechaApi, h.id);
        plazasMap.forEach((hora, plazas) {
          if (plazas > 0) {
            temp.add({'hora': hora, 'plazas': plazas, 'horarioObj': h});
          }
        });
      }

      temp.sort((a, b) => a['hora'].compareTo(b['hora']));
      setState(() { 
        _bloquesFinales = temp; 
        _estaCargando = false; 
      });
    } catch (e) {
      setState(() => _estaCargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEn = Provider.of<LocaleProvider>(context).locale.languageCode == 'en';

    return Scaffold(
      backgroundColor: grisFondo,
      appBar: AppBar(
        backgroundColor: naranjaLogo,
        title: TextoAutomatico(isEn ? "Book Appointment" : "Reserva tu cita", style: const TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildCalendarioHeader(),
          Expanded(
            child: _estaCargando 
              ? Center(child: CircularProgressIndicator(color: naranjaLogo)) 
              : _buildListaBloques(isEn)
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarioHeader() {
    final lang = Provider.of<LocaleProvider>(context).locale.languageCode;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]
      ),
      child: TableCalendar(
        locale: lang == 'es' ? 'es_ES' : 'en_US',
        firstDay: DateTime.now(),
        lastDay: DateTime.now().add(const Duration(days: 60)),
        focusedDay: _diaEnfocado,
        startingDayOfWeek: StartingDayOfWeek.monday,
        selectedDayPredicate: (day) => isSameDay(_diaSeleccionado, day),
        enabledDayPredicate: _esDiaHabilitado,
        headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
        calendarStyle: CalendarStyle(
          selectedDecoration: BoxDecoration(color: naranjaLogo, shape: BoxShape.circle),
          todayDecoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: naranjaLogo)),
          todayTextStyle: TextStyle(color: naranjaLogo, fontWeight: FontWeight.bold),
          disabledTextStyle: const TextStyle(color: Colors.black26),
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            if (_esDiaHabilitado(day)) {
              return Center(child: Text('${day.day}', style: TextStyle(color: naranjaLogo, fontWeight: FontWeight.bold)));
            }
            return null;
          },
        ),
        onDaySelected: (sel, foc) {
          setState(() { _diaSeleccionado = sel; _diaEnfocado = foc; });
          _cargarDatosDia(sel);
        },
      ),
    );
  }

  Widget _buildListaBloques(bool isEn) {
    if (_bloquesFinales.isEmpty) {
      return Center(child: TextoAutomatico(isEn ? "No slots available" : "No hay turnos disponibles."));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _bloquesFinales.length,
      itemBuilder: (context, i) {
        final b = _bloquesFinales[i];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            title: Text(b['hora'].substring(0, 5), style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("${b['plazas']} ${isEn ? 'slots' : 'libres'}", style: const TextStyle(color: Colors.green)),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: naranjaLogo),
              onPressed: () => _mostrarPopUpConfirmacion(b['horarioObj'], b['hora'], isEn),
              child: Text(isEn ? "BOOK" : "RESERVAR", style: const TextStyle(color: Colors.white)),
            ),
          ),
        );
      },
    );
  }

  void _mostrarPopUpConfirmacion(HorarioSemanal h, String hora, bool isEn) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEn ? "Confirm" : "Confirmar"),
        content: Text("${widget.servicio.nombre}\n${DateFormat('dd/MM/yyyy').format(_diaSeleccionado!)} - $hora"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCELAR")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final id = await _prefs.userId;
              _procederConReserva(h, hora, id);
            },
            child: const Text("CONFIRMAR"),
          )
        ],
      ),
    );
  }

  Future<void> _procederConReserva(HorarioSemanal h, String hora, int clienteId) async {
    setState(() => _estaCargando = true);
    final exito = await _horarioService.crearReserva(clienteId, h.id, _diaSeleccionado!, hora);
    if (mounted) setState(() => _estaCargando = false);
    if (exito) {
      _mostrarSnackBar("¡Reserva realizada!", Colors.green);
      Navigator.pop(context, true);
    } else {
      _mostrarSnackBar("Error en la reserva", Colors.red);
    }
  }

  String _getNombreDiaEspanol(DateTime date) => ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"][date.weekday - 1];
  String _getDiaBackend(DateTime date) => ["LUNES", "MARTES", "MIERCOLES", "JUEVES", "VIERNES", "SABADO", "DOMINGO"][date.weekday - 1];
  
  String _normalizarNombreDia(String dia) {
    String d = dia.toLowerCase();
    if (d.contains("miercoles")) return "Miércoles";
    if (d.contains("sabado")) return "Sábado";
    return d[0].toUpperCase() + d.substring(1);
  }

  void _mostrarSnackBar(String m, Color c) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), backgroundColor: c));
}