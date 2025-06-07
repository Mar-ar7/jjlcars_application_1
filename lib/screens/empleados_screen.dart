import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/usuario_service.dart';

class EmpleadosScreen extends StatefulWidget {
  const EmpleadosScreen({Key? key}) : super(key: key);

  @override
  _EmpleadosScreenState createState() => _EmpleadosScreenState();
}

class _EmpleadosScreenState extends State<EmpleadosScreen> {
  final UsuarioService _usuarioService = UsuarioService();
  List<Usuario> _usuarios = [];
  bool _isLoading = true;
  String? _error;
  TextEditingController _searchController = TextEditingController();
  String _search = '';

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
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

  Future<void> _cargarUsuarios() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final usuarios = await _usuarioService.obtenerUsuarios();
      setState(() {
        _usuarios = usuarios;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _mostrarFormularioUsuario([Usuario? usuario]) async {
    final esEdicion = usuario != null;
    final nombreController = TextEditingController(text: usuario?.nombre);
    final usuarioController = TextEditingController(text: usuario?.usuario);
    final passwordController = TextEditingController();
    String tipoUsuario = usuario?.tipoUsuario ?? 'Vendedor';
    // Normalizar para que coincida con los valores del Dropdown
    tipoUsuario = tipoUsuario[0].toUpperCase() + tipoUsuario.substring(1).toLowerCase();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(esEdicion ? 'Editar Empleado' : 'Nuevo Empleado'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: usuarioController,
                decoration: const InputDecoration(labelText: 'Usuario'),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  helperText: 'Dejar en blanco para mantener la actual',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: tipoUsuario,
                decoration: const InputDecoration(labelText: 'Tipo de Usuario'),
                items: ['Administrador', 'Gerente', 'Vendedor']
                    .toSet()
                    .map((tipo) => DropdownMenuItem(
                          value: tipo,
                          child: Text(tipo),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    tipoUsuario = value;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(esEdicion ? 'Actualizar' : 'Crear'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        setState(() => _isLoading = true);
        
        if (esEdicion) {
          await _usuarioService.actualizarUsuario(
            id: usuario.id,
            nombre: nombreController.text,
            usuario: usuarioController.text,
            password: passwordController.text.isEmpty ? null : passwordController.text,
            tipoUsuario: tipoUsuario,
          );
        } else {
          await _usuarioService.crearUsuario(
            nombre: nombreController.text,
            usuario: usuarioController.text,
            password: passwordController.text,
            tipoUsuario: tipoUsuario,
          );
        }
        
        _cargarUsuarios();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(esEdicion ? 'Empleado actualizado' : 'Empleado creado'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _confirmarEliminar(Usuario usuario) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar a ${usuario.nombre}?'),
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
        setState(() => _isLoading = true);
        await _usuarioService.eliminarUsuario(usuario.id);
        _cargarUsuarios();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Empleado eliminado'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuariosFiltrados = _usuarios.where((u) =>
      u.nombre.toLowerCase().contains(_search.toLowerCase()) ||
      u.usuario.toLowerCase().contains(_search.toLowerCase())
    ).toList();
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFe3f2fd), // azul muy claro
            Color(0xFF90caf9), // azul claro
            Color(0xFFf5f7fa), // blanco-gris
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Empleados', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
          backgroundColor: Colors.white,
          elevation: 2,
          iconTheme: const IconThemeData(color: Color(0xFF1565C0)),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _cargarUsuarios,
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
                        Text('Error: $_error', style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _cargarUsuarios,
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
                            prefixIcon: const Icon(Icons.search, color: Color(0xFF1565C0)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Mostrando ${usuariosFiltrados.length} de ${_usuarios.length} registros',
                            style: TextStyle(color: Colors.blueGrey[700], fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      Expanded(
                        child: usuariosFiltrados.isEmpty
                            ? const Center(child: Text('No hay empleados registrados'))
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: usuariosFiltrados.length,
                                itemBuilder: (context, index) {
                                  final usuario = usuariosFiltrados[index];
                                  return Card(
                                    elevation: 6,
                                    margin: const EdgeInsets.only(bottom: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: BorderSide(color: Colors.blueGrey.shade100, width: 1.5),
                                    ),
                                    color: Colors.white,
                                    shadowColor: Colors.blueGrey.shade100,
                                    child: Padding(
                                      padding: const EdgeInsets.all(18),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CircleAvatar(
                                            radius: 28,
                                            backgroundColor: const Color(0xFF1976D2),
                                            child: Text(
                                              (usuario.nombre.isNotEmpty)
                                                  ? usuario.nombre[0].toUpperCase()
                                                  : '?',
                                              style: const TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          const SizedBox(width: 18),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Icon(Icons.person, color: Color(0xFF1565C0), size: 22),
                                                    const SizedBox(width: 6),
                                                    Text(usuario.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF1565C0))),
                                                  ],
                                                ),
                                                const SizedBox(height: 6),
                                                Row(
                                                  children: [
                                                    Icon(Icons.account_circle, color: Colors.blueGrey[400], size: 18),
                                                    const SizedBox(width: 4),
                                                    Text(usuario.usuario, style: const TextStyle(fontSize: 15, color: Colors.blueGrey)),
                                                  ],
                                                ),
                                                const SizedBox(height: 6),
                                                Row(
                                                  children: [
                                                    Icon(Icons.badge, color: Colors.blueGrey[400], size: 18),
                                                    const SizedBox(width: 4),
                                                    Text(usuario.tipoUsuario, style: const TextStyle(fontSize: 15, color: Colors.blueGrey)),
                                                  ],
                                                ),
                                                const SizedBox(height: 10),
                                                Row(
                                                  children: [
                                                    ElevatedButton.icon(
                                                      icon: const Icon(Icons.edit, color: Colors.white),
                                                      label: const Text('Editar', style: TextStyle(color: Colors.white)),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: const Color(0xFF1976D2),
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                                      ),
                                                      onPressed: () => _mostrarFormularioUsuario(usuario),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    ElevatedButton.icon(
                                                      icon: const Icon(Icons.delete, color: Colors.white),
                                                      label: const Text('Eliminar', style: TextStyle(color: Colors.white)),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.red.shade400,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                                      ),
                                                      onPressed: () => _confirmarEliminar(usuario),
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
          onPressed: () => _mostrarFormularioUsuario(),
          backgroundColor: const Color(0xFF1976D2),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
