import 'package:flutter/material.dart';
import '../../services/servicio_service.dart';
import '../../models/servicios/servicio_model.dart';
import '../../models/servicios/tipo_servicio_model.dart';

class ServiciosScreen extends StatefulWidget {
  const ServiciosScreen({super.key});

  @override
  _ServiciosScreenState createState() => _ServiciosScreenState();
}

class _ServiciosScreenState extends State<ServiciosScreen> {
  final ServicioService _servicioService = ServicioService();
  final TextEditingController _searchController = TextEditingController();

  final Color naranjaLogo = const Color(0xFFFF6B00);
  final Color textoPrincipal = const Color(0xFF333333);
  final Color grisSuave = const Color(0xFFF5F5F5);

  List<Servicio> _todosLosServicios = [];
  List<TipoServicio> _tiposDeServicio = [];

  // ESTADOS
  bool _estaCargando = true;
  String? _categoriaSeleccionada;
  String _textoBusqueda = "";
  bool _filtroFavoritosActivo = false;
  int? _idServicioSeleccionado;

  // Simulación de múltiples favoritos (Esto vendrá de tu BD después)
  final Set<int> _idsFavoritos = {};

  @override
  void initState() {
    super.initState();
    _obtenerDatosDeAPI();
  }

  Future<void> _obtenerDatosDeAPI() async {
    try {
      final resultados = await Future.wait([
        _servicioService.obtenerTodos(),
        _servicioService.obtenerTipos(),
      ]);
      if (mounted) {
        setState(() {
          _todosLosServicios = resultados[0] as List<Servicio>;
          _tiposDeServicio = resultados[1] as List<TipoServicio>;
          _estaCargando = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _estaCargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_estaCargando)
      return Center(child: CircularProgressIndicator(color: naranjaLogo));

    // Filtrado lógico
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
          // 1. BUSCADOR
          Padding(
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
          ),

          // 2. FILTROS (TAMAÑO UNIFICADO Y POSICIÓN FIJA)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(flex: 2, child: _buildModernDropdown()),
                const SizedBox(width: 10),
                Expanded(flex: 1, child: _buildFavoriteFilterButton()),
              ],
            ),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),

          // 3. LISTA
          Expanded(
            child: listaFiltrada.isEmpty
                ? const Center(child: Text("No hay servicios disponibles"))
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
          menuMaxHeight: 300,
          hint: Text(
            "Categorías",
            style: TextStyle(
              color: naranjaLogo,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          icon: Icon(Icons.keyboard_arrow_down, color: naranjaLogo),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(10),
          items: [
            DropdownMenuItem(
              value: null,
              child: Text(
                "Todas",
                style: TextStyle(
                  color: _categoriaSeleccionada == null
                      ? naranjaLogo
                      : textoPrincipal,
                  fontWeight: _categoriaSeleccionada == null
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
            ..._tiposDeServicio.map((tipo) {
              bool selected = _categoriaSeleccionada == tipo.nombre;
              return DropdownMenuItem(
                value: tipo.nombre,
                child: Text(
                  tipo.nombre,
                  style: TextStyle(
                    color: selected ? naranjaLogo : textoPrincipal,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              );
            }),
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
        constraints: const BoxConstraints(minHeight: 110),
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
              color: estaSeleccionado
                  ? naranjaLogo.withOpacity(0.1)
                  : Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BOTÓN DE CORAZÓN INDEPENDIENTE
            GestureDetector(
              onTap: () {
                setState(() {
                  if (esFavorito) {
                    _idsFavoritos.remove(s.idServicio);
                  } else {
                    _idsFavoritos.add(s.idServicio);
                  }
                });
              },
              child: Icon(
                esFavorito ? Icons.favorite : Icons.favorite_border,
                color: esFavorito ? naranjaLogo : Colors.grey[400],
                size: 26,
              ),
            ),
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
                    softWrap: true,
                  ),
                  const SizedBox(height: 4),
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
                    softWrap: true,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
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
}
