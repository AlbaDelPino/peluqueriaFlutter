class ApiConfig {
  // Base URL - El corazón de tu conexión
  static const String baseUrl = 'http://192.168.7.13:8082';

  // --- AUTENTICACIÓN Y REGISTRO ---
  static const String loginUrl = '$baseUrl/api/auth/signin';
  static const String signupUrl = '$baseUrl/api/auth/signup'; // Usado en SignupScreen
  static const String googleLoginUrl = '$baseUrl/api/auth/google';
  static const String meUrl = '$baseUrl/api/auth/me'; // Usado en Perfil y Editar Perfil

  // --- GESTIÓN DE CLIENTES / PERFIL ---
  // Endpoint dinámico para PUT/GET de un cliente específico
  static String clientesUrl(int id) => '$baseUrl/clientes/$id';
  static const String uploadPhotoUrl = '$baseUrl/clientes/upload-photo';

  // --- RECUPERACIÓN DE CONTRASEÑA ---
  static String forgotPassword(String email) => 
      '$baseUrl/api/auth/forgot-password?email=$email';
  static const String resetPasswordUrl = '$baseUrl/api/auth/reset-password';

  // --- SERVICIOS Y CATEGORÍAS ---
  static const String serviciosUrl = '$baseUrl/servicio';
  static const String tiposServicioUrl = '$baseUrl/tiposervicio';

  // --- FAVORITOS ---
  static String favoritosCliente(int clienteId) => 
      '$baseUrl/api/favoritos/cliente/$clienteId';
  static String favoritoAccion(int clienteId, int servicioId) => 
      '$baseUrl/api/favoritos/cliente/$clienteId/servicio/$servicioId';

  // --- HORARIOS Y RESERVAS ---
  static const String buscarHorariosUrl = '$baseUrl/horarios/buscar';
  static const String reservasUrl = '$baseUrl/reservas';
  static const String plazasDisponiblesUrl = '$baseUrl/citas/disponible';
  static String misReservas(int clienteId) => '$baseUrl/api/reservas/cliente/$clienteId';

  // --- GALERÍA DE IMÁGENES ---
  static const String todasImagenesUrl = '$baseUrl/api/imagenes';
  static String imagenesPorServicio(int id) => 
      '$baseUrl/api/imagenes/servicio/$id';

  // --- CITAS ENDPOINTS ---
  // Obtener todas las citas de un cliente específico
  static String getCitasByCliente(int clienteId) => 
      "$baseUrl/citas/cliente/$clienteId";

  // Detalle de una cita o cancelación
  static String detalleCita(int citaId) => 
      "$baseUrl/citas/$citaId";

  // Endpoint para cancelar (si tu backend usa un path específico)
  static String cancelarCita(int citaId) => 
      "$baseUrl/citas/$citaId/cancelar";

  
  static String getDisponibilidad(String fecha, int horarioId) => 
    "$baseUrl/citas/disponible?fecha=$fecha&horarioId=$horarioId";

static const String reservarCitaUrl = "$baseUrl/citas/reservar";
}