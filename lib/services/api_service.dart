import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/vehiculo.dart';
import '../models/usuario.dart';

class ApiService {
  final String baseUrl = ApiConfig.baseUrl;
  
  // Método genérico para obtener datos
  Future<List<dynamic>> getData(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al obtener datos de $endpoint');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Método genérico para enviar datos
  Future<Map<String, dynamic>> postData(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? error['message'] ?? 'Error al enviar datos a $endpoint');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
  
  // Autenticación
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'Usuario': username,
          'password': password,
        }),
      );

      print('URL de login: ${Uri.parse('$baseUrl/login.php')}');
      print('Código de respuesta: ${response.statusCode}');
      print('Respuesta: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error de servidor: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error de conexión: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Map<String, dynamic>> registro({
    required String nombre,
    required String usuario,
    required String password,
  }) async {
    return postData('registro.php', {
      'Nombre': nombre,
      'Usuario': usuario,
      'password': password,
      'TipoUsuario': 'Usuario', // Por defecto se registra como usuario normal
    });
  }

  // Vehículos
  Future<List<Vehiculo>> getVehiculos() async {
    final data = await getData('vehiculos.php');
    return data.map((json) => Vehiculo.fromJson(json)).toList();
  }

  // Citas
  Future<bool> agendarCita(String nombre, String correo, DateTime fecha, String hora) async {
    final response = await postData('procesar_cita.php', {
      'nombre': nombre,
      'correo': correo,
      'fecha': fecha.toIso8601String().split('T')[0],
      'hora': hora,
    });
    return response['success'] ?? false;
  }

  // Contacto
  Future<bool> enviarContacto(String nombre, String correo, String mensaje) async {
    final response = await postData('guardar_contacto.php', {
      'nombre': nombre,
      'correo': correo,
      'mensaje': mensaje,
    });
    return response['success'] ?? false;
  }

  // Compras
  Future<bool> realizarCompra(String clienteNombre, String clienteEmail, int vehiculoId, int cantidad, double totalPrecio) async {
    final response = await postData('nueva_compra.php', {
      'cliente_nombre': clienteNombre,
      'cliente_email': clienteEmail,
      'vehiculo_id': vehiculoId.toString(),
      'cantidad': cantidad.toString(),
      'total_precio': totalPrecio.toString(),
    });
    return response['success'] ?? false;
  }

  // Métodos similares para ventas, empleados y clientes
  // Implementa los métodos según tus necesidades
}
