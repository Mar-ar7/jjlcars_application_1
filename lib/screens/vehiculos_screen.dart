import 'package:flutter/material.dart';
import '../main.dart';

class VehiculosScreen extends StatefulWidget {
  const VehiculosScreen({super.key});

  @override
  State<VehiculosScreen> createState() => _VehiculosScreenState();
}

class _VehiculosScreenState extends State<VehiculosScreen> {
  String? selectedBrand;

  // Datos de ejemplo - esto vendrá de la base de datos
  final Map<String, List<Map<String, dynamic>>> vehiclesByBrand = {
    'Ferrari': [
      {
        'modelo': 'F8 Tributo',
        'año': '2024',
        'precio': '\$325,000',
        'disponible': true,
        'descripcion': 'Potencia y lujo incomparables.',
        'imagen': 'assets/images/ferrari_f8.jpg'
      },
    ],
    'Audi': [
      {
        'modelo': 'A3',
        'año': '2024',
        'precio': '\$45,000',
        'disponible': true,
        'descripcion': 'Eficiencia y confort para toda la familia.',
        'imagen': 'assets/images/audi_a3.jpg'
      },
      {
        'modelo': 'RS Q8',
        'año': '2024',
        'precio': '\$120,000',
        'disponible': true,
        'descripcion': 'Diseño y tecnología avanzada.',
        'imagen': 'assets/images/audi_rsq8.jpg'
      },
      {
        'modelo': 'RS',
        'año': '2024',
        'precio': '\$85,000',
        'disponible': false,
        'descripcion': 'Confort y lujo en cada detalle.',
        'imagen': 'assets/images/audi_rs.jpg'
      },
    ],
    'Chevrolet': [
      {
        'modelo': 'Silverado 2025',
        'año': '2025',
        'precio': '\$55,000',
        'disponible': true,
        'descripcion': 'Potencia y durabilidad.',
        'imagen': 'assets/images/chevrolet_silverado.jpg'
      },
      {
        'modelo': 'Spark 2025',
        'año': '2025',
        'precio': '\$18,000',
        'disponible': true,
        'descripcion': 'Diseño y comodidad.',
        'imagen': 'assets/images/chevrolet_spark.jpg'
      },
      {
        'modelo': 'Tahoe 2025',
        'año': '2025',
        'precio': '\$65,000',
        'disponible': false,
        'descripcion': 'Potencia y comodidad en un solo vehículo.',
        'imagen': 'assets/images/chevrolet_tahoe.jpg'
      },
    ],
    'BMW': [
      {
        'modelo': 'M4 COMPETITION',
        'año': '2024',
        'precio': '\$85,000',
        'disponible': true,
        'descripcion': 'Lo mejor de nosotros.',
        'imagen': 'assets/images/bmw_m4.jpg'
      },
      {
        'modelo': 'X5',
        'año': '2024',
        'precio': '\$75,000',
        'disponible': true,
        'descripcion': 'Potencia y lujo.',
        'imagen': 'assets/images/bmw_x5.jpg'
      },
      {
        'modelo': 'X3',
        'año': '2024',
        'precio': '\$65,000',
        'disponible': true,
        'descripcion': 'El vehículo familiar más rápido.',
        'imagen': 'assets/images/bmw_x3.jpg'
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/home');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(selectedBrand ?? 'Vehículos'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (selectedBrand != null) {
                setState(() {
                  selectedBrand = null;
                });
              } else {
                Navigator.pushReplacementNamed(context, '/home');
              }
            },
          ),
        ),
        body: SafeArea(
          child: selectedBrand == null
              ? _buildBrandsGrid()
              : _buildVehiclesGrid(selectedBrand!),
        ),
      ),
    );
  }

  Widget _buildBrandsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: vehiclesByBrand.length,
      itemBuilder: (context, index) {
        final brand = vehiclesByBrand.keys.elementAt(index);
        return InkWell(
          onTap: () {
            setState(() {
              selectedBrand = brand;
            });
          },
          child: Card(
            elevation: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.directions_car,
                  size: 48,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  brand,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${vehiclesByBrand[brand]?.length ?? 0} modelos',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVehiclesGrid(String brand) {
    final vehicles = vehiclesByBrand[brand] ?? [];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: vehicles.length,
      itemBuilder: (context, index) {
        final vehicle = vehicles[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.directions_car,
                    size: 64,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          vehicle['modelo'] as String,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: vehicle['disponible'] ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            vehicle['disponible'] ? 'Disponible' : 'No disponible',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      vehicle['descripcion'] as String,
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      vehicle['precio'] as String,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
