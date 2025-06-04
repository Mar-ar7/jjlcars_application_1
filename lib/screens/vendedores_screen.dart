import 'package:flutter/material.dart';
import '../widgets/custom_drawer.dart';

class VendedoresScreen extends StatelessWidget {
  final List<Map<String, dynamic>> vendedores = [
    {'nombre': 'Carlos Ramírez', 'ventas': 12},
    {'nombre': 'Sofía Aguilar', 'ventas': 18},
    {'nombre': 'José Torres', 'ventas': 9},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Vendedores')),
      drawer: CustomDrawer(),
      body: ListView.builder(
        itemCount: vendedores.length,
        itemBuilder: (_, i) {
          final v = vendedores[i];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: CircleAvatar(
                child: Text(v['nombre']![0]),
                backgroundColor: Colors.teal.shade300,
              ),
              title: Text(v['nombre']),
              subtitle: Text('Ventas realizadas: ${v['ventas']}'),
              trailing: Icon(Icons.star, color: Colors.amber),
            ),
          );
        },
      ),
    );
  }
}
