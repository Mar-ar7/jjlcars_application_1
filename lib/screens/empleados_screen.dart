import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/empleado.dart';

class EmpleadosScreen extends StatefulWidget {
  @override
  _EmpleadosScreenState createState() => _EmpleadosScreenState();
}

class _EmpleadosScreenState extends State<EmpleadosScreen> {
  List<Empleado> empleados = [];
  bool cargando = true;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    cargarEmpleados();
  }

  Future<void> cargarEmpleados() async {
    try {
      final data = await _apiService.getData('usuarios.php');
      final lista = data.map<Empleado>((e) => Empleado.fromJson(e)).toList();
      setState(() {
        empleados = lista;
        cargando = false;
      });
    } catch (e) {
      setState(() => cargando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar empleados')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Empleados')),
      body: cargando
          ? Center(child: CircularProgressIndicator())
          : empleados.isEmpty
              ? Center(child: Text('No hay empleados registrados.'))
              : ListView.builder(
                  itemCount: empleados.length,
                  itemBuilder: (_, i) {
                    final e = empleados[i];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: Icon(Icons.person),
                        title: Text(e.nombre),
                        subtitle: Text('Usuario: ${e.usuario} - Rol: ${e.tipo}'),
                      ),
                    );
                  },
                ),
    );
  }
}
