import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/vehiculo.dart';
import '../models/usuario.dart';
import '../models/cita.dart';

// Define a data model for Cita Statistics
class CitaStats {
  final Map<String, int> counts;
  final double totalRevenue;

  CitaStats({
    required this.counts,
    required this.totalRevenue,
  });

  factory CitaStats.fromJson(Map<String, dynamic> json) {
    Map<String, int> counts = {};
    if (json['counts'] != null) {
      (json['counts'] as Map<String, dynamic>).forEach((key, value) {
        counts[key] = int.tryParse(value.toString()) ?? 0;
      });
    }
    final totalRevenue = double.tryParse(json['totalRevenue'].toString()) ?? 0.0;

    return CitaStats(
      counts: counts,
      totalRevenue: totalRevenue,
    );
  }
}

class ApiService {
  final String baseUrl = ApiConfig.baseUrl;

  // Método genérico para obtener lista de objetos con parseo fuerte
  Future<List<T>> getData<T>(String endpoint, T Function(Map<String, dynamic>) fromJson) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (decoded['success'] == true) {
          // Suponemos que la clave con datos es el nombre del endpoint sin ".php"
          final key = endpoint.replaceAll('.php', '');
          if (decoded.containsKey(key)) {
            final List<dynamic> list = decoded[key];
            return list.map<T>((json) => fromJson(json)).toList();
          } else {
            throw Exception('Respuesta sin datos para $key');
          }
        } else {
          throw Exception(decoded['error'] ?? 'Error desconocido del servidor');
        }
      } else {
        throw Exception('Error al obtener datos de $endpoint: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Método genérico para enviar datos POST
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

  // Login
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'usuario': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error de servidor: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Registro de usuario
  Future<Map<String, dynamic>> registro({
    required String nombre,
    required String usuario,
    required String password,
    required String tipoUsuario,
  }) async {
    return postData('registro.php', {
      'nombre': nombre,
      'usuario': usuario,
      'password': password,
      'tipoUsuario': tipoUsuario,
    });
  }

  // Obtener lista de vehículos
  Future<List<Vehiculo>> getVehiculos() async {
    return getData<Vehiculo>('vehiculos.php', (json) => Vehiculo.fromJson(json));
  }

  // Obtener lista de citas
 Future<List<Cita>> getCitas() async {
  try {
    print('Iniciando carga de citas...'); 
    
    final response = await http.get(
      Uri.parse('$baseUrl/obtener_citas.php'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    print('Código de estado: ${response.statusCode}');
    print('Respuesta recibida: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(response.body);
      print('JSON decodificado: $decoded');

      // Verificar que tengamos la estructura correcta
      if (decoded['success'] == true && decoded['citas'] != null) {
        final List<dynamic> citasList = decoded['citas'];
        print('Lista de citas encontrada: ${citasList.length}');
        
        final citas = citasList.map((json) {
          print('Procesando cita individual: $json');
          try {
            return Cita.fromJson(json);
          } catch (e) {
            print('Error al procesar cita: $e');
            rethrow;
          }
        }).toList();

        print('Citas procesadas exitosamente');
        return citas;
      } else {
        throw Exception('La respuesta no contiene citas válidas');
      }
    } else {
      throw Exception('Error del servidor: ${response.statusCode}');
    }
  } catch (e, stack) {
    print('Error detallado: $e');
    print('Stack trace: $stack');
    throw Exception('Error al cargar citas: $e');
  }
}

  // Agendar cita
  Future<bool> agendarCita(String nombre, String correo, DateTime fecha, String hora) async {
    final response = await postData('procesar_cita.php', {
      'nombre': nombre,
      'correo': correo,
      'fecha': fecha.toIso8601String().split('T')[0],
      'hora': hora,
    });
    return response['success'] ?? false;
  }

  // Enviar contacto
  Future<bool> enviarContacto(String nombre, String correo, String mensaje) async {
    final response = await postData('guardar_contacto.php', {
      'nombre': nombre,
      'correo': correo,
      'mensaje': mensaje,
    });
    return response['success'] ?? false;
  }

  // Realizar compra
  Future<bool> realizarCompra(String clienteNombre, String clienteEmail, int vehiculoId, int cantidad, double totalPrecio) async {
    final response = await postData('nueva_compra.php', {
      'cliente_nombre': clienteNombre,
      'cliente_email': clienteEmail,
      'vehiculo_id': vehiculoId,
      'cantidad': cantidad,
      'total_precio': totalPrecio,
    });
    return response['success'] ?? false;
  }

  // Solicitar restablecimiento de contraseña
  Future<Map<String, dynamic>> requestPasswordReset({
    required String usuario,
  }) async {
    return postData('request_password_reset.php', {
      'usuario': usuario,
    });
  }

  // Restablecer contraseña con token
  Future<Map<String, dynamic>> resetPassword({
    required String usuario,
    required String nombre,
    required String newPassword,
  }) async {
    return postData('reset_password.php', {
      'usuario': usuario,
      'nombre': nombre,
      'new_password': newPassword,
    });
  }

  // Get Cita Statistics
  Future<CitaStats> getCitaStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/citas_stats.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (decoded['success'] == true && decoded['data'] != null) {
          // Use the new CitaStats model
          return CitaStats.fromJson(decoded['data']);
        } else {
          throw Exception(decoded['message'] ?? 'Error desconocido al obtener estadísticas de citas');
        }
      } else {
        throw Exception('Error del servidor al obtener estadísticas de citas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión al obtener estadísticas de citas: $e');
    }
  }

  // Get Client Statistics
  Future<int> getClientStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/clientes_stats.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (decoded['success'] == true && decoded['data'] != null && decoded['data']['totalClientes'] != null) {
          // The backend returns count as string, convert it to int
          return int.tryParse(decoded['data']['totalClientes'].toString()) ?? 0;
        } else {
          throw Exception(decoded['message'] ?? 'Error desconocido al obtener estadísticas de clientes');
        }
      } else {
        throw Exception('Error del servidor al obtener estadísticas de clientes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión al obtener estadísticas de clientes: $e');
    }
  }

  // Get Vehicle Statistics
  Future<int> getVehiculoStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/vehiculos_stats.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (decoded['success'] == true && decoded['data'] != null && decoded['data']['totalVehiculos'] != null) {
          // The backend returns count as string, convert it to int
          return int.tryParse(decoded['data']['totalVehiculos'].toString()) ?? 0;
        } else {
          throw Exception(decoded['message'] ?? 'Error desconocido al obtener estadísticas de vehículos');
        }
      }
       else {
        throw Exception('Error del servidor al obtener estadísticas de vehículos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión al obtener estadísticas de vehículos: $e');
    }
  }

  // Crear cita
  Future<bool> crearCita(Cita cita) async {
    final response = await http.post(
      Uri.parse('$baseUrl/crear_cita.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'tipoCita': cita.tipoCita,
        'precio': cita.precio,
        'nombre': cita.nombre,
        'correo': cita.correo,
        'fecha': cita.fecha,
        'hora': cita.hora,
        'status': cita.status,
        'vehiculo_id': cita.vehiculoId ?? 0,
      }),
    );
    final data = json.decode(response.body);
    if (data['success'] == true) return true;
    throw Exception(data['error'] ?? 'Error al crear cita');
  }

  // Actualizar cita
  Future<bool> actualizarCita(Cita cita) async {
    final response = await http.post(
      Uri.parse('$baseUrl/actualizar_cita.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'id': cita.id,
        'tipoCita': cita.tipoCita,
        'precio': cita.precio,
        'nombre': cita.nombre,
        'correo': cita.correo,
        'fecha': cita.fecha,
        'hora': cita.hora,
        'status': cita.status,
        'vehiculo_id': cita.vehiculoId ?? 0,
      }),
    );
    final data = json.decode(response.body);
    if (data['success'] == true) return true;
    throw Exception(data['error'] ?? 'Error al actualizar cita');
  }

  // Eliminar cita
  Future<bool> eliminarCita(int id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/eliminar_cita.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'id': id}),
    );
    final data = json.decode(response.body);
    if (data['success'] == true) return true;
    throw Exception(data['error'] ?? 'Error al eliminar cita');
  }

  // Aquí puedes agregar más métodos según necesites
}
