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
        if (decoded['success'] == true && decoded['data'] != null && decoded['data'] is List) {
          setState(() {
            _vehiculosPorMarca = List<Map<String, dynamic>>.from(decoded['data']);
            _isLoadingVehiculosMarca = false;
          });
        } else {
          throw Exception('La respuesta de vehículos no es una lista');
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
                  'Proyección de Ventas por Tipo de Compra',
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
} 