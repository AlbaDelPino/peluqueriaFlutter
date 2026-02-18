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
  List<Map<String, dynamic>> _bloqueosRaw = []; 
  List<int> _misHorariosIds = [];
  bool _estaCargando = false;

  final Color naranjaLogo = const Color(0xFFFF6B00);

  @override
  void initState() {
    super.initState();
    _inicializarDatos();
  }

  Future<void> _inicializarDatos() async {
    setState(() => _estaCargando = true);
    await _obtenerConfiguracionDias(); 
    await _obtenerBloqueos(); 
    await _cargarDatosDia(_diaSeleccionado!);
  }

  Future<void> _obtenerBloqueos() async {
    final bloqueos = await _horarioService.obtenerBloqueosCompletos();
    setState(() => _bloqueosRaw = bloqueos);
  }

  Future<void> _obtenerConfiguracionDias() async {
    final horarios = await _horarioService.buscarHorariosPorServicio(widget.servicio.idServicio);
    setState(() {
      _misHorariosIds = horarios.map((h) => h.id).toList();
      _diasConPlazas = horarios
          .where((h) => h.plazas >= 1)
          .map((h) => _normalizarNombreDia(h.diaSemana))
          .toSet().toList();
    });
  }

  bool _esDiaHabilitado(DateTime day) {
    DateTime diaLimpio = DateTime(day.year, day.month, day.day);
    DateTime hoyLimpio = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    if (diaLimpio.isBefore(hoyLimpio)) return false;
    if (!_diasConPlazas.contains(_getNombreDiaEspanol(day))) return false;

    return !_bloqueosRaw.any((bloqueo) {
      DateTime fechaBloqueo = DateTime.parse(bloqueo['fecha']);
      if (isSameDay(fechaBloqueo, diaLimpio)) {
        List<dynamic> horariosBloqueados = bloqueo['horarios'] ?? [];
        return horariosBloqueados.any((h) => _misHorariosIds.contains(h['id']));
      }
      return false;
    });
  }

  Future<void> _cargarDatosDia(DateTime date) async {
    setState(() => _estaCargando = true);
    final String fechaApi = DateFormat('dd/MM/yyyy').format(date);
    try {
      final horarios = await _horarioService.buscarHorariosPorDiaYServicio(_getDiaBackend(date), widget.servicio.idServicio);
      List<Map<String, dynamic>> temp = [];
      for (var h in horarios) {
        final plazasMap = await _horarioService.obtenerPlazasDisponibles(fechaApi, h.id);
        plazasMap.forEach((hora, plazas) {
          if (plazas > 0) temp.add({'hora': hora, 'plazas': plazas, 'horarioObj': h});
        });
      }
      temp.sort((a, b) => a['hora'].compareTo(b['hora']));
      setState(() { _bloquesFinales = temp; _estaCargando = false; });
    } catch (e) { setState(() => _estaCargando = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: naranjaLogo,
        elevation: 0,
        centerTitle: true,
        title: const TextoAutomatico("RESERVA TU CITA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea( 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
              child: TextoAutomatico(
                widget.servicio.nombre.toUpperCase(),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            _buildCalendarioHeader(),
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 20, 24, 10),
              child: TextoAutomatico("TURNOS DISPONIBLES", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black45)),
            ),
            Expanded(
              child: _estaCargando 
                ? Center(child: CircularProgressIndicator(color: naranjaLogo)) 
                : _buildListaTurnos(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarioHeader() {
    final String languageCode = Localizations.localeOf(context).languageCode;
    final String localConfig = (languageCode == 'en') ? 'en_US' : 'es_ES';
    return Container(
      width: MediaQuery.of(context).size.width, // Ocupa todo el ancho
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]
      ),
      child: TableCalendar(
        locale:localConfig,
        firstDay: DateTime.now(),
        lastDay: DateTime.now().add(const Duration(days: 60)),
        focusedDay: _diaEnfocado,
        startingDayOfWeek: StartingDayOfWeek.monday,
        rowHeight: 45, // Altura de filas para que no se vea comprimido
        daysOfWeekHeight: 30,
        
        // --- ESTO ESTIRA LOS DÍAS ---
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
          rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
        ),

        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          weekendStyle: TextStyle(color: Colors.black45, fontWeight: FontWeight.bold),
        ),

        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          selectedDecoration: BoxDecoration(color: naranjaLogo, shape: BoxShape.circle),
          todayDecoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: naranjaLogo)),
          todayTextStyle: TextStyle(color: naranjaLogo, fontWeight: FontWeight.bold),
          disabledTextStyle: const TextStyle(color: Colors.black12),
          // Márgenes mínimos para maximizar el ancho
          cellPadding: EdgeInsets.zero,
          cellMargin: const EdgeInsets.all(2),
        ),

        selectedDayPredicate: (day) => isSameDay(_diaSeleccionado, day),
        enabledDayPredicate: _esDiaHabilitado,

        onDaySelected: (sel, foc) {
          setState(() { _diaSeleccionado = sel; _diaEnfocado = foc; });
          _cargarDatosDia(sel);
        },
      ),
    );
  }

  Widget _buildListaTurnos() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _bloquesFinales.length,
      itemBuilder: (context, i) {
        final b = _bloquesFinales[i];
        final String duracion = "${b['duracion'] ?? '30'} min"; 
        final String horaInicio = b['hora'].substring(0, 5);
        return Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.black12), borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
          title: Row(
              children: [
                const Icon(Icons.timer_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                TextoAutomatico(
                  " $horaInicio h", 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                ),
              ],
            ),            
            subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  TextoAutomatico("Duración: $duracion", 
                    style: TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 13)),
                  TextoAutomatico("${b['plazas']} plazas libres", 
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500)),
                ],
              ), 
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: naranjaLogo, elevation: 0),
              onPressed: () => _confirmarReservaBottomSheet(b['horarioObj'], b['hora']),
              child: const TextoAutomatico("RESERVAR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        );
      },
    );
  }

  // ... (resto del código igual hasta el BottomSheet)

  void _confirmarReservaBottomSheet(HorarioSemanal h, String hora) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      elevation: 10,
      // isScrollControlled: true permite que el modal no se corte si el contenido es grande
      isScrollControlled: true, 
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // Usamos SafeArea para respetar la barra del sistema del móvil
        return SafeArea(
          child: Padding(
            // El padding inferior (bottom) ahora tiene un extra para separarse del borde
            padding: EdgeInsets.fromLTRB(30, 35, 30, MediaQuery.of(context).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min, // El modal solo ocupa lo que necesita
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TextoAutomatico(
                  "TU RESERVA", 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5)
                ),
                const SizedBox(height: 30),
                
                _itemDetalleConTabulacion("SERVICIO", widget.servicio.nombre.toUpperCase()),
                const Divider(color: Colors.black12, height: 25),
                _itemDetalleConTabulacion("FECHA", DateFormat('dd / MM / yyyy').format(_diaSeleccionado!)),
                const Divider(color: Colors.black12, height: 25),
                _itemDetalleConTabulacion("HORA", hora.substring(0, 5)),
                
                const SizedBox(height: 40),
                
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: naranjaLogo,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      final id = await _prefs.userId;
                      _ejecutarReserva(h, hora, id);
                    },
                    child: const TextoAutomatico(
                      "CONFIRMAR RESERVA", 
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
                    ),
                  ),
                ),
                // Este espacio extra asegura que el botón nunca toque el borde físico del móvil
                const SizedBox(height: 10), 
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget mejorado para manejar nombres largos con "tabulación" visual
  Widget _itemDetalleConTabulacion(String label, String valor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start, // Alinea al tope si hay varias líneas
      children: [
        TextoAutomatico(
          label, 
          style: const TextStyle(fontSize: 12, color: Colors.black45, fontWeight: FontWeight.bold)
        ),
        const SizedBox(width: 20), // Espacio fijo de "tabulación"
        Expanded(
          child: TextoAutomatico(
            valor,
            textAlign: TextAlign.right, // Lo empuja hacia la derecha
            style: const TextStyle(
              fontSize: 15, 
              color: Colors.black, 
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      ],
    );
  }

// ... (resto de funciones iguales)

  Widget _itemDetalleMinimal(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextoAutomatico(label, style: const TextStyle(fontSize: 12, color: Colors.black45, fontWeight: FontWeight.bold)),
          TextoAutomatico(valor, style: const TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Future<void> _ejecutarReserva(HorarioSemanal h, String hora, int clienteId) async {
    setState(() => _estaCargando = true);
    final exito = await _horarioService.crearReserva(clienteId, h.id, _diaSeleccionado!, hora);
    if (mounted) setState(() => _estaCargando = false);
    if (exito) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: TextoAutomatico("Reserva realizada con éxito"), backgroundColor: Colors.green));
      Navigator.pop(context, true);
    }
  }

  String _getNombreDiaEspanol(DateTime d) => ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"][d.weekday - 1];
  String _getDiaBackend(DateTime d) => ["LUNES", "MARTES", "MIERCOLES", "JUEVES", "VIERNES", "SABADO", "DOMINGO"][d.weekday - 1];
  String _normalizarNombreDia(String dia) {
    String d = dia.toLowerCase();
    if (d.contains("miercoles")) return "Miércoles";
    if (d.contains("sabado")) return "Sábado";
    return d[0].toUpperCase() + d.substring(1);
  }
}