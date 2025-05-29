import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../models/ventas.dart';
import 'dart:async';

class VentaService {
  static const String baseUrl = 'http://10.0.2.2/jjlcars_application_1/api';

  Future<List<Venta>> obtenerVentas() async {
    try {
      developer.log('Obteniendo ventas desde: $baseUrl/ventas.php');

      final response = await http.get(
        Uri.parse('$baseUrl/ventas.php'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      developer.log('Respuesta del servidor: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (!data['success']) {
          throw Exception(data['error'] ?? 'Error desconocido al obtener ventas');
        }

        final List<dynamic> ventasJson = data['ventas'];
        return ventasJson.map((json) => Venta.fromJson(json)).toList();
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      developer.log('Error al obtener ventas', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
