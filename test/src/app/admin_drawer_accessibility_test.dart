import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tooapp_dashboard/src/app/layout/responsive_admin_layout.dart';

void main() {
  testWidgets(
    'drawer enables modules with read routes and keeps unsupported modules disabled',
    (tester) async {
      final semantics = tester.ensureSemantics();
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1000, 800);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: ResponsiveAdminLayout(currentPath: '/', child: Text('Screen')),
        ),
      );
      expect(find.byTooltip('Expandir navegación'), findsOneWidget);
      expect(find.byTooltip('Personas'), findsOneWidget);
      expect(find.byTooltip('Catálogo'), findsOneWidget);
      expect(find.byTooltip('Actividad'), findsOneWidget);
      expect(find.byTooltip('Administración'), findsOneWidget);
      IconButton iconButtonFor(String label) => tester.widget<IconButton>(
        find.ancestor(
          of: find.byTooltip(label),
          matching: find.byType(IconButton),
        ),
      );
      expect(iconButtonFor('Personas').onPressed, isNotNull);
      expect(iconButtonFor('Catálogo').onPressed, isNotNull);
      expect(iconButtonFor('Actividad').onPressed, isNotNull);
      expect(iconButtonFor('Administración').onPressed, isNotNull);
      await tester.tap(find.byTooltip('Catálogo'));
      await tester.pumpAndSettle();
      expect(find.text('Servicios y tarifas'), findsOneWidget);
      expect(find.text('Portafolios'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      expect(FocusManager.instance.primaryFocus, isNotNull);
      semantics.dispose();
    },
  );
}
