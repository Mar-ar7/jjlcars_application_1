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

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Empleados'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $_error'),
                      ElevatedButton(
                        onPressed: _cargarUsuarios,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _cargarUsuarios,
                  child: ListView.builder(
                    itemCount: _usuarios.length,
                    itemBuilder: (context, index) {
                      final usuario = _usuarios[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          title: Text(usuario.nombre),
                          subtitle: Text('${usuario.usuario} - ${usuario.tipoUsuario}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _mostrarFormularioUsuario(usuario),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                color: Colors.red,
                                onPressed: () => _confirmarEliminar(usuario),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormularioUsuario(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
