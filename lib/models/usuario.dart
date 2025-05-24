class Usuario {
  final int id;
  final String usuario;
  final String nombre;
  final String tipoUsuario;
  final String estado;
  final String? estadoMensaje;
  final DateTime? estadoHasta;
  final String? avatar;
  
  Usuario({
    required this.id,
    required this.usuario,
    required this.nombre,
    required this.tipoUsuario,
    this.estado = 'Disponible',
    this.estadoMensaje,
    this.estadoHasta,
    this.avatar,
  });
  
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: int.parse(json['id'].toString()),
      usuario: json['Usuario'] ?? '',
      nombre: json['Nombre'] ?? '',
      tipoUsuario: json['TipoUsuario'] ?? '',
      estado: json['estado'] ?? 'Disponible',
      estadoMensaje: json['estado_mensaje'],
      estadoHasta: json['estado_hasta'] != null ? DateTime.parse(json['estado_hasta']) : null,
      avatar: json['avatar'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'Usuario': usuario,
      'Nombre': nombre,
      'TipoUsuario': tipoUsuario,
      'estado': estado,
      'estado_mensaje': estadoMensaje,
      'estado_hasta': estadoHasta?.toIso8601String(),
      'avatar': avatar,
    };
  }
} 