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

  // Simulación de horas disponibles
  List<String> _getHoras(DateTime day) {
    return [
      "10:00",
      "11:00",
      "12:00",
      "16:00",
      "17:00",
      "18:00",
    ];
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
        title: Text(widget.servicio.nombre),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.servicio.descripcion,
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),

            // 📅 Calendario en español con semana de lunes a domingo
            TableCalendar(
              locale: 'es_ES',
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: DateTime.now(),
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                  _horasDisponibles = _getHoras(selectedDay);
                  _selectedHora = null; // reset al cambiar de día
                });
              },
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarFormat: CalendarFormat.month,
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: primary,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ⏰ Horas disponibles
            if (_selectedDay != null) ...[
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
                    child: Text(hora,
                        style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // 👉 Botón de añadir debajo de las horas
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
