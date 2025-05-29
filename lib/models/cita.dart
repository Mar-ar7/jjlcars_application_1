// lib/models/cita.dart
class Cita {
  final int id;
  final String tipoCita;
  final String tipoCompra;
  final int precio;
  final String nombre;
  final String correo;
  final String fecha;
  final String hora;
  final String status;

  Cita({
    required this.id,
    required this.tipoCita,
    required this.tipoCompra,
    required this.precio,
    required this.nombre,
    required this.correo,
    required this.fecha,
    required this.hora,
    required this.status,
  });

  factory Cita.fromJson(Map<String, dynamic> json) {
    return Cita(
      id: int.parse(json['id'].toString()),
      tipoCita: json['tipoCita'] ?? '',
      tipoCompra: json['tipoCompra'] ?? '',
      precio: int.parse(json['precio'].toString()),
      nombre: json['nombre'] ?? '',
      correo: json['correo'] ?? '',
      fecha: json['fecha'] ?? '',
      hora: json['hora'] ?? '',
      status: json['status'] ?? '',
    );
  }
}
