import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tooapp_dashboard/src/core/network/api_client.dart';
import 'package:tooapp_dashboard/src/core/session/admin_session.dart';
import 'package:tooapp_dashboard/src/features/categories/data/category_repository.dart';
import 'package:tooapp_dashboard/src/features/categories/models/admin_category.dart';
import 'package:tooapp_dashboard/src/features/categories/presentation/category_unify_dialog.dart';

class _CategoryRepository extends CategoryRepository {
  _CategoryRepository()
    : super(
        ApiClient(
          baseUrl: 'https://api.example.invalid',
          session: AdminSession(),
        ),
      );
  String? sourceId;
  String? targetId;
  @override
  Future<UnifyCategoryResult> unify({
    required String sourceCategoryId,
    required String targetCategoryId,
  }) async {
    sourceId = sourceCategoryId;
    targetId = targetCategoryId;
    return UnifyCategoryResult(
      message: 'ok',
      sourceCategoryId: sourceCategoryId,
      targetCategoryId: targetCategoryId,
      updatedProvidersCount: 3,
    );
  }
}

void main() {
  testWidgets(
    'requires different valid source and target then reports server result',
    (tester) async {
      final repository = _CategoryRepository();
      const categories = [
        AdminCategory(
          id: 'pending-id',
          name: 'Origen',
          iconUrl: null,
          status: CategoryStatus.pending,
          isActive: true,
          createdAt: null,
          primaryProviders: 0,
          secondaryProviders: 2,
        ),
        AdminCategory(
          id: 'approved-id',
          name: 'Destino',
          iconUrl: null,
          status: CategoryStatus.approved,
          isActive: true,
          createdAt: null,
          primaryProviders: 4,
          secondaryProviders: 1,
        ),
      ];
      UnifyCategoryResult? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await showDialog<UnifyCategoryResult>(
                  context: context,
                  builder: (_) => CategoryUnifyDialog(
                    categories: categories,
                    repository: repository,
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Confirmar unificación'),
            )
            .onPressed,
        isNull,
      );

      await tester.tap(find.byType(DropdownButtonFormField<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Origen').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<String>).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Destino').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirmar unificación'));
      await tester.pumpAndSettle();

      expect(repository.sourceId, 'pending-id');
      expect(repository.targetId, 'approved-id');
      expect(result?.updatedProvidersCount, 3);
    },
  );
}
