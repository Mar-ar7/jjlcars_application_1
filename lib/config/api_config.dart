class ApiConfig {
  // URL base para el backend PHP en XAMPP
  // Usa la IP de tu computadora cuando pruebes en un dispositivo o emulador
  static const String baseUrl = 'http://10.0.2.2/jjlcars_application_1/api';  // Para emulador Android
  // static const String baseUrl = 'http://localhost/jjlcars_application_1/api';  // Para desarrollo local
  // static const String baseUrl = 'http://192.168.1.107:80/jjlcars/api';  // Para dispositivo físico
  
  // Autenticación
  static const String login = '/login.php';
  static const String registro = '/registro.php';
  static const String logout = '/logout.php';
  
  // Vehículos
  static const String vehiculos = '/vehiculos.php';
  static const String vehiculoDetalle = '/vehiculo_detalle.php';
  
  // Compras/Ventas
  static const String compras = '/compras.php';
  static const String nuevaCompra = '/nueva_compra.php';
  
  // Citas
  static const String citas = '/citas.php';
  static const String nuevaCita = '/procesar_cita.php';
  
  // Contacto
  static const String contacto = '/guardar_contacto.php';
  
  // Usuarios
  static const String usuarios = '/usuarios.php';
  static const String registroUsuario = '/registro_usuario.php';
}