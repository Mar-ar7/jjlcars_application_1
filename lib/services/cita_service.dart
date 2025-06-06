import 'dart:convert';
import 'dart:async';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../models/cita.dart';

class CitaService {
   static const String baseUrl = 'http://10.0.2.2/jjlcars_application_1/api'; // Ajusta según tu entorno

  Future<List<Cita>> obtenerCitas() async {
    try {
      developer.log('Intentando obtener citas desde: $baseUrl/obtener_citas.php');

      final response = await http.get(
        Uri.parse('$baseUrl/obtener_citas.php'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('La solicitud para obtener citas tardó demasiado');
        },
      );

      developer.log('Código de estado: ${response.statusCode}');
      developer.log('Respuesta del servidor: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          developer.log('Respuesta vacía del servidor');
          throw Exception('La respuesta del servidor está vacía');
        }

        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (!jsonResponse.containsKey('success') || !jsonResponse['success']) {
          final errorMsg = jsonResponse['error'] ?? 'Error desconocido al obtener citas';
          developer.log('Error en respuesta: $errorMsg');
          throw Exception(errorMsg);
        }

        if (!jsonResponse.containsKey('citas')) {
          throw Exception('Respuesta inválida: no contiene campo citas');
        }

        final List<dynamic> citasJson = jsonResponse['citas'];

        if (citasJson.isEmpty) {
          developer.log('No se encontraron citas');
          return [];
        }

        final List<Cita> citas = citasJson.map((json) {
          developer.log('JSON recibido: $json');
          try {
            return Cita.fromJson(json);
          } catch (e) {
            developer.log('Error al convertir cita: $e');
            developer.log('JSON problemático: $json');
            rethrow;
          }
        }).toList();

        developer.log('Citas convertidas exitosamente: ${citas.length}');
        return citas;
      } else {
        throw Exception('Error al obtener citas: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      developer.log('Error al obtener citas', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<bool> actualizarStatusCita(int id, String status) async {
    try {
      developer.log('Intentando actualizar status de cita: ID=$id, Status=$status');

      final response = await http.post(
        Uri.parse('$baseUrl/actualizar_cita_status.php'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id': id,
          'status': status,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('La solicitud para actualizar el status tardó demasiado');
        },
      );

      developer.log('Código de estado: ${response.statusCode}');
      developer.log('Respuesta del servidor: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          developer.log('Status actualizado exitosamente');
          return true;
        } else {
          final errorMsg = jsonResponse['message'] ?? 'Error desconocido al actualizar status';
          developer.log('Error en respuesta: $errorMsg');
          throw Exception(errorMsg);
        }
      } else {
        throw Exception('Error al actualizar status: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      developer.log('Error al actualizar status de cita', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
