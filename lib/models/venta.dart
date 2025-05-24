class Venta {
  final String cliente;
  final String vehiculoId;
  final int cantidad;
  final double total;
  final String fecha;

  Venta({
    required this.cliente,
    required this.vehiculoId,
    required this.cantidad,
    required this.total,
    required this.fecha,
  });

  factory Venta.fromJson(Map<String, dynamic> json) {
    return Venta(
      cliente: json['cliente_nombre'],
      vehiculoId: json['vehiculo_id'].toString(),
      cantidad: int.tryParse(json['cantidad'].toString()) ?? 0,
      total: double.tryParse(json['total_precio'].toString()) ?? 0.0,
      fecha: json['fecha_compra'],
    );
  }
}
