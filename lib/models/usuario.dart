class Usuario {
  final int id;
  final String usuario;
  final String nombre;
  final String tipoUsuario;
  
  Usuario({
    required this.id,
    required this.usuario,
    required this.nombre,
    required this.tipoUsuario,
  });
  
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      usuario: json['Usuario'],
      nombre: json['Nombre'],
      tipoUsuario: json['TipoUsuario'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'Usuario': usuario,
      'Nombre': nombre,
      'TipoUsuario': tipoUsuario,
    };
  }
} 