import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';

import 'package:jjlcars_application_1/main.dart';

void main() {
  testWidgets('DashboardScreen muestra opciones y navega correctamente', (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(MyApp());

      // Verificar que los ListTiles con los títulos estén presentes
      expect(find.text('Inventario de Autos'), findsOneWidget);
      expect(find.text('Empleados'), findsOneWidget);
      expect(find.text('Clientes y Mensajes'), findsOneWidget);
      expect(find.text('Citas'), findsOneWidget);

      // Simular tap en 'Inventario de Autos' y verificar que navega a InventarioScreen
      await tester.tap(find.text('Inventario de Autos'));
      await tester.pumpAndSettle();

      expect(find.text('Inventario de Autos'), findsOneWidget); // AppBar título

      // Aquí podrías abrir un ExpansionTile y verificar algún modelo para asegurar carga imágenes
      await tester.tap(find.text('Ferrari'));
      await tester.pumpAndSettle();

      expect(find.text('F8 Tributo'), findsOneWidget);

      // Regresar atrás
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Simular tap en 'Empleados' y verificar navegación
      await tester.tap(find.text('Empleados'));
      await tester.pumpAndSettle();

      expect(find.text('Empleados'), findsOneWidget);

      // Regresar atrás
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Simular tap en 'Clientes y Mensajes' y verificar navegación
      await tester.tap(find.text('Clientes y Mensajes'));
      await tester.pumpAndSettle();

      expect(find.text('Clientes y Mensajes'), findsOneWidget);

      // Regresar atrás
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Simular tap en 'Citas' y verificar navegación
      await tester.tap(find.text('Citas'));
      await tester.pumpAndSettle();

      expect(find.text('Citas'), findsOneWidget);
    });
  });
}
