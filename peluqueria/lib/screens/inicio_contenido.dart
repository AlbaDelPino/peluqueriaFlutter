import 'package:flutter/material.dart';
import 'package:peluqueria/screens/detalles_screen.dart';

class InicioContenido extends StatefulWidget {
  @override
  _InicioContenidoState createState() => _InicioContenidoState();
}

class _InicioContenidoState extends State<InicioContenido> {
  final TextEditingController micontrolador = TextEditingController();

  // Colores corporativos
  final Color naranjaLogo = const Color(0xFFFF6B00);
  final Color negroSuave = const Color(0xFF2D2D2D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Fondo gris muy claro
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Cabecera con Imagen de Bienvenida
            _buildHeader(),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Sección de Información de la Empresa
                  _buildSeccionEmpresa(),

                  const SizedBox(height: 25),

                  // 3. Sección de Interacción (Tu código anterior mejorado)
                  _buildSeccionDonacion(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET: CABECERA ---
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: negroSuave,
        image: const DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?q=80&w=2074&auto=format&fit=crop',
          ),
          fit: BoxFit.cover,
          opacity: 0.6,
        ),
      ),
      child: const Center(
        child: Text(
          "BERNAT\nESTILISTAS",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
          ),
        ),
      ),
    );
  }

  // --- WIDGET: SECCIÓN DE LA EMPRESA ---
  Widget _buildSeccionEmpresa() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.storefront, color: naranjaLogo),
              const SizedBox(width: 10),
              const Text(
                "SOBRE NOSOTROS",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Text(
            "Bernat Peluquería",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildInfoRow(
            Icons.location_on,
            "Calle de la Moda 45, Valencia, España",
          ),
          const Divider(height: 30),
          _buildInfoRow(Icons.email, "contacto@bernatpeluqueria.com"),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.phone_android, "+34 612 345 678"),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.access_time_filled,
            "Lunes a Sábado: 09:00 - 20:00",
          ),
        ],
      ),
    );
  }

  // --- WIDGET: FILAS DE CONTACTO ---
  Widget _buildInfoRow(IconData icon, String texto) {
    return Row(
      children: [
        Icon(icon, size: 18, color: naranjaLogo),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            texto,
            style: TextStyle(
              fontSize: 14,
              color: negroSuave,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  //// --- WIDGET: SECCIÓN DE DONACIÓN / OBJETIVO SOCIAL ---
  Widget _buildSeccionDonacion() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // Un degradado sutil o un color crema para diferenciarlo
        color: naranjaLogo.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: naranjaLogo.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.volunteer_activism, color: naranjaLogo, size: 28),
              const SizedBox(width: 12),
              Text(
                "MÁS QUE UN CORTE",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: naranjaLogo,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            "Tu belleza genera impacto",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: negroSuave,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Es importante que sepas que el importe íntegro de nuestros servicios se gestiona como una donación. "
            "Gracias a tu aporte, podemos continuar con nuestras labores sociales y de capacitación profesional. "
            "¡Tu visita marca la diferencia!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: negroSuave.withOpacity(0.8),
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
