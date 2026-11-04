import 'package:flutter_test/flutter_test.dart';
import 'package:tooapp_dashboard/src/app/layout/responsive_admin_layout.dart';
import 'package:tooapp_dashboard/src/core/widgets/async_state_view.dart';
import 'package:tooapp_dashboard/src/core/widgets/confirmation_dialog.dart';
import 'package:flutter/material.dart';

void main() {
  test('responsive breakpoints classify mobile, tablet and desktop', () {
    expect(viewportForWidth(767), AdminViewport.mobile);
    expect(viewportForWidth(768), AdminViewport.tablet);
    expect(viewportForWidth(1199), AdminViewport.tablet);
    expect(viewportForWidth(1200), AdminViewport.desktop);
  });

  testWidgets(
    'shared async view distinguishes loading, empty, error and forbidden',
    (tester) async {
      for (final state in [
        AsyncViewState.loading,
        AsyncViewState.empty,
        AsyncViewState.error,
        AsyncViewState.forbidden,
        AsyncViewState.unavailable,
      ]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AsyncStateView(state: state, child: const Text('Loaded')),
            ),
          ),
        );
        await tester.pump();
        expect(find.text('Loaded'), findsNothing);
      }
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AsyncStateView(
              state: AsyncViewState.success,
              child: Text('Loaded'),
            ),
          ),
        ),
      );
      expect(find.text('Loaded'), findsOneWidget);
    },
  );

  testWidgets(
    'drawer exposes disabled destinations without enabling navigation',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveAdminLayout(
              currentPath: '/',
              child: Text('Content'),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Content'), findsOneWidget);
      expect(find.byTooltip('Administración'), findsOneWidget);
      await tester.tap(find.byTooltip('Administración'));
      await tester.pumpAndSettle();
      expect(find.text('Reportes'), findsOneWidget);
    },
  );

  testWidgets('confirmation dialog reports only an explicit confirmation', (
    tester,
  ) async {
    bool? confirmed;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async => confirmed = await confirmAdminAction(
              context,
              title: 'Confirmar',
              message: 'Acción irreversible',
            ),
            child: const Text('Open confirmation'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open confirmation'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(confirmed, false);
  });
}
