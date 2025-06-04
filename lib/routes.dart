import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/registro_screen.dart';
import 'screens/home_screen.dart';
import 'screens/vehiculos_screen.dart';
import 'screens/citas_screen.dart';
import 'screens/nueva_cita_screen.dart';
import 'screens/clientes_screen.dart';
import 'screens/ventas_screen.dart';
import 'screens/empleados_screen.dart';
import 'screens/marcas_screen.dart';
import 'screens/proyecciones_screen.dart';

final Map<String, WidgetBuilder> routes = {
  '/': (context) => const LoginScreen(),
  '/registro': (context) => const RegistroScreen(),
  '/home': (context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args == null) {
      return const LoginScreen();
    }
    return HomeScreen(userData: args);
  },
  '/vehiculos': (context) => const VehiculosScreen(),
  '/citas': (context) => const CitasScreen(),
  '/nueva_cita': (context) => const NuevaCitaScreen(),
  '/clientes': (context) => const ClientesScreen(),
  '/ventas': (context) => VentasScreen(),
  '/empleados': (context) => EmpleadosScreen(),
  '/marcas': (context) => MarcasScreen(),
  '/proyecciones': (context) => ProyeccionesScreen(),
  // Aquí agregaremos más rutas conforme creemos las pantallas
};

// Manejador de rutas desconocidas
Route<dynamic>? onUnknownRoute(RouteSettings settings) {
  return MaterialPageRoute(
    builder: (context) => Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: const Center(
        child: Text('Página no encontrada'),
      ),
    ),
  );
} 