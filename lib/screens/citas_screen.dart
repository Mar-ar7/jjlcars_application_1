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
  List<Cita> _citas = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarCitas();
  }

  Future<void> _cargarCitas() async {
  try {
    final citas = await _apiService.getCitas();
    setState(() {
      _citas = citas;
      _isLoading = false;
      _error = null;
    });
  } catch (e) {
    print('Error al cargar citas: $e');
    setState(() {
      _error = 'Error al cargar las citas: $e';
      _isLoading = false;
    });
  }
}

  Future<void> _actualizarStatus(Cita cita, String nuevoStatus) async {
    try {
      await _apiService.postData(
        'actualizar_cita_status.php',
        {
          'id': cita.id.toString(),
          'status': nuevoStatus,
        },
      );
      setState(() {
        cita.status = nuevoStatus;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar status: $e')),
      );
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
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _citas.isEmpty
                  ? const Center(child: Text('No hay citas registradas'))
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
                            leading: CircleAvatar(
                              child: Text(
                                cita.nombre.isNotEmpty
                                    ? cita.nombre[0].toUpperCase()
                                    : '?',
                              ),
                            ),
                            title: Text('${cita.tipoCita} - ${cita.nombre}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Correo: ${cita.correo}'),
                                Text('Tipo compra: ${cita.tipoCompra}'),
                                Text('Precio: Q${cita.precio}'),
                                Text('Fecha: ${cita.fecha} ${cita.hora}'),
                                Text('Status: ${cita.status}'),
                              ],
                            ),
                            trailing: DropdownButton<String>(
                              value: cita.status,
                              items: const [
                                DropdownMenuItem(value: 'Pendiente', child: Text('Pendiente')),
                                DropdownMenuItem(value: 'Aprobada', child: Text('Aprobada')),
                                DropdownMenuItem(value: 'Cancelada', child: Text('Cancelada')),
                              ],
                              onChanged: (nuevoStatus) {
                                if (nuevoStatus != null && nuevoStatus != cita.status) {
                                  _actualizarStatus(cita, nuevoStatus);
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}