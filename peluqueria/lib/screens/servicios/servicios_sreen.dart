import 'package:flutter/material.dart';
import '../../services/servicio_service.dart';
import '../../services/user_preferences.dart';
import '../../models/servicios/servicio_model.dart';
import '../../models/servicios/tipo_servicio_model.dart';
import '../calendario/calendario_screen.dart';
import 'package:peluqueria/widget/texto_automatico.dart';
import 'detalle_tipo_screen.dart';

class ServiciosScreen extends StatefulWidget {
  const ServiciosScreen({super.key});

  @override
  _ServiciosScreenState createState() => _ServiciosScreenState();
}

class _ServiciosScreenState extends State<ServiciosScreen> {
  final ServicioService _servicioService = ServicioService();
  final UserPreferences _prefs = UserPreferences();
  final Color naranjaLogo = const Color(0xFFFF6B00);

  List<Servicio> _todosLosServicios = [];
  List<TipoServicio> _tiposDeServicio = [];
  final Set<int> _idsFavoritos = {};

  bool _estaCargando = true;
  bool _filtroFavoritosActivo = false;
  String _textoBusqueda = "";

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  // --- ICONOS POR CATEGORÍA ---
  IconData _getIconoParaTipo(String nombre) {
    final n = nombre.toLowerCase().trim();
    if (n.contains('peluquería')) return Icons.content_cut_rounded;
    if (n.contains('manicura') || n.contains('pedicura'))
      return Icons.front_hand_rounded;
    if (n.contains('depilación')) return Icons.clean_hands_rounded;
    if (n.contains('facial')) return Icons.face_retouching_natural;
    if (n.contains('corporales')) return Icons.accessibility_new_rounded;
    if (n.contains('masajes')) return Icons.spa_rounded;
    if (n.contains('maquillaje')) return Icons.auto_fix_high_rounded;
    if (n.contains('mirada')) return Icons.remove_red_eye_rounded;
    return Icons.category_rounded;
  }

  Future<void> _cargarDatos() async {
    try {
      final int clienteId = await _prefs.userId;
      final resultados = await Future.wait([
        _servicioService.obtenerTodos(),
        _servicioService.obtenerTipos(),
        _servicioService.obtenerIdsFavoritos(clienteId),
      ]);
      if (mounted) {
        setState(() {
          _todosLosServicios = resultados[0] as List<Servicio>;
          _tiposDeServicio = resultados[1] as List<TipoServicio>;
          _idsFavoritos.addAll(resultados[2] as List<int>);
          _estaCargando = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _estaCargando = false);
    }
  }

  // Lógica sincronizada para favoritos
  void _handleToggleFavorito(Servicio s, bool nuevoEstado) async {
    final int clienteId = await _prefs.userId;

    // Si estamos en la pantalla principal (buscando), actualizamos el set aquí
    if (!widget.toString().contains('DetalleTipoScreen')) {
      setState(() {
        if (nuevoEstado)
          _idsFavoritos.add(s.idServicio);
        else
          _idsFavoritos.remove(s.idServicio);
      });
    }

    bool exito = nuevoEstado
        ? await _servicioService.agregarFavorito(clienteId, s.idServicio)
        : await _servicioService.eliminarFavorito(clienteId, s.idServicio);

    if (!exito && mounted) {
      setState(() {
        if (nuevoEstado)
          _idsFavoritos.remove(s.idServicio);
        else
          _idsFavoritos.add(s.idServicio);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _estaCargando
          ? Center(child: CircularProgressIndicator(color: naranjaLogo))
          : Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: (_filtroFavoritosActivo || _textoBusqueda.isNotEmpty)
                      ? _buildListaResultados() // Vista de búsqueda/favoritos
                      : _buildGridCategorias(), // Vista normal de cuadros
                ),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
        width: double.infinity, // Asegura que ocupe todo el ancho para poder centrar
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 15),      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const TextoAutomatico(
            "NUESTROS SERVICIOS",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    onChanged: (val) => setState(() => _textoBusqueda = val),
                    decoration: InputDecoration(
                      hintText: "Buscar servicio...",
                      prefixIcon: Icon(Icons.search, color: naranjaLogo),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _buildBotonFiltroFav(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBotonFiltroFav() {
    return GestureDetector(
      onTap: () =>
          setState(() => _filtroFavoritosActivo = !_filtroFavoritosActivo),
      child: Container(
        height: 45,
        width: 45,
        decoration: BoxDecoration(
          color: _filtroFavoritosActivo ? naranjaLogo : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          _filtroFavoritosActivo ? Icons.favorite : Icons.favorite_border,
          color: _filtroFavoritosActivo ? Colors.white : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildGridCategorias() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.9,
      ),
      itemCount: _tiposDeServicio.length,
      itemBuilder: (context, index) {
        final tipo = _tiposDeServicio[index];
        return InkWell(
          onTap: () {
            final filtrados = _todosLosServicios
                .where((s) => s.tipoServicio.id == tipo.id)
                .toList();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetalleTipoScreen(
                  titulo: tipo.nombre,
                  servicios: filtrados,
                  idsFavoritos: _idsFavoritos,
                  onToggle: _handleToggleFavorito,
                ),
              ),
            ).then((_) => setState(() {}));
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getIconoParaTipo(tipo.nombre),
                  color: naranjaLogo,
                  size: 35,
                ),
                const SizedBox(height: 10),
                TextoAutomatico(
                  tipo.nombre,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildListaResultados() {
    final listaFiltrada = _todosLosServicios.where((s) {
      final coincideTexto = s.nombre.toLowerCase().contains(
        _textoBusqueda.toLowerCase(),
      );
      final coincideFav =
          !_filtroFavoritosActivo || _idsFavoritos.contains(s.idServicio);
      return coincideTexto && coincideFav;
    }).toList();

    if (listaFiltrada.isEmpty) {
      return const Center(child: Text("No se encontraron servicios"));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      itemCount: listaFiltrada.length,
      itemBuilder: (context, index) {
        final s = listaFiltrada[index];
        final bool esFav = _idsFavoritos.contains(s.idServicio);
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextoAutomatico(
                      s.nombre,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextoAutomatico(
                      "${s.precio}€",
                      style: TextStyle(
                        color: naranjaLogo,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _handleToggleFavorito(s, !esFav),
                icon: Icon(
                  esFav ? Icons.favorite : Icons.favorite_border,
                  color: esFav ? naranjaLogo : Colors.grey,
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CalendarioScreen(servicio: s),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const TextoAutomatico(
                  "Reservar",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
