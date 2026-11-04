import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tooapp_dashboard/src/core/network/api_client.dart';
import 'package:tooapp_dashboard/src/core/session/admin_session.dart';
import 'package:tooapp_dashboard/src/features/categories/data/category_repository.dart';
import 'package:tooapp_dashboard/src/features/categories/models/admin_category.dart';
import 'package:tooapp_dashboard/src/features/categories/presentation/category_form_page.dart';

class _Categories extends CategoryRepository {
  _Categories()
    : super(ApiClient(baseUrl: 'https://api.invalid', session: AdminSession()));

  String? createdName;
  String? createdIconUrl;

  @override
  Future<AdminCategory> create({required String name, String? iconUrl}) async {
    createdName = name;
    createdIconUrl = iconUrl;
    return AdminCategory(
      id: 'category-1',
      name: name,
      iconUrl: iconUrl,
      status: CategoryStatus.pending,
      isActive: true,
      createdAt: DateTime.utc(2026),
      primaryProviders: 0,
      secondaryProviders: 0,
    );
  }
}

void main() {
  testWidgets('creates a category using only name and icon URL', (
    tester,
  ) async {
    final repository = _Categories();
    var result = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () async {
                result =
                    await Navigator.of(context).push<bool>(
                      MaterialPageRoute<bool>(
                        builder: (_) =>
                            CategoryFormPage(repository: repository),
                      ),
                    ) ??
                    false;
              },
              child: const Text('Abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Plomería');
    await tester.ensureVisible(find.text('Guardar'));
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(result, isTrue);
    expect(repository.createdName, 'Plomería');
    expect(repository.createdIconUrl, isNull);
    expect(find.text('Nueva categoría'), findsNothing);
  });

  testWidgets('rejects a category name outside server constraints', (
    tester,
  ) async {
    final repository = _Categories();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: CategoryFormPage(repository: repository)),
      ),
    );
    await tester.enterText(find.byType(TextFormField).first, 'A');
    await tester.ensureVisible(find.text('Guardar'));
    await tester.tap(find.text('Guardar'));
    await tester.pump();

    expect(find.text('Usa entre 2 y 100 caracteres.'), findsOneWidget);
    expect(repository.createdName, isNull);
  });
}
