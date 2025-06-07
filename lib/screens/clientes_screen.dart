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
  TextEditingController _searchController = TextEditingController();
  String _search = '';

  @override
  void initState() {
    super.initState();
    _cargarClientes();
    _searchController.addListener(() {
      setState(() {
        _search = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                          final correo = v?.trim() ?? '';
                          if (correo.isEmpty) return 'Campo obligatorio';
                          if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(correo)) return 'Correo inválido';
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
                              'mensaje': mensajeController.text.isNotEmpty ? mensajeController.text : '',
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
    final clientesFiltrados = _clientes.where((c) => c.nombre.toLowerCase().contains(_search.toLowerCase())).toList();
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF5F7FA), // gris muy claro
            Color(0xFFE8EAED), // gris claro
            Color(0xFFDDE3EC), // gris más oscuro
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Clientes', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 2,
          iconTheme: const IconThemeData(color: Colors.black),
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
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            labelText: 'Buscar por nombre',
                            prefixIcon: const Icon(Icons.search, color: Colors.black54),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Mostrando ${clientesFiltrados.length} de ${_clientes.length} registros',
                            style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      Expanded(
                        child: clientesFiltrados.isEmpty
                            ? const Center(child: Text('No hay clientes registrados'))
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: clientesFiltrados.length,
                                itemBuilder: (context, index) {
                                  final c = clientesFiltrados[index];
                                  return Card(
                                    elevation: 4,
                                    margin: const EdgeInsets.only(bottom: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: BorderSide(color: Colors.grey.shade200, width: 1.2),
                                    ),
                                    color: Colors.white,
                                    shadowColor: Colors.grey.shade200,
                                    child: Padding(
                                      padding: const EdgeInsets.all(18),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CircleAvatar(
                                            radius: 28,
                                            backgroundColor: Colors.grey[300],
                                            child: Text(
                                              (c.nombre.isNotEmpty)
                                                  ? c.nombre[0].toUpperCase()
                                                  : '?',
                                              style: const TextStyle(fontSize: 26, color: Colors.black, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          const SizedBox(width: 18),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Icon(Icons.person, color: Colors.black87, size: 22),
                                                    const SizedBox(width: 6),
                                                    Text(c.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black)),
                                                  ],
                                                ),
                                                const SizedBox(height: 6),
                                                Row(
                                                  children: [
                                                    Icon(Icons.email, color: Colors.grey[500], size: 18),
                                                    const SizedBox(width: 4),
                                                    Text(c.correo, style: const TextStyle(fontSize: 15, color: Colors.black87)),
                                                  ],
                                                ),
                                                if (c.mensaje != null && c.mensaje!.isNotEmpty)
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 6),
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.message, color: Colors.grey[500], size: 18),
                                                        const SizedBox(width: 4),
                                                        Expanded(
                                                          child: Text(
                                                            c.mensaje!,
                                                            maxLines: 2,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: const TextStyle(fontSize: 15, color: Colors.black87),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                const SizedBox(height: 10),
                                                Row(
                                                  children: [
                                                    ElevatedButton.icon(
                                                      icon: const Icon(Icons.edit, color: Colors.black87),
                                                      label: const Text('Editar', style: TextStyle(color: Colors.black87)),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.grey[200],
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                        elevation: 0,
                                                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                                      ),
                                                      onPressed: () => _mostrarFormularioCliente(cliente: c),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    ElevatedButton.icon(
                                                      icon: const Icon(Icons.delete, color: Colors.white),
                                                      label: const Text('Eliminar', style: TextStyle(color: Colors.white)),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.red.shade300,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                        elevation: 0,
                                                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                                      ),
                                                      onPressed: () => _confirmarEliminarCliente(c),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _mostrarFormularioCliente(),
          backgroundColor: Colors.grey[400],
          child: const Icon(Icons.add, color: Colors.black),
        ),
      ),
    );
  }
}
