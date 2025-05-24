import 'package:flutter/material.dart';
import '../widgets/custom_drawer.dart';

class ProyeccionesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Proyecciones de Ventas')),
      drawer: CustomDrawer(),
      body: Center(
        child: Text(
          'Aquí se mostrarán proyecciones de ventas (gráficas, indicadores, etc.)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
