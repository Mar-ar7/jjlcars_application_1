import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/cita.dart';
import '../models/vehiculo.dart';

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

  Future<void> _mostrarFormularioCita({Cita? cita}) async {
    final esEdicion = cita != null;
    final formKey = GlobalKey<FormState>();
    final nombreController = TextEditingController(text: cita?.nombre ?? '');
    final correoController = TextEditingController(text: cita?.correo ?? '');
    String tipoCita = cita?.tipoCita ?? '';
    final precioController = TextEditingController(text: cita?.precio.toString() ?? '');
    DateTime? fecha = cita != null && cita.fecha.isNotEmpty ? DateTime.tryParse(cita.fecha) : null;
    TimeOfDay? hora = cita != null && cita.hora.isNotEmpty
        ? TimeOfDay(
            hour: int.tryParse(cita.hora.split(':')[0]) ?? 0,
            minute: int.tryParse(cita.hora.split(':')[1]) ?? 0)
        : null;
    int? vehiculoId = cita?.vehiculoId;
    String status = cita?.status ?? 'Pendiente';
    List<Vehiculo> vehiculos = [];
    bool cargandoVehiculos = true;
    String? errorVehiculos;
    bool isLoading = false;

    final tipoCitaOpciones = ['Servicio', 'Cotización', 'Test Drive'];
    final tipoCitaDropdown = tipoCitaOpciones.toSet().toList();
    if (tipoCita.isNotEmpty && !tipoCitaDropdown.contains(tipoCita)) {
      tipoCitaDropdown.insert(0, tipoCita);
    }

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            if (cargandoVehiculos) {
              _apiService.getVehiculos().then((v) {
                setState(() {
                  vehiculos = v;
                  cargandoVehiculos = false;
                });
              }).catchError((e) {
                setState(() {
                  errorVehiculos = e.toString();
                  cargandoVehiculos = false;
                });
              });
            }
            return AlertDialog(
              title: Text(esEdicion ? 'Editar Cita' : 'Nueva Cita'),
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
                          if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) return 'Correo inválido';
                          return null;
                        },
                        keyboardType: TextInputType.emailAddress,
                      ),
                      DropdownButtonFormField<String>(
                        value: tipoCita.isNotEmpty ? tipoCita : null,
                        decoration: const InputDecoration(labelText: 'Tipo de Cita'),
                        items: tipoCitaDropdown
                            .map((op) => DropdownMenuItem(value: op, child: Text(op)))
                            .toList(),
                        onChanged: (v) => setState(() => tipoCita = v ?? ''),
                        validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
                      ),
                      TextFormField(
                        controller: precioController,
                        decoration: const InputDecoration(labelText: 'Precio'),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Campo obligatorio';
                          final n = int.tryParse(v);
                          if (n == null || n < 0) return 'Debe ser un número positivo';
                          return null;
                        },
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.calendar_today),
                              label: Text(fecha == null
                                  ? 'Seleccionar fecha'
                                  : '${fecha?.day}/${fecha?.month}/${fecha?.year}'),
                              onPressed: () async {
                                final now = DateTime.now();
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: fecha ?? now,
                                  firstDate: now,
                                  lastDate: DateTime(now.year + 2),
                                );
                                if (picked != null) setState(() => fecha = picked);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.access_time),
                              label: Text(hora == null
                                  ? 'Seleccionar hora'
                                  : hora?.format(context) ?? ''),
                              onPressed: () async {
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: hora ?? TimeOfDay.now(),
                                );
                                if (picked != null) setState(() => hora = picked);
                              },
                            ),
                          ),
                        ],
                      ),
                      if (fecha == null)
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(top: 4, left: 8),
                            child: Text('Seleccione una fecha', style: TextStyle(color: Colors.red, fontSize: 12)),
                          ),
                        ),
                      if (hora == null)
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(top: 4, left: 8),
                            child: Text('Seleccione una hora', style: TextStyle(color: Colors.red, fontSize: 12)),
                          ),
                        ),
                      if ((tipoCita == 'Servicio' || tipoCita == 'Cotización') && !cargandoVehiculos && errorVehiculos == null)
                        DropdownButtonFormField<int>(
                          value: vehiculoId,
                          decoration: const InputDecoration(labelText: 'Vehículo'),
                          items: vehiculos
                              .map((v) => DropdownMenuItem(
                                    value: v.id,
                                    child: Text('${v.marca} ${v.modelo}'),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              vehiculoId = value;
                            });
                          },
                          isExpanded: true,
                          hint: const Text('Seleccione un vehículo'),
                          validator: (v) => v == null ? 'Campo obligatorio' : null,
                        ),
                      const SizedBox(height: 8),
                      Text('Status: $status'),
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
                          if (!formKey.currentState!.validate() || fecha == null || hora == null) return;
                          setState(() => isLoading = true);
                          try {
                            final nuevaCita = Cita(
                              id: cita?.id ?? 0,
                              tipoCita: tipoCita,
                              precio: int.tryParse(precioController.text) ?? 0,
                              nombre: nombreController.text,
                              correo: correoController.text,
                              fecha: fecha!.toIso8601String().split('T')[0],
                              hora: hora!.format(context),
                              status: status,
                              vehiculoId: vehiculoId,
                              fechaRegistro: cita?.fechaRegistro,
                            );
                            if (esEdicion) {
                              await _apiService.actualizarCita(nuevaCita);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cita actualizada')));
                            } else {
                              await _apiService.crearCita(nuevaCita);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cita creada')));
                            }
                            if (mounted) {
                              Navigator.pop(context);
                              _cargarCitas();
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                          } finally {
                            setState(() => isLoading = false);
                          }
                        },
                  child: Text(esEdicion ? 'Actualizar' : 'Crear'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmarEliminarCita(Cita cita) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar la cita de ${cita.nombre}?'),
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
        await _apiService.eliminarCita(cita.id);
        _cargarCitas();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cita eliminada'), backgroundColor: Colors.green));
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
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  child: Text(
                                    cita.nombre.isNotEmpty ? cita.nombre[0].toUpperCase() : '?',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${cita.tipoCita} - ${cita.nombre}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      const SizedBox(height: 4),
                                      Text('Correo: ${cita.correo}', style: const TextStyle(fontSize: 14)),
                                      Text('Precio: Q${cita.precio}', style: const TextStyle(fontSize: 14)),
                                      Text('Fecha: ${cita.fecha} ${cita.hora}', style: const TextStyle(fontSize: 14)),
                                      if (cita.vehiculoId != null && cita.vehiculoId != 0)
                                        Text('Vehículo ID: ${cita.vehiculoId}', style: const TextStyle(fontSize: 14)),
                                      Text('Status: ${cita.status}', style: const TextStyle(fontSize: 14)),
                                    ],
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => _mostrarFormularioCita(cita: cita),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      color: Colors.red,
                                      onPressed: () => _confirmarEliminarCita(cita),
                                    ),
                                    DropdownButton<String>(
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
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormularioCita(),
        child: const Icon(Icons.add),
      ),
    );
  }
}