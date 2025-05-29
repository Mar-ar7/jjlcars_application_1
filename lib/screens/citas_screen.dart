import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/cita.dart';

class CitasScreen extends StatefulWidget {
  const CitasScreen({super.key});

  @override
  State<CitasScreen> createState() => _CitasScreenState();
}

class _CitasScreenState extends State<CitasScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _citas = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarCitas();
  }

  Future<void> _cargarCitas() async {
    try {
     final citasRaw = await _apiService.getData<Cita>('citas.php', (json) => Cita.fromJson(json));


      print('Citas cargadas: $citasRaw'); // Log para depuración

      final citas = List<Map<String, dynamic>>.from(citasRaw);

      setState(() {
        _citas = citas;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar las citas: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Citas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _cargarCitas();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() => _isLoading = true);
                          _cargarCitas();
                        },
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : _citas.isEmpty
                  ? const Center(child: Text('No hay citas programadas'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _citas.length,
                      itemBuilder: (context, index) {
                        final cita = _citas[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(
                              cita['nombre'] ?? 'Sin nombre',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Text('Correo: ${cita['correo'] ?? 'N/A'}'),
                                Text('Fecha: ${cita['fecha'] ?? 'N/A'}'),
                                Text('Hora: ${cita['hora'] ?? 'N/A'}'),
                                Text('Estado: ${cita['status'] ?? 'Pendiente'}'),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/nueva_cita').then((_) => _cargarCitas());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
