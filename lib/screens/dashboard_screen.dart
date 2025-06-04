import 'package:flutter/material.dart';
import '../widgets/custom_drawer.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('JJLCars - Panel')),
      drawer: CustomDrawer(),
      body: Center(child: Text('Bienvenido al panel principal')),
    );
  }
}
