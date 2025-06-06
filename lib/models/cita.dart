class Cita {
  final int id;
  final String tipoCita;
  final int precio;
  final String nombre;
  final String correo;
  final String fecha;
  final String hora;
  final String? fechaRegistro;
  String status;
  final int? vehiculoId;

  Cita({
    required this.id,
    required this.tipoCita,
    required this.precio,
    required this.nombre,
    required this.correo,
    required this.fecha,
    required this.hora,
    this.fechaRegistro,
    required this.status,
    this.vehiculoId,
  });

  factory Cita.fromJson(Map<String, dynamic> json) {
    return Cita(
      id: int.tryParse(json['id'].toString()) ?? 0,
      tipoCita: json['tipoCita'] ?? json['tipocita'] ?? '',
      precio: int.tryParse(json['precio'].toString()) ?? 0,
      nombre: json['nombre'] ?? '',
      correo: json['correo'] ?? '',
      fecha: json['fecha'] ?? '',
      hora: json['hora'] ?? '',
      fechaRegistro: json['fecha_registro']?.toString(),
      status: json['status'] ?? '',
      vehiculoId: json['vehiculo_id'] != null ? int.tryParse(json['vehiculo_id'].toString()) : null,
    );
  }
}