import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../models/cliente.dart';
import 'dart:async';

class ClienteService {
  static const String baseUrl = 'http://10.0.2.2/jjlcars_application_1/api';

  Future<List<Cliente>> obtenerClientes() async {
    try {
      developer.log('Obteniendo clientes desde: $baseUrl/clientes.php');

      final response = await http.get(
        Uri.parse('$baseUrl/clientes.php'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      developer.log('Respuesta del servidor: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (!data['success']) {
          throw Exception(data['error'] ?? 'Error desconocido al obtener clientes');
        }

        final List<dynamic> clientesJson = data['clientes'];
        return clientesJson.map((json) => Cliente.fromJson(json)).toList();
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      developer.log('Error al obtener clientes', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<Cliente> crearCliente(Map<String, String> fields) async {
    final response = await http.post(
      Uri.parse('$baseUrl/crear_cliente.php'),
      body: fields,
    );
    final data = json.decode(response.body);
    if (data['success'] == true && data['cliente'] != null) {
      return Cliente.fromJson(data['cliente']);
    } else {
      throw Exception(data['error'] ?? 'Error al crear cliente');
    }
  }

  Future<Cliente> actualizarCliente(Map<String, String> fields) async {
    final response = await http.post(
      Uri.parse('$baseUrl/actualizar_cliente.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(fields),
    );
    final data = json.decode(response.body);
    if (data['success'] == true && data['cliente'] != null) {
      return Cliente.fromJson(data['cliente']);
    } else {
      throw Exception(data['error'] ?? 'Error al actualizar cliente');
    }
  }

  Future<void> eliminarCliente(int id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/eliminar_cliente.php'),
      body: {'id': id.toString()},
    );
    final data = json.decode(response.body);
    if (data['success'] != true) {
      throw Exception(data['error'] ?? 'Error al eliminar cliente');
    }
  }
}
