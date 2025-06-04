class Venta {
  final int id;
  final String clienteNombre;
  final String vehiculoNombre;
  final double totalPrecio;
  final String fechaVenta;

  Venta({
    required this.id,
    required this.clienteNombre,
    required this.vehiculoNombre,
    required this.totalPrecio,
    required this.fechaVenta,
  });

  factory Venta.fromJson(Map<String, dynamic> json) {
    return Venta(
      id: int.parse(json['id'].toString()),
      clienteNombre: json['cliente_nombre'] ?? '',
      vehiculoNombre: json['vehiculo_nombre'] ?? '',
      totalPrecio: double.tryParse(json['total_precio'].toString()) ?? 0.0,
      fechaVenta: json['fecha_venta'] ?? '',
    );
  }
}
