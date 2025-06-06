import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vehiculo.dart';

class VehiculoService {
  static const String baseUrl = 'http://10.0.2.2/jjlcars_application_1/api';

  Future<List<Vehiculo>> obtenerVehiculos() async {
    final response = await http.get(Uri.parse('$baseUrl/obtener_vehiculos.php'));
    final data = json.decode(response.body);
    if (data['success'] == true && data['vehiculos'] != null) {
      return (data['vehiculos'] as List)
          .map((json) => Vehiculo.fromJson(json))
          .toList();
    } else {
      throw Exception(data['error'] ?? 'Error al obtener vehículos');
    }
  }

  Future<Vehiculo> crearVehiculo(Map<String, String> fields, String? imagePath) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/crear_vehiculo.php'));
    fields.forEach((key, value) => request.fields[key] = value);
    if (imagePath != null) {
      request.files.add(await http.MultipartFile.fromPath('imagen', imagePath));
    }
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final data = json.decode(response.body);
    if (data['success'] == true && data['vehiculo'] != null) {
      return Vehiculo.fromJson(data['vehiculo']);
    } else {
      throw Exception(data['error'] ?? 'Error al crear vehículo');
    }
  }

  Future<Vehiculo> actualizarVehiculo(Map<String, String> fields, String? imagePath) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/actualizar_vehiculo.php'));
    fields.forEach((key, value) => request.fields[key] = value);
    if (imagePath != null) {
      request.files.add(await http.MultipartFile.fromPath('imagen', imagePath));
    }
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final data = json.decode(response.body);
    if (data['success'] == true && data['vehiculo'] != null) {
      return Vehiculo.fromJson(data['vehiculo']);
    } else {
      throw Exception(data['error'] ?? 'Error al actualizar vehículo');
    }
  }

  Future<void> eliminarVehiculo(int id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/eliminar_vehiculo.php'),
      body: {'id': id.toString()},
    );
    final data = json.decode(response.body);
    if (data['success'] != true) {
      throw Exception(data['error'] ?? 'Error al eliminar vehículo');
    }
  }
} 