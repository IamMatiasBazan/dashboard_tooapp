import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tooapp_dashboard/src/core/network/api_client.dart';
import 'package:tooapp_dashboard/src/core/session/admin_session.dart';
import 'package:tooapp_dashboard/src/features/categories/data/category_repository.dart';
import 'package:tooapp_dashboard/src/features/categories/models/admin_category.dart';
import 'package:tooapp_dashboard/src/features/categories/presentation/category_list_page.dart';

class _CategoryRepository extends CategoryRepository {
  _CategoryRepository()
    : super(
        ApiClient(
          baseUrl: 'https://api.example.invalid',
          session: AdminSession(),
        ),
      );
  String? activatedId;
  bool? nextActive;
  @override
  Future<List<AdminCategory>> list({
    CategoryStatus? status,
    bool? active,
  }) async => const [
    AdminCategory(
      id: 'id-1',
      name: 'Electricidad',
      iconUrl: null,
      status: CategoryStatus.approved,
      isActive: true,
      createdAt: null,
      primaryProviders: 2,
      secondaryProviders: 1,
    ),
  ];

  @override
  Future<AdminCategory> setActive(String id, bool isActive) async {
    activatedId = id;
    nextActive = isActive;
    return AdminCategory(
      id: id,
      name: 'Electricidad',
      iconUrl: null,
      status: CategoryStatus.approved,
      isActive: isActive,
      createdAt: null,
      primaryProviders: 2,
      secondaryProviders: 1,
    );
  }
}

void main() {
  testWidgets('renders confirmed category data and derived counts', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CategoryListPage(repository: _CategoryRepository()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Electricidad'), findsOneWidget);
    expect(find.text('APPROVED'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('confirms and applies category activation state', (tester) async {
    final repository = _CategoryRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: CategoryListPage(repository: repository)),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(
      find.byType(SingleChildScrollView).last,
      const Offset(-1800, 0),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Desactivar Electricidad'));
    await tester.pumpAndSettle();
    expect(find.text('¿Confirmas desactivar “Electricidad”?'), findsOneWidget);
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(repository.activatedId, 'id-1');
    expect(repository.nextActive, isFalse);
    expect(find.text('Categoría desactivada por el servidor.'), findsOneWidget);
  });
}
