import 'package:flutter/material.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/activity_chart.dart';
import '../main.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const HomeScreen({Key? key, required this.userData}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  List<Map<String, dynamic>> empleados = [];
  bool isLoading = true;

  CitaStats? _citaStats;
  bool _isLoadingCitaStats = true;
  String? _citaStatsError;

  int _totalClientes = 0;
  bool _isLoadingClientStats = true;
  String? _clientStatsError;

  int _totalVehiculos = 0;
  bool _isLoadingVehiculoStats = true;
  String? _vehiculoStatsError;

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    cargarEmpleados();
    _loadAllStats();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadAllStats();
    }
  }

  Future<void> _loadAllStats() async {
    setState(() {
      _isLoadingCitaStats = true;
      _citaStatsError = null;
      _isLoadingClientStats = true;
      _clientStatsError = null;
      _isLoadingVehiculoStats = true;
      _vehiculoStatsError = null;
    });

    await Future.wait([
      _loadCitaStats(),
      _loadClientStats(),
      _loadVehiculoStats(),
    ]).catchError((e) {
      print('Error loading all stats: $e');
    });
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

  Future<void> _loadCitaStats() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2/jjlcars/api/obtener_estadisticas_citas.php'),
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
            _citaStats = null;
            _isLoadingCitaStats = false;
          });
          return;
        }

        try {
          final Map<String, dynamic> data = json.decode(response.body);
          setState(() {
            _citaStats = CitaStats.fromJson(data);
            _isLoadingCitaStats = false;
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
      print('Error en _loadCitaStats: $e');
      setState(() {
        _isLoadingCitaStats = false;
      });
      
      String errorMessage = 'Error al cargar estadísticas de citas';
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
                _loadCitaStats();
              },
            ),
          ),
        );
      }
    }
  }

  Future<void> _loadClientStats() async {
    setState(() {
      _isLoadingClientStats = true;
      _clientStatsError = null;
    });
    try {
      final totalClientes = await _apiService.getClientStats();
      setState(() {
        _totalClientes = totalClientes;
        _isLoadingClientStats = false;
      });
    } catch (e) {
      setState(() {
        _clientStatsError = e.toString();
        _isLoadingClientStats = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar estadísticas de clientes: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _loadVehiculoStats() async {
    setState(() {
      _isLoadingVehiculoStats = true;
      _vehiculoStatsError = null;
    });
    try {
      final totalVehiculos = await _apiService.getVehiculoStats();
      setState(() {
        _totalVehiculos = totalVehiculos;
        _isLoadingVehiculoStats = false;
      });
    } catch (e) {
      setState(() {
        _vehiculoStatsError = e.toString();
        _isLoadingVehiculoStats = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar estadísticas de vehículos: ${e.toString()}'),
            duration: const Duration(seconds: 3),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estadísticas Generales',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        // Citas Chart
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estadísticas de Citas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _isLoadingCitaStats
                    ? Center(child: CircularProgressIndicator())
                    : _citaStatsError != null
                        ? Center(child: Text('Error al cargar estadísticas de citas: $_citaStatsError'))
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildCitaStatsChart(),
                              const SizedBox(height: 16),
                              Text(
                                'Ingresos por Citas Aprobadas: \${_citaStats?.totalRevenue.toStringAsFixed(2) ?? 'N/A'}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Clients and Vehicles Stats
        Row(
          children: [
            Expanded(
              child: Card(
                 shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(15),
                 ),
                elevation: 4,
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
                              color: Colors.blue.shade400,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.people_alt_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          _isLoadingClientStats
                              ? CircularProgressIndicator()
                              : _clientStatsError != null
                                  ? Text('Error')
                                  : Text(
                                      '$_totalClientes',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Total Clientes',
                        style: TextStyle(
                          color: Colors.grey[600],
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
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
                              Icons.directions_car_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                           _isLoadingVehiculoStats
                              ? CircularProgressIndicator()
                              : _vehiculoStatsError != null
                                  ? Text('Error')
                                  : Text(
                                      '$_totalVehiculos',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Total Vehículos',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCitaStatsChart() {
    // Data model for the chart
    final List<CitaData> chartData = _citaStats?.entries.map((entry) {
      // Map states from backend to more user-friendly labels if needed
      String label = entry.key;
      switch (entry.key) {
        case 'aprobada':
          label = 'Aprobadas';
          break;
        case 'pendiente':
          label = 'Pendientes';
          break;
        case 'cancelada':
          label = 'Canceladas';
          break;
      }
      return CitaData(label, entry.value);
    }).toList() ?? [];

    return SfCircularChart(
      series: <CircularSeries>[ // Use CircularSeries for pie/doughnut charts
        PieSeries<CitaData, String>(
          dataSource: chartData,
          pointColorMapper:(CitaData data, _) => data.color, // Optional: Assign colors
          xValueMapper: (CitaData data, _) => data.state,
          yValueMapper: (CitaData data, _) => data.count,
          dataLabelSettings: DataLabelSettings(isVisible: true),
          enableTooltip: true,
        ),
      ],
      // Optional: Add title and legend
      // title: ChartTitle(text: 'Estadísticas de Citas'),
      legend: Legend(isVisible: true),
    );
  }

  // Define a simple data class for the chart
  class CitaData {
    CitaData(this.state, this.count, [this.color]);
    final String state;
    final int count;
    final Color? color;
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