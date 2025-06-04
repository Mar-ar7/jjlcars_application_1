class Empleado {
  final String nombre;
  final String usuario;
  final String tipo;

  Empleado({
    required this.nombre,
    required this.usuario,
    required this.tipo,
  });

  factory Empleado.fromJson(Map<String, dynamic> json) {
    return Empleado(
      nombre: json['Nombre'],
      usuario: json['Usuario'],
      tipo: json['TipoUsuario'],
    );
  }
}
