class Cliente {
  final int id;
  final String nombre;
  final String correo;
  final String mensaje;

  Cliente({
    required this.id,
    required this.nombre,
    required this.correo,
    this.mensaje = '',
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nombre: json['nombre'],
      correo: json['correo'],
      mensaje: json['mensaje'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'correo': correo,
      'mensaje': mensaje,
    };
  }
}
