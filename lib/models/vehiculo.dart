class Vehiculo {
  final int id;
  final String marca;
  final String modelo;
  final String descripcion;
  final double precio;
  final String imagen;
  final int inventario;

  Vehiculo({
    required this.id,
    required this.marca,
    required this.modelo,
    required this.descripcion,
    required this.precio,
    required this.imagen,
    required this.inventario,
  });

  factory Vehiculo.fromJson(Map<String, dynamic> json) {
    return Vehiculo(
      id: int.parse(json['id'].toString()),
      marca: json['marca'],
      modelo: json['modelo'],
      descripcion: json['descripcion'],
      precio: double.parse(json['precio'].toString()),
      imagen: json['imagen'].toString().startsWith('http')
          ? json['imagen']
          : 'http://10.0.2.2/jjlcars_application_1/api/Imagen/${json['imagen']}',
      inventario: int.tryParse(json['inventario'].toString()) ?? 0,
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
      'inventario': inventario,
    };
  }
}
