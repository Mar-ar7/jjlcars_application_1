import 'package:flutter/material.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/activity_chart.dart';
import '../main.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const HomeScreen({Key? key, required this.userData}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> empleados = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    cargarEmpleados();
  }

  Future<void> cargarEmpleados() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2/jjlcars/api/obtener_usuarios.php'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('La conexión tardó demasiado tiempo');
        },
      );

      if (response.statusCode == 200) {
        // Imprimir la respuesta para debug
        print('Respuesta del servidor: ${response.body}');
        
        if (response.body.isEmpty) {
          setState(() {
            empleados = [];
            isLoading = false;
          });
          return;
        }

        try {
          final List<dynamic> data = json.decode(response.body);
          setState(() {
            empleados = data.map((e) => Map<String, dynamic>.from(e)).toList();
            isLoading = false;
          });
        } catch (e) {
          print('Error al decodificar JSON: $e');
          print('Respuesta recibida: ${response.body}');
          throw FormatException('Error en el formato de la respuesta del servidor');
        }
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en cargarEmpleados: $e');
      setState(() {
        isLoading = false;
      });
      
      String errorMessage = 'Error al cargar usuarios';
      if (e is TimeoutException) {
        errorMessage = 'La conexión tardó demasiado tiempo. Intenta de nuevo.';
      } else if (e is SocketException) {
        errorMessage = 'No se pudo conectar al servidor. Verifica tu conexión.';
      } else if (e is FormatException) {
        errorMessage = 'Error en el formato de la respuesta del servidor.';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Reintentar',
              onPressed: () {
                cargarEmpleados();
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JJL Cars'),
        actions: [
          CircleAvatar(
            backgroundColor: AppColors.background,
            child: Icon(
              Icons.person_outline,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      drawer: const CustomDrawer(),
      body: RefreshIndicator(
        onRefresh: cargarEmpleados,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(),
              const SizedBox(height: 24),
              _buildStatistics(),
              const SizedBox(height: 24),
              _buildActivityChart(),
              const SizedBox(height: 24),
              _buildEmployeesList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¡Bienvenido, ${widget.userData['Nombre']}!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tipo de usuario: ${widget.userData['TipoUsuario']}',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistics() {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        '75%',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Reliability num.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade400,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.thumb_up,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        '97%',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Owner satisfaction',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityChart() {
    final List<FlSpot> dummyData = [
      FlSpot(0, 3),
      FlSpot(1, 1),
      FlSpot(2, 4),
      FlSpot(3, 2),
      FlSpot(4, 5),
      FlSpot(5, 3),
      FlSpot(6, 4),
    ];

    return ActivityChart(
      spots: dummyData,
      title: 'Car Activity',
    );
  }

  Widget _buildEmployeesList() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando usuarios...'),
          ],
        ),
      );
    }

    if (empleados.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'No hay usuarios disponibles',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: cargarEmpleados,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Estado de Usuarios',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: cargarEmpleados,
              tooltip: 'Actualizar lista',
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: empleados.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final empleado = empleados[index];
              final bool puedeEditarEstado = 
                widget.userData['TipoUsuario'].toString().toLowerCase() == 'administrador' ||
                empleado['id'].toString() == widget.userData['id'].toString();
              
              return ListTile(
                leading: Stack(
                  children: [
                    CircleAvatar(
                      backgroundColor: _getStatusColor(empleado['TipoUsuario'] ?? 'vendedor'),
                      child: Text(
                        empleado['Nombre']?.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _getEstadoColor(empleado['estado'] ?? 'Disponible'),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                title: Text(empleado['Nombre'] ?? 'Sin nombre'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(empleado['TipoUsuario'] ?? 'Sin rol'),
                    if (empleado['estado'] != null && empleado['estado'] != 'Disponible')
                      Text(
                        '${empleado['estado']}${empleado['estado_mensaje'] != null ? ': ${empleado['estado_mensaje']}' : ''}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    if (empleado['estado_hasta'] != null)
                      Text(
                        'Regresa: ${empleado['estado_hasta']}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
                trailing: puedeEditarEstado ? PopupMenuButton<String>(
                  onSelected: (value) => _mostrarDialogoEstado(empleado, value),
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem(
                      value: 'Disponible',
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text('Disponible'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'Atendiendo',
                      child: Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.orange),
                          SizedBox(width: 8),
                          Text('Atendiendo'),
                        ],
                      ),
                    ),
                    if (widget.userData['TipoUsuario'].toString().toLowerCase() == 'administrador')
                      const PopupMenuItem(
                        value: 'Ausente',
                        child: Row(
                          children: [
                            Icon(Icons.do_not_disturb_on, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Ausente'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'Fuera de oficina',
                      child: Row(
                        children: [
                          Icon(Icons.directions_walk, color: Colors.grey),
                          SizedBox(width: 8),
                          Text('Fuera de oficina'),
                        ],
                      ),
                    ),
                  ],
                ) : null,
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _mostrarDialogoEstado(Map<String, dynamic> empleado, String estado) async {
    final TextEditingController mensajeController = TextEditingController();
    DateTime? horaRegreso;

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cambiar estado a $estado'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: mensajeController,
                decoration: InputDecoration(
                  labelText: 'Mensaje (opcional)',
                  hintText: estado == 'Atendiendo' ? 'Ej: Reunión con cliente' : 'Mensaje de estado',
                ),
              ),
              const SizedBox(height: 16),
              if (estado != 'Disponible')
                ElevatedButton(
                  onPressed: () async {
                    final TimeOfDay? tiempo = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (tiempo != null) {
                      final now = DateTime.now();
                      horaRegreso = DateTime(
                        now.year,
                        now.month,
                        now.day,
                        tiempo.hour,
                        tiempo.minute,
                      );
                      if (horaRegreso!.isBefore(now)) {
                        horaRegreso = horaRegreso!.add(const Duration(days: 1));
                      }
                    }
                  },
                  child: const Text('Seleccionar hora de regreso'),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final response = await http.post(
                    Uri.parse('http://10.0.2.2/jjlcars/api/actualizar_estado_usuario.php'),
                    body: {
                      'id': empleado['id'].toString(),
                      'estado': estado,
                      'estado_mensaje': mensajeController.text,
                      'estado_hasta': horaRegreso?.toIso8601String(),
                    },
                  );

                  if (response.statusCode == 200) {
                    if (mounted) {
                      Navigator.pop(context);
                      cargarEmpleados();
                    }
                  } else {
                    throw Exception('Error al actualizar el estado');
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error al actualizar el estado')),
                    );
                  }
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Color _getStatusColor(String tipoUsuario) {
    switch (tipoUsuario.toLowerCase()) {
      case 'administrador':
        return Colors.purple;
      case 'gerente':
        return Colors.blue;
      case 'vendedor':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'disponible':
        return Colors.green;
      case 'atendiendo':
        return Colors.orange;
      case 'ausente':
        return Colors.red;
      case 'fuera de oficina':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
} 