import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/cliente.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final ApiService _apiService = ApiService();
  List<Cliente> _clientes = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarClientes();
  }

  Future<void> _cargarClientes() async {
    try {
      final clientes = await _apiService.getData<Cliente>(
        'clientes.php',
        (json) => Cliente.fromJson(json),
      );
      setState(() {
        _clientes = clientes;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar los clientes: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _cargarClientes();
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
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() => _isLoading = true);
                          _cargarClientes();
                        },
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : _clientes.isEmpty
                  ? const Center(child: Text('No hay clientes registrados'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _clientes.length,
                      itemBuilder: (context, index) {
                        final cliente = _clientes[index];
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
                              (cliente.nombre != null && cliente.nombre.isNotEmpty)
                                ? cliente.nombre[0].toUpperCase()
                              : '?',
    ),
  ),
                            title: Text(cliente.nombre),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Text('Correo: ${cliente.correo}'),
                                if (cliente.mensaje != null)
                                  Text(
                                    'Mensaje: ${cliente.mensaje}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
