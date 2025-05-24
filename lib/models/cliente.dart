class Cliente {
  final String nombre;
  final String correo;
  final String mensaje;
  final String fecha;

  Cliente({
    required this.nombre,
    required this.correo,
    required this.mensaje,
    required this.fecha,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      nombre: json['nombre'],
      correo: json['correo'] ?? '',
      mensaje: json['mensaje'],
      fecha: json['fecha_registro'],
    );
  }
}
