import 'package:flutter/material.dart';
import '../widgets/custom_drawer.dart';

class MarcasScreen extends StatelessWidget {
  final List<String> marcas = [
    'Ferrari',
    'Audi',
    'Chevrolet',
    'BMW',
    'Toyota',
    'Ford',
    'Honda',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Marcas Disponibles')),
      drawer: CustomDrawer(),
      body: ListView.builder(
        itemCount: marcas.length,
        itemBuilder: (_, i) {
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: Icon(Icons.directions_car),
              title: Text(marcas[i]),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                // Futuro: navegar a modelos de esa marca
              },
            ),
          );
        },
      ),
    );
  }
}
