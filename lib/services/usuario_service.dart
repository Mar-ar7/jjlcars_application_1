import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../models/usuario.dart';
import 'dart:async';

class UsuarioService {
  // URL base para XAMPP incluyendo la carpeta api
  static const String baseUrl = 'http://10.0.2.2/jjlcars/api';  // Para Android Emulator
  // static const String baseUrl = 'http://localhost/jjlcars/api'; // Para web
  // static const String baseUrl = 'http://127.0.0.1/jjlcars/api'; // Alternativa para local

  Future<List<Usuario>> obtenerUsuarios() async {
    try {
      developer.log('Intentando obtener usuarios desde: $baseUrl/obtener_usuarios.php');
      
      final response = await http.get(
        Uri.parse('$baseUrl/obtener_usuarios.php'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('La solicitud tardó demasiado en completarse');
        },
      );
      
      developer.log('Código de estado: ${response.statusCode}');
      developer.log('Respuesta del servidor: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          developer.log('Respuesta vacía del servidor');
          throw Exception('La respuesta del servidor está vacía');
        }

        try {
          final Map<String, dynamic> jsonResponse = json.decode(response.body);
          developer.log('JSON decodificado: $jsonResponse');
          
          if (!jsonResponse.containsKey('success')) {
            developer.log('Error: La respuesta no contiene el campo success');
            throw Exception('Formato de respuesta inválido: falta el campo success');
          }

          if (!jsonResponse['success']) {
            developer.log('Error reportado por el servidor: ${jsonResponse['error']}');
            throw Exception(jsonResponse['error'] ?? 'Error desconocido del servidor');
          }

          if (!jsonResponse.containsKey('usuarios')) {
            developer.log('Error: La respuesta no contiene el campo usuarios');
            throw Exception('Formato de respuesta inválido: falta el campo usuarios');
          }

          final List<dynamic> usuariosJson = jsonResponse['usuarios'];
          developer.log('Número de usuarios encontrados: ${usuariosJson.length}');
          
          if (usuariosJson.isEmpty) {
            developer.log('No se encontraron usuarios');
            return [];
          }

          final List<Usuario> usuarios = usuariosJson.map((json) {
            try {
              return Usuario.fromJson(json);
            } catch (e) {
              developer.log('Error al convertir usuario: $e');
              developer.log('JSON problemático: $json');
              rethrow;
            }
          }).toList();

          developer.log('Usuarios convertidos exitosamente: ${usuarios.length}');
          return usuarios;

        } catch (e) {
          developer.log('Error al procesar JSON: $e');
          throw Exception('Error en el formato de la respuesta del servidor: $e');
        }
      } else {
        throw Exception('Error al obtener usuarios: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      developer.log(
        'Error al obtener usuarios',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
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
      developer.log('Intentando actualizar estado para usuario ID: $id');
      
      final response = await http.post(
        Uri.parse('$baseUrl/actualizar_estado_usuario.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'id': id,
          'estado': estado,
          'estado_mensaje': estadoMensaje,
          'estado_hasta': estadoHasta?.toIso8601String(),
          'usuario_id': usuarioId,
          'tipo_usuario': tipoUsuario.toLowerCase(),
        }),
      );

      developer.log('Respuesta del servidor (actualizar): ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] != null) {
          throw Exception(data['error']);
        }
        return Usuario.fromJson(data['usuario']);
      } else {
        throw Exception('Error al actualizar estado: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      developer.log(
        'Error al actualizar estado',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Error de conexión: $e');
    }
  }
} 