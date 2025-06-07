import 'package:flutter/material.dart';
import '../models/vehiculo.dart';
import '../services/vehiculo_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class VehiculosScreen extends StatefulWidget {
  const VehiculosScreen({super.key});

  @override
  State<VehiculosScreen> createState() => _VehiculosScreenState();
}

class _VehiculosScreenState extends State<VehiculosScreen> {
  final VehiculoService _vehiculoService = VehiculoService();
  List<Vehiculo> _vehiculos = [];
  bool _isLoading = true;
  String? _error;
  TextEditingController _searchController = TextEditingController();
  String _search = '';

  @override
  void initState() {
    super.initState();
    _cargarVehiculos();
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

  Future<void> _cargarVehiculos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final vehiculos = await _vehiculoService.obtenerVehiculos();
      setState(() {
        _vehiculos = vehiculos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar vehículos: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _mostrarFormularioVehiculo({Vehiculo? vehiculo}) async {
    final formKey = GlobalKey<FormState>();
    final marcaController = TextEditingController(text: vehiculo?.marca ?? '');
    final modeloController = TextEditingController(text: vehiculo?.modelo ?? '');
    final descripcionController = TextEditingController(text: vehiculo?.descripcion ?? '');
    final precioController = TextEditingController(text: vehiculo?.precio.toString() ?? '');
    final inventarioController = TextEditingController(text: vehiculo?.inventario.toString() ?? '');
    File? imagenFile;
    String? imagenUrl = vehiculo?.imagen;
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(vehiculo == null ? 'Agregar Vehículo' : 'Editar Vehículo'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final picker = ImagePicker();
                          final picked = await picker.pickImage(source: ImageSource.gallery);
                          if (picked != null) {
                            setState(() {
                              imagenFile = File(picked.path);
                              imagenUrl = null;
                            });
                          }
                        },
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: imagenFile != null
                              ? Image.file(imagenFile!, fit: BoxFit.cover)
                              : ((imagenUrl ?? '').isNotEmpty)
                                  ? Image.network(imagenUrl!, fit: BoxFit.cover)
                                  : const Icon(Icons.camera_alt, size: 48, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: marcaController,
                        decoration: const InputDecoration(labelText: 'Marca'),
                        validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
                      ),
                      TextFormField(
                        controller: modeloController,
                        decoration: const InputDecoration(labelText: 'Modelo'),
                        validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
                      ),
                      TextFormField(
                        controller: descripcionController,
                        decoration: const InputDecoration(labelText: 'Descripción'),
                        validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
                        maxLines: 2,
                      ),
                      TextFormField(
                        controller: precioController,
                        decoration: const InputDecoration(labelText: 'Precio'),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Campo obligatorio';
                          final n = double.tryParse(v);
                          if (n == null || n < 0) return 'Debe ser un número positivo';
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: inventarioController,
                        decoration: const InputDecoration(labelText: 'Inventario'),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Campo obligatorio';
                          final n = int.tryParse(v);
                          if (n == null || n < 0) return 'Debe ser un número positivo';
                          return null;
                        },
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
                              'marca': marcaController.text,
                              'modelo': modeloController.text,
                              'descripcion': descripcionController.text,
                              'precio': precioController.text,
                              'inventario': inventarioController.text,
                            };
                            if (vehiculo != null) fields['id'] = vehiculo.id.toString();
                            if (vehiculo == null) {
                              await _vehiculoService.crearVehiculo(fields, imagenFile?.path);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vehículo creado')));
                            } else {
                              await _vehiculoService.actualizarVehiculo(fields, imagenFile?.path);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vehículo actualizado')));
                            }
                            if (mounted) {
                              Navigator.pop(context);
                              _cargarVehiculos();
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                          } finally {
                            setState(() => isLoading = false);
                          }
                        },
                  child: Text(vehiculo == null ? 'Crear' : 'Actualizar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmarEliminarVehiculo(Vehiculo vehiculo) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar el vehículo ${vehiculo.marca} ${vehiculo.modelo}?'),
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
        await _vehiculoService.eliminarVehiculo(vehiculo.id);
        _cargarVehiculos();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vehículo eliminado'), backgroundColor: Colors.green));
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
    final vehiculosFiltrados = _vehiculos.where((v) =>
      v.marca.toLowerCase().contains(_search.toLowerCase()) ||
      v.modelo.toLowerCase().contains(_search.toLowerCase())
    ).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehículos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarVehiculos,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Buscar por marca o modelo',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Mostrando ${vehiculosFiltrados.length} de ${_vehiculos.length} registros'),
                      ),
                    ),
                    Expanded(
                      child: vehiculosFiltrados.isEmpty
                          ? const Center(child: Text('No hay vehículos registrados'))
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: vehiculosFiltrados.length,
                              itemBuilder: (context, index) {
                                final v = vehiculosFiltrados[index];
                                return Card(
                                  elevation: 6,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(color: Colors.grey.shade200, width: 1.5),
                                  ),
                                  color: Colors.white,
                                  shadowColor: Colors.grey.shade200,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                        child: v.imagen.isNotEmpty
                                            ? Image.network(
                                                v.imagen,
                                                height: 180,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) => Container(
                                                  height: 180,
                                                  color: Colors.grey[200],
                                                  child: const Icon(Icons.directions_car, size: 64, color: Colors.grey),
                                                ),
                                              )
                                            : Container(
                                                height: 180,
                                                color: Colors.grey[200],
                                                child: const Icon(Icons.directions_car, size: 64, color: Colors.grey),
                                              ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(18),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  '${v.marca} ${v.modelo}',
                                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                                                ),
                                                Text(
                                                  '\$24${v.precio.toStringAsFixed(2)}',
                                                  style: const TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              v.descripcion,
                                              style: const TextStyle(fontSize: 15, color: Colors.black),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                const Icon(Icons.inventory, size: 18, color: Colors.black),
                                                const SizedBox(width: 4),
                                                Text('Inventario: ${v.inventario}', style: const TextStyle(fontSize: 14, color: Colors.black)),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                ElevatedButton.icon(
                                                  icon: const Icon(Icons.edit, color: Colors.white),
                                                  label: const Text('Editar', style: TextStyle(color: Colors.white)),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.grey.shade300,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                                  ),
                                                  onPressed: () => _mostrarFormularioVehiculo(vehiculo: v),
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
                                                  onPressed: () => _confirmarEliminarVehiculo(v),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormularioVehiculo(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
