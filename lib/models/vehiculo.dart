class Vehiculo {
  final int id;
  final String marca;
  final String modelo;
  final String descripcion;
  final double precio;
  final String imagen;
  final DateTime fechaAgregado;

  Vehiculo({
    required this.id,
    required this.marca,
    required this.modelo,
    required this.descripcion,
    required this.precio,
    required this.imagen,
    required this.fechaAgregado,
  });

  factory Vehiculo.fromJson(Map<String, dynamic> json) {
    return Vehiculo(
      id: json['id'],
      marca: json['marca'],
      modelo: json['modelo'],
      descripcion: json['descripcion'],
      precio: double.parse(json['precio'].toString()),
      imagen: json['imagen'],
      fechaAgregado: DateTime.parse(json['fecha_agregado']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'marca': marca,
      'modelo': modelo,
      'descripcion': descripcion,
      'precio': precio,
      'imagen': imagen,
      'fecha_agregado': fechaAgregado.toIso8601String(),
    };
  }
}
