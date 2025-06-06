import 'package:flutter/material.dart';
import '../widgets/custom_drawer.dart';
import '../main.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

// Define a simple data class for the chart (Ensuring it's at the top level)
class CitaData {
  CitaData(this.state, this.count, [this.color]);
  final String state;
  final int count;
  final Color? color;
}

// Typedef fuera de la clase
typedef CitaPorTipoEntry = MapEntry<String, Map<String, double>>;

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const HomeScreen({Key? key, required this.userData}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  List<Map<String, dynamic>> empleados = [];
  bool isLoading = true;

  // State variables for cita statistics
  CitaStats? _citaStats; // Now holds CitaStats object
  bool _isLoadingCitaStats = true;
  String? _citaStatsError;

  int _totalClientes = 0;
  bool _isLoadingClientStats = true;
  String? _clientStatsError;

  int _totalVehiculos = 0;
  bool _isLoadingVehiculoStats = true;
  String? _vehiculoStatsError;

  List<Map<String, dynamic>> _vehiculosPorMarca = [];
  bool _isLoadingVehiculosMarca = true;
  String? _vehiculosMarcaError;

  Map<String, Map<String, double>> _citasPorTipoYMes = {};
  bool _isLoadingCitasPorTipo = true;
  String? _citasPorTipoError;

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    cargarEmpleados();
    _loadAllStats();
    _loadVehiculosPorMarca();
    _loadCitasPorTipoYMes();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Reload stats when returning to the app if it was inactive or paused
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

    // Use Future.wait to load all stats concurrently
    await Future.wait([
      _loadCitaStats(),
      _loadClientStats(),
      _loadVehiculoStats(),
    ]).catchError((e) { // Catch errors from Future.wait
       print('Error loading all stats: $e');
       // Individual error handling is done in each load method
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
      final response = await _apiService.getCitaStats(); // Use ApiService method
      setState(() {
        _citaStats = response;
        _isLoadingCitaStats = false;
      });
    } catch (e) {
      setState(() {
        _citaStatsError = e.toString();
        _isLoadingCitaStats = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar estadísticas de citas: ${e.toString()}'),
            duration: const Duration(seconds: 3),
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

  Future<void> _loadVehiculosPorMarca() async {
    setState(() {
      _isLoadingVehiculosMarca = true;
      _vehiculosMarcaError = null;
    });
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2/jjlcars_application_1/api/vehiculos_stats.php'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          setState(() {
            _vehiculosPorMarca = List<Map<String, dynamic>>.from(decoded['data']);
            _isLoadingVehiculosMarca = false;
          });
        } else {
          throw Exception(decoded['message'] ?? 'Error desconocido al obtener vehículos por marca');
        }
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _vehiculosMarcaError = e.toString();
        _isLoadingVehiculosMarca = false;
      });
    }
  }

  Future<void> _loadCitasPorTipoYMes() async {
    setState(() {
      _isLoadingCitasPorTipo = true;
      _citasPorTipoError = null;
    });
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2/jjlcars_application_1/api/citas_por_tipo_mes.php'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          setState(() {
            _citasPorTipoYMes = Map<String, Map<String, double>>.from(
              (decoded['data'] as Map<String, dynamic>).map((mes, tipos) => MapEntry(
                mes,
                Map<String, double>.from((tipos as Map<String, dynamic>).map((tipo, monto) => MapEntry(tipo, (monto as num).toDouble()))),
              )),
            );
            _isLoadingCitasPorTipo = false;
          });
        } else {
          throw Exception(decoded['message'] ?? 'Error desconocido al obtener proyección de ventas');
        }
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _citasPorTipoError = e.toString();
        _isLoadingCitasPorTipo = false;
      });
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
        onRefresh: _loadAllStats, // Refresh all stats on pull down
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(),
              const SizedBox(height: 24),
              _buildStatistics(),
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
        // Gráfica de Proyección de Ventas por Categoría
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
                  'Proyección de Ventas por Categoría',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _isLoadingCitasPorTipo
                    ? Center(child: CircularProgressIndicator())
                    : _citasPorTipoError != null
                        ? Center(child: Text('Error al cargar proyección: $_citasPorTipoError'))
                        : _citasPorTipoYMes.isEmpty
                            ? Center(child: Text('No hay datos de ventas para mostrar'))
                            : SfCartesianChart(
                                primaryXAxis: CategoryAxis(
                                  title: AxisTitle(text: 'Mes'),
                                  labelRotation: 30,
                                  labelIntersectAction: AxisLabelIntersectAction.wrap,
                                ),
                                primaryYAxis: NumericAxis(
                                  title: AxisTitle(text: 'Ventas en USD'),
                                  numberFormat: NumberFormat.simpleCurrency(name: 'USD'),
                                ),
                                legend: Legend(isVisible: true, position: LegendPosition.top, overflowMode: LegendItemOverflowMode.wrap),
                                series: _buildBarSeriesCitasPorTipo(),
                              ),
                if (_citaStats != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Ingresos por Citas Aprobadas: ${NumberFormat.simpleCurrency(name: 'USD').format(_citaStats!.totalRevenue)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Gráfica de Vehículos por Marca (Barras)
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
                  'Inventario de Vehículos por Marca',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _isLoadingVehiculosMarca
                    ? Center(child: CircularProgressIndicator())
                    : _vehiculosMarcaError != null
                        ? Center(child: Text('Error al cargar vehículos: $_vehiculosMarcaError'))
                        : _vehiculosPorMarca.isEmpty
                            ? Center(child: Text('No hay datos de vehículos para mostrar'))
                            : SfCartesianChart(
                                primaryXAxis: CategoryAxis(title: AxisTitle(text: 'Marca')),
                                primaryYAxis: NumericAxis(title: AxisTitle(text: 'Cantidad')),
                                series: <CartesianSeries<Map<String, dynamic>, String>>[
                                  ColumnSeries<Map<String, dynamic>, String>(
                                    dataSource: _vehiculosPorMarca,
                                    xValueMapper: (data, _) => data['marca'],
                                    yValueMapper: (data, _) => data['cantidad'],
                                    dataLabelSettings: DataLabelSettings(isVisible: true),
                                    pointColorMapper: (data, _) {
                                      switch ((data['marca'] as String).toLowerCase()) {
                                        case 'audi':
                                          return Colors.redAccent;
                                        case 'bmw':
                                          return Colors.blueAccent;
                                        case 'chevrolet':
                                          return Colors.amber;
                                        case 'ferrari':
                                          return Colors.deepOrange;
                                        default:
                                          return Colors.grey;
                                      }
                                    },
                                  ),
                                ],
                              ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Tarjetas de resumen
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Ingresos por Citas Aprobadas:  24${_citaStats?.totalRevenue.toStringAsFixed(2) ?? '0.00'}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green[700],
          ),
        ),
      ],
    );
  }

  List<CartesianSeries<CitaPorTipoEntry, String>> _buildBarSeriesCitasPorTipo() {
    final Set<String> tipos = <String>{};
    _citasPorTipoYMes.values.forEach((Map<String, double> mapa) => tipos.addAll(mapa.keys));
    final List<Color> colores = [Colors.purple, Colors.green, Colors.orange];
    int colorIndex = 0;
    return tipos.map((String tipo) {
      final Color color = colores[colorIndex++ % colores.length];
      return ColumnSeries<CitaPorTipoEntry, String>(
        dataSource: _citasPorTipoYMes.entries.map((e) => MapEntry(e.key, e.value)).toList(),
        xValueMapper: (entry, _) => entry!.key,
        yValueMapper: (entry, _) => entry!.value[tipo] ?? 0.0,
        name: tipo,
        color: color,
        dataLabelSettings: DataLabelSettings(isVisible: true),
      );
    }).toList();
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