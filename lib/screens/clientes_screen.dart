import 'package:flutter/material.dart';
import '../services/cliente_service.dart';
import '../models/cliente.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final ClienteService _clienteService = ClienteService();
  List<Cliente> _clientes = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarClientes();
  }

  Future<void> _cargarClientes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final clientes = await _clienteService.obtenerClientes();
      setState(() {
        _clientes = clientes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar los clientes: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _mostrarFormularioCliente({Cliente? cliente}) async {
    final formKey = GlobalKey<FormState>();
    final nombreController = TextEditingController(text: cliente?.nombre ?? '');
    final correoController = TextEditingController(text: cliente?.correo ?? '');
    final mensajeController = TextEditingController(text: cliente?.mensaje ?? '');
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(cliente == null ? 'Agregar Cliente' : 'Editar Cliente'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nombreController,
                        decoration: const InputDecoration(labelText: 'Nombre'),
                        validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
                      ),
                      TextFormField(
                        controller: correoController,
                        decoration: const InputDecoration(labelText: 'Correo'),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Campo obligatorio';
                          if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+
').hasMatch(v)) return 'Correo inválido';
                          return null;
                        },
                        keyboardType: TextInputType.emailAddress,
                      ),
                      TextFormField(
                        controller: mensajeController,
                        decoration: const InputDecoration(labelText: 'Mensaje (opcional)'),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setState(() => isLoading = true);
                          try {
                            final fields = {
                              'nombre': nombreController.text,
                              'correo': correoController.text,
                              'mensaje': mensajeController.text,
                            };
                            if (cliente != null) fields['id'] = cliente.id.toString();
                            if (cliente == null) {
                              await _clienteService.crearCliente(fields);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cliente creado')));
                            } else {
                              await _clienteService.actualizarCliente(fields);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cliente actualizado')));
                            }
                            if (mounted) {
                              Navigator.pop(context);
                              _cargarClientes();
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                          } finally {
                            setState(() => isLoading = false);
                          }
                        },
                  child: Text(cliente == null ? 'Crear' : 'Actualizar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmarEliminarCliente(Cliente cliente) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar el cliente ${cliente.nombre}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      try {
        await _clienteService.eliminarCliente(cliente.id);
        _cargarClientes();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cliente eliminado'), backgroundColor: Colors.green));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
        }
      }
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
            onPressed: _cargarClientes,
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
                        onPressed: _cargarClientes,
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
                        final c = _clientes[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              child: Text(
                                (c.nombre.isNotEmpty)
                                  ? c.nombre[0].toUpperCase()
                                  : '?',
                              ),
                            ),
                            title: Text(c.nombre),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Text('Correo: ${c.correo}'),
                                if (c.mensaje != null && c.mensaje!.isNotEmpty)
                                  Text(
                                    'Mensaje: ${c.mensaje}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _mostrarFormularioCliente(cliente: c),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  color: Colors.red,
                                  onPressed: () => _confirmarEliminarCliente(c),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormularioCliente(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
