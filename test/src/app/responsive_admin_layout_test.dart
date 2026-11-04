import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tooapp_dashboard/src/app/layout/responsive_admin_layout.dart';

void main() {
  testWidgets('keeps vertical navigation persistent on desktop', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1400, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: ResponsiveAdminLayout(
          currentPath: '/',
          child: Text('Current screen'),
        ),
      ),
    );
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Current screen'), findsOneWidget);
    expect(find.byTooltip('Expandir navegación'), findsNothing);
  });

  testWidgets(
    'tablet navigation can collapse and expand without losing the screen',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1000, 800);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: ResponsiveAdminLayout(
            currentPath: '/categories',
            child: Text('Category screen'),
          ),
        ),
      );
      expect(find.byTooltip('Expandir navegación'), findsOneWidget);
      await tester.tap(find.byTooltip('Expandir navegación'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Contraer navegación'), findsOneWidget);
      expect(find.text('Category screen'), findsOneWidget);
    },
  );

  testWidgets('mobile opens the lateral drawer and preserves module access', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: ResponsiveAdminLayout(
          currentPath: '/',
          child: Text('Mobile screen'),
        ),
      ),
    );
    expect(find.text('Mobile screen'), findsOneWidget);
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Personas'));
    await tester.pumpAndSettle();
    expect(find.text('Usuarios'), findsOneWidget);
    expect(find.text('Prestadores'), findsOneWidget);
    await tester.tap(find.text('Administración'));
    await tester.pumpAndSettle();
    expect(find.text('Reportes'), findsOneWidget);
  });

  testWidgets(
    'keeps navigation and page content available with enlarged text',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1400, 900);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(1.8)),
            child: ResponsiveAdminLayout(
              currentPath: '/',
              child: Text('Large text screen'),
            ),
          ),
        ),
      );
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Large text screen'), findsOneWidget);
    },
  );
}
