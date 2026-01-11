import 'package:flutter/material.dart';
import '../../services/servicio_service.dart';
import '../../services/user_preferences.dart';
import '../../models/servicios/servicio_model.dart';
import '../../models/servicios/tipo_servicio_model.dart';

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
    _obtenerDatosDeAPI();
  }

  Future<void> _obtenerDatosDeAPI() async {
    try {
      final int clienteId = await _prefs.userId;

      // Depuración: Si esto sale 0, el problema está en el guardado del Login
      print("DEBUG: Cargando datos para cliente ID: $clienteId");

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
          _idsFavoritos.addAll(resultados[2] as List<int>);
          _estaCargando = false;
        });

        if (_todosLosServicios.isEmpty) {
          print("DEBUG: La lista de servicios llegó vacía del servidor.");
        }
      }
    } catch (e) {
      print("Error cargando datos en ServiciosScreen: $e");
      if (mounted) setState(() => _estaCargando = false);
    }
  }

  // --- MÉTODOS DE CONSTRUCCIÓN DE UI (Iguales a los tuyos pero optimizados) ---

  @override
  Widget build(BuildContext context) {
    if (_estaCargando) {
      return Center(child: CircularProgressIndicator(color: naranjaLogo));
    }

    final listaFiltrada = _todosLosServicios.where((s) {
      final coincideCategoria =
          _categoriaSeleccionada == null ||
          s.tipoServicio.nombre == _categoriaSeleccionada;
      final coincideTexto = s.nombre.toLowerCase().contains(
        _textoBusqueda.toLowerCase(),
      );
      final coincideFavorito =
          !_filtroFavoritosActivo || _idsFavoritos.contains(s.idServicio);
      return coincideCategoria && coincideTexto && coincideFavorito;
    }).toList();

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildBuscador(),
          _buildFiltros(),
          const SizedBox(height: 12),
          const Divider(height: 1),
          Expanded(
            child: listaFiltrada.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: listaFiltrada.length,
                    itemBuilder: (context, index) =>
                        _buildServicioCard(listaFiltrada[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            _textoBusqueda.isEmpty
                ? "No hay servicios disponibles"
                : "No se encontraron resultados",
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          TextButton(
            onPressed: _obtenerDatosDeAPI,
            child: Text("Reintentar", style: TextStyle(color: naranjaLogo)),
          ),
        ],
      ),
    );
  }

  // --- COMPONENTES UI ---

  Widget _buildBuscador() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _textoBusqueda = value),
        decoration: InputDecoration(
          hintText: "Buscar un servicio...",
          prefixIcon: Icon(Icons.search, color: naranjaLogo),
          filled: true,
          fillColor: grisSuave,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFiltros() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(flex: 2, child: _buildModernDropdown()),
          const SizedBox(width: 10),
          Expanded(flex: 1, child: _buildFavoriteFilterButton()),
        ],
      ),
    );
  }

  Widget _buildModernDropdown() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: naranjaLogo.withOpacity(0.5), width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _categoriaSeleccionada,
          isExpanded: true,
          hint: Text(
            "Categorías",
            style: TextStyle(
              color: naranjaLogo,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          items: [
            DropdownMenuItem(value: null, child: Text("Todas")),
            ..._tiposDeServicio.map(
              (tipo) => DropdownMenuItem(
                value: tipo.nombre,
                child: Text(tipo.nombre),
              ),
            ),
          ],
          onChanged: (val) => setState(() => _categoriaSeleccionada = val),
        ),
      ),
    );
  }

  Widget _buildFavoriteFilterButton() {
    return GestureDetector(
      onTap: () =>
          setState(() => _filtroFavoritosActivo = !_filtroFavoritosActivo),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: _filtroFavoritosActivo ? naranjaLogo : grisSuave,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            "Favoritos",
            style: TextStyle(
              color: _filtroFavoritosActivo ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServicioCard(Servicio s) {
    bool estaSeleccionado = _idServicioSeleccionado == s.idServicio;
    bool esFavorito = _idsFavoritos.contains(s.idServicio);

    return GestureDetector(
      onTap: () => setState(() => _idServicioSeleccionado = s.idServicio),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: estaSeleccionado ? naranjaLogo : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeartIcon(s, esFavorito),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.nombre,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: estaSeleccionado ? naranjaLogo : textoPrincipal,
                    ),
                  ),
                  Text(
                    s.tipoServicio.nombre.toUpperCase(),
                    style: TextStyle(
                      color: naranjaLogo,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s.descripcion,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              "${s.precio}€",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: naranjaLogo,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeartIcon(Servicio s, bool esFavorito) {
    return GestureDetector(
      onTap: () async {
        final int clienteId = await _prefs.userId;
        if (clienteId == 0) return;

        setState(() {
          if (esFavorito)
            _idsFavoritos.remove(s.idServicio);
          else
            _idsFavoritos.add(s.idServicio);
        });

        bool exito = esFavorito
            ? await _servicioService.eliminarFavorito(clienteId, s.idServicio)
            : await _servicioService.agregarFavorito(clienteId, s.idServicio);

        if (!exito && mounted) {
          setState(() {
            if (esFavorito)
              _idsFavoritos.add(s.idServicio);
            else
              _idsFavoritos.remove(s.idServicio);
          });
        }
      },
      child: Icon(
        esFavorito ? Icons.favorite : Icons.favorite_border,
        color: esFavorito ? naranjaLogo : Colors.grey[400],
        size: 26,
      ),
    );
  }
}
