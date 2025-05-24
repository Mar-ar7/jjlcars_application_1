import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';

class UsuarioService {
  static const String baseUrl = 'http://localhost/jjlcars/api';

  Future<List<Usuario>> obtenerUsuarios() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/obtener_usuarios.php'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Usuario.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener usuarios: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Usuario> actualizarEstado({
    required int id,
    required String estado,
    String? estadoMensaje,
    DateTime? estadoHasta,
    required int usuarioId,
    required String tipoUsuario,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/actualizar_estado_usuario.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id': id,
          'estado': estado,
          'estado_mensaje': estadoMensaje,
          'estado_hasta': estadoHasta?.toIso8601String(),
          'usuario_id': usuarioId,
          'tipo_usuario': tipoUsuario.toLowerCase(),
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] != null) {
          throw Exception(data['error']);
        }
        return Usuario.fromJson(data['usuario']);
      } else {
        throw Exception('Error al actualizar estado: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
} 