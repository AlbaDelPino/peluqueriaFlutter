import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/service_model.dart';

class ServiceDetailScreen extends StatefulWidget {
  final Servicio servicio;

  const ServiceDetailScreen({super.key, required this.servicio});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _selectedHora;
  List<String> _horasDisponibles = [];

  // Lista de festivos (ejemplo, añade los que quieras)
  final List<DateTime> _festivos = [
    DateTime(2025, 1, 1),   // Año Nuevo
    DateTime(2025, 12, 25), // Navidad
    DateTime(2025, 12, 6),  // Constitución
  ];

  // Función para obtener horas disponibles
  List<String> _getHoras(DateTime day) {
    // Bloquear sábados y domingos
    if (day.weekday == DateTime.saturday || day.weekday == DateTime.sunday) {
      return [];
    }

    // Bloquear festivos
    if (_festivos.any((f) => isSameDay(f, day))) {
      return [];
    }

    // Horas normales
    return ["10:00", "11:00", "12:00", "16:00", "17:00", "18:00"];
  }

  void _abrirFormularioReserva() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Confirmar reserva"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Servicio: ${widget.servicio.nombre}"),
              Text("Fecha: ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}"),
              Text("Hora: $_selectedHora"),
              const SizedBox(height: 20),
              const Text("¿Quieres confirmar esta cita?"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8B00)),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Cita confirmada con éxito")),
                );
              },
              child: const Text("Confirmar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFFFF8B00);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        title: const Text(
          "Calendario",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🟠 Bloque con servicio y descripción
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.servicio.nombre,
                        style: const TextStyle(
                          fontSize: 20,
                          color: primary,
                        )),
                    const SizedBox(height: 8),
                    Text(widget.servicio.descripcion,
                        style: const TextStyle(fontSize: 16, color: Colors.black87)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 📅 Calendario estilizado
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
                ],
              ),
              child: TableCalendar(
                locale: 'es_ES',
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  // Bloquear sábados, domingos y festivos
                  if (selectedDay.weekday == DateTime.saturday ||
                      selectedDay.weekday == DateTime.sunday ||
                      _festivos.any((f) => isSameDay(f, selectedDay))) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("No hay horas disponibles en este día")),
                    );
                    return;
                  }

                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    _horasDisponibles = _getHoras(selectedDay);
                    _selectedHora = null;
                  });
                },
                startingDayOfWeek: StartingDayOfWeek.monday,
                calendarFormat: CalendarFormat.month,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: primary,
                  ),
                  leftChevronIcon: Icon(Icons.chevron_left, color: primary),
                  rightChevronIcon: Icon(Icons.chevron_right, color: primary),
                ),
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: primary,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  weekendTextStyle: TextStyle(color: Colors.redAccent),
                ),
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    if (_festivos.any((f) => isSameDay(f, day))) {
                      return Center(
                        child: Text(
                          '${day.day}',
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      );
                    }
                    return null;
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ⏰ Horas disponibles
            if (_selectedDay != null && _horasDisponibles.isNotEmpty) ...[
              const Text("Horas disponibles:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: _horasDisponibles.map((hora) {
                  final isSelected = _selectedHora == hora;
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected ? Colors.orange : primary,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedHora = hora;
                      });
                    },
                    child: Text(hora, style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              if (_selectedHora != null)
                Center(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: _abrirFormularioReserva,
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text("Añadir", style: TextStyle(color: Colors.white)),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
