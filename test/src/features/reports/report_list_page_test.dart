import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tooapp_dashboard/src/core/network/api_client.dart';
import 'package:tooapp_dashboard/src/core/network/api_failure.dart';
import 'package:tooapp_dashboard/src/core/session/admin_session.dart';
import 'package:tooapp_dashboard/src/features/reports/data/report_repository.dart';
import 'package:tooapp_dashboard/src/features/reports/models/admin_report.dart';
import 'package:tooapp_dashboard/src/features/reports/presentation/report_list_page.dart';

class _ReportRepository extends ReportRepository {
  _ReportRepository({this.failure, this.resolutionFailure, this.items})
    : super(
        ApiClient(
          baseUrl: 'https://api.example.invalid',
          session: AdminSession(),
        ),
      );
  final ApiFailure? failure;
  final ApiFailure? resolutionFailure;
  final List<AdminReport>? items;
  bool? requestedResolved;
  AdminReportType? requestedType;
  String? resolvedId;

  @override
  Future<List<AdminReport>> list({
    bool? isResolved,
    AdminReportType? type,
  }) async {
    requestedResolved = isResolved;
    requestedType = type;
    if (failure != null) throw failure!;
    return items ?? [report(isResolved: false)];
  }

  @override
  Future<AdminReport> resolve(String id) async {
    resolvedId = id;
    if (resolutionFailure != null) throw resolutionFailure!;
    return report(isResolved: true);
  }
}

AdminReport report({required bool isResolved, ReportAuthorSummary? author}) =>
    AdminReport(
      id: 'report-1',
      type: AdminReportType.userReport,
      content: 'Descripción del reporte',
      isResolved: isResolved,
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 2),
      author: author,
    );

void main() {
  test('maps only the approved optional author summary', () {
    final item = AdminReport.fromJson({
      'id': 'report-1',
      'type': 'USER_REPORT',
      'content': 'Descripción',
      'isResolved': false,
      'createdAt': '2026-01-01T00:00:00.000Z',
      'updatedAt': '2026-01-02T00:00:00.000Z',
      'author': {'firstName': 'Ana', 'lastName': 'Pérez'},
    });
    expect(item.author?.firstName, 'Ana');
    expect(item.author?.lastName, 'Pérez');
  });

  testWidgets(
    'shows a report without optional author data and allows resolution',
    (tester) async {
      final repository = _ReportRepository();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ReportListPage(repository: repository)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Descripción del reporte'), findsOneWidget);
      expect(find.text('report-1'), findsOneWidget);
      expect(find.text('Autor no disponible'), findsOneWidget);

      await tester.drag(
        find.byType(SingleChildScrollView).last,
        const Offset(-2400, 0),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Resolver'));
      await tester.pumpAndSettle();
      expect(find.text('Marcar reporte como resuelto'), findsOneWidget);
      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();
      expect(repository.resolvedId, 'report-1');
      expect(find.text('Resuelto'), findsOneWidget);
      expect(
        find.text('Reporte marcado como resuelto por el servidor.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('shows only the approved basic author name when present', (
    tester,
  ) async {
    final item = report(
      isResolved: false,
      author: const ReportAuthorSummary(firstName: 'Ana', lastName: 'Pérez'),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReportListPage(repository: _ReportRepository(items: [item])),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Ana Pérez'), findsOneWidget);
  });

  testWidgets('reports access denial distinctly from an empty list', (
    tester,
  ) async {
    final repository = _ReportRepository(
      failure: const ApiFailure(
        ApiFailureKind.forbidden,
        'Forbidden',
        statusCode: 403,
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ReportListPage(repository: repository)),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('No tienes permiso para consultar esta información.'),
      findsOneWidget,
    );
    expect(find.text('No hay datos para mostrar.'), findsNothing);
  });

  testWidgets('reports expired authorization distinctly', (tester) async {
    final repository = _ReportRepository(
      failure: const ApiFailure(
        ApiFailureKind.unauthorized,
        'Unauthorized',
        statusCode: 401,
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ReportListPage(repository: repository)),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('La sesión no está autorizada. Inicia sesión de nuevo.'),
      findsOneWidget,
    );
  });

  testWidgets('sends only the supported report filters', (tester) async {
    final repository = _ReportRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ReportListPage(repository: repository)),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButton<bool?>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Resueltos').last);
    await tester.pumpAndSettle();
    expect(repository.requestedResolved, true);
    expect(repository.requestedType, isNull);
    await tester.tap(find.byType(DropdownButton<AdminReportType?>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('USER_REPORT').last);
    await tester.pumpAndSettle();
    expect(repository.requestedResolved, true);
    expect(repository.requestedType, AdminReportType.userReport);
  });

  testWidgets('keeps an empty successful result distinct from failures', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReportListPage(repository: _ReportRepository(items: const [])),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('No hay datos para mostrar.'), findsOneWidget);
  });

  testWidgets(
    'shows a not-found result after resolution without claiming success',
    (tester) async {
      final repository = _ReportRepository(
        resolutionFailure: const ApiFailure(
          ApiFailureKind.unknown,
          'Not found',
          statusCode: 404,
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ReportListPage(repository: repository)),
        ),
      );
      await tester.pumpAndSettle();
      await tester.drag(
        find.byType(SingleChildScrollView).last,
        const Offset(-2400, 0),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Resolver'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();
      expect(find.text('El reporte ya no está disponible.'), findsOneWidget);
      expect(
        find.text('Reporte marcado como resuelto por el servidor.'),
        findsNothing,
      );
    },
  );
}
