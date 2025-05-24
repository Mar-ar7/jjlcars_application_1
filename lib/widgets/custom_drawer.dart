import 'package:flutter/material.dart';
import '../main.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                color: AppColors.primary,
                width: double.infinity,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'JJLCars',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              _buildDrawerItem(
                context: context,
                icon: Icons.home_outlined,
                title: 'Inicio',
                route: '/home',
              ),
              _buildDrawerItem(
                context: context,
                icon: Icons.calendar_today_outlined,
                title: 'Citas',
                route: '/citas',
              ),
              _buildDrawerItem(
                context: context,
                icon: Icons.people_outline,
                title: 'Clientes',
                route: '/clientes',
              ),
              _buildDrawerItem(
                context: context,
                icon: Icons.badge_outlined,
                title: 'Empleados',
                route: '/empleados',
              ),
              _buildDrawerItem(
                context: context,
                icon: Icons.directions_car_outlined,
                title: 'Vehículos',
                route: '/vehiculos',
              ),
              _buildDrawerItem(
                context: context,
                icon: Icons.analytics_outlined,
                title: 'Proyecciones',
                route: '/proyecciones',
              ),
              _buildDrawerItem(
                context: context,
                icon: Icons.point_of_sale_outlined,
                title: 'Ventas',
                route: '/ventas',
              ),
              _buildDrawerItem(
                context: context,
                icon: Icons.local_offer_outlined,
                title: 'Marcas',
                route: '/marcas',
              ),
              const Divider(height: 1),
              _buildDrawerItem(
                context: context,
                icon: Icons.logout,
                title: 'Cerrar Sesión',
                route: '/',
                isLogout: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String route,
    bool isLogout = false,
  }) {
    final isSelected = ModalRoute.of(context)?.settings.name == route;

    return ListTile(
      leading: Icon(
        icon,
        color: isLogout
            ? Colors.red
            : isSelected
                ? AppColors.primary
                : Colors.grey[600],
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout
              ? Colors.red
              : isSelected
                  ? AppColors.primary
                  : Colors.grey[800],
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        if (route == '/home') {
          Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
        } else if (isLogout) {
          Navigator.pushReplacementNamed(context, route);
        } else {
          Navigator.pushNamed(context, route);
        }
      },
      tileColor: isSelected ? AppColors.primary.withOpacity(0.1) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    );
  }
}
