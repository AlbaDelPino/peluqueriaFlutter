import 'package:flutter/material.dart';
import '../../services/servicio_service.dart';
import '../../services/user_preferences.dart';
import '../../models/servicios/servicio_model.dart';
import '../../models/servicios/tipo_servicio_model.dart';
import '../calendario/calendario_screen.dart';

class ServiciosScreen extends StatefulWidget {
  const ServiciosScreen({super.key});

  @override
  _ServiciosScreenState createState() => _ServiciosScreenState();
}

class _ServiciosScreenState extends State<ServiciosScreen> {
  final ServicioService _servicioService = ServicioService();
  final UserPreferences _prefs = UserPreferences();
  final TextEditingController _searchController = TextEditingController();

  final Color naranjaLogo = const Color(0xFFFF6B00);
  final Color textoPrincipal = const Color(0xFF333333);
  final Color grisSuave = const Color(0xFFF5F5F5);

  List<Servicio> _todosLosServicios = [];
  List<TipoServicio> _tiposDeServicio = [];
  final Set<int> _idsFavoritos = {};

  bool _estaCargando = true;
  String? _categoriaSeleccionada;
  String _textoBusqueda = "";
  bool _filtroFavoritosActivo = false;
  int? _idServicioSeleccionado;

  @override
  void initState() {
    super.initState();
    _cargarDatosIniciales(); // <-- Método que te faltaba
  }

  // --- 1. CARGA DE DATOS DESDE LA API ---
  Future<void> _cargarDatosIniciales() async {
    if (!mounted) return;
    setState(() => _estaCargando = true);

    try {
      final int clienteId = await _prefs.userId;
      
      // Lanzamos todas las peticiones a la vez
      final resultados = await Future.wait([
        _servicioService.obtenerTodos(),
        _servicioService.obtenerTipos(),
        _servicioService.obtenerIdsFavoritos(clienteId),
      ]);

      if (mounted) {
        setState(() {
          _todosLosServicios = resultados[0] as List<Servicio>;
          _tiposDeServicio = resultados[1] as List<TipoServicio>;
          _idsFavoritos.clear();
          //resultados[2] ya viene como List<int> gracias al mapeo del Service
          _idsFavoritos.addAll(resultados[2] as List<int>);
          _estaCargando = false;
        });
      }
    } catch (e) {
      print("ERROR CARGANDO DATOS: $e");
      if (mounted) setState(() => _estaCargando = false);
    }
  }

  // --- 2. GESTIÓN DE FAVORITOS (API) ---
  Future<void> _toggleFavorito(Servicio s, bool esFavoritoActual) async {
    final int clienteId = await _prefs.userId;
    if (clienteId == 0) return;

    setState(() {
      if (esFavoritoActual) _idsFavoritos.remove(s.idServicio);
      else _idsFavoritos.add(s.idServicio);
    });

    bool exito = esFavoritoActual
        ? await _servicioService.eliminarFavorito(clienteId, s.idServicio)
        : await _servicioService.agregarFavorito(clienteId, s.idServicio);

    if (!exito && mounted) {
      setState(() {
        if (esFavoritoActual) _idsFavoritos.add(s.idServicio);
        else _idsFavoritos.remove(s.idServicio);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_estaCargando) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B00)));
    }

    final listaFiltrada = _todosLosServicios.where((s) {
      final coincideCategoria = _categoriaSeleccionada == null || s.tipoServicio.nombre == _categoriaSeleccionada;
      final coincideTexto = s.nombre.toLowerCase().contains(_textoBusqueda.toLowerCase());
      final coincideFavorito = !_filtroFavoritosActivo || _idsFavoritos.contains(s.idServicio);
      return coincideCategoria && coincideTexto && coincideFavorito;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      // Usamos Column y Expanded para evitar el error de RenderFlex
      body: Column(
        children: [
          _buildBuscador(),
          _buildFiltros(),
          const SizedBox(height: 12),
          const Divider(height: 1),
          Expanded( // El Expanded evita que la lista cause desbordamiento
            child: listaFiltrada.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: listaFiltrada.length,
                    itemBuilder: (context, index) => _buildServicioCard(listaFiltrada[index]),
                  ),
          ),
        ],
      ),
    );
  }

  // --- COMPONENTES DE UI ---

  Widget _buildBuscador() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: TextField(
        onChanged: (val) => setState(() => _textoBusqueda = val),
        decoration: InputDecoration(
          hintText: "Buscar servicio...",
          prefixIcon: Icon(Icons.search, color: naranjaLogo),
          filled: true,
          fillColor: grisSuave,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildFiltros() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: naranjaLogo.withOpacity(0.3)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _categoriaSeleccionada,
                  isExpanded: true,
                  hint: const Text("Categorías"),
                  items: [
                    const DropdownMenuItem(value: null, child: Text("Todas")),
                    ..._tiposDeServicio.map((t) => DropdownMenuItem(value: t.nombre, child: Text(t.nombre))),
                  ],
                  onChanged: (val) => setState(() => _categoriaSeleccionada = val),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => setState(() => _filtroFavoritosActivo = !_filtroFavoritosActivo),
            child: Container(
              width: 50,
              height: 48,
              decoration: BoxDecoration(
                color: _filtroFavoritosActivo ? naranjaLogo : grisSuave,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.favorite, color: _filtroFavoritosActivo ? Colors.white : Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicioCard(Servicio s) {
    bool estaSeleccionado = _idServicioSeleccionado == s.idServicio;
    bool esFavorito = _idsFavoritos.contains(s.idServicio);

    return GestureDetector(
      onTap: () async {
        setState(() => _idServicioSeleccionado = s.idServicio);
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CalendarioScreen(servicio: s)),
        );
        if (mounted) setState(() => _idServicioSeleccionado = null);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: estaSeleccionado ? naranjaLogo : Colors.transparent, width: 2),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () => _toggleFavorito(s, esFavorito),
              icon: Icon(esFavorito ? Icons.favorite : Icons.favorite_border, color: esFavorito ? naranjaLogo : Colors.grey[400]),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.nombre, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: estaSeleccionado ? naranjaLogo : textoPrincipal)),
                  Text(s.tipoServicio.nombre.toUpperCase(), style: TextStyle(color: naranjaLogo, fontSize: 11, fontWeight: FontWeight.bold)),
                  Text(s.descripcion, style: const TextStyle(color: Colors.black54, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Text("${s.precio}€", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: naranjaLogo)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(child: Text("No se encontraron servicios", style: TextStyle(color: Colors.grey[600])));
  }
}