import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tooapp_dashboard/src/core/network/api_client.dart';
import 'package:tooapp_dashboard/src/core/session/admin_session.dart';
import 'package:tooapp_dashboard/src/features/admin_read/data/admin_read_repository.dart';
import 'package:tooapp_dashboard/src/features/admin_read/models/admin_read_models.dart';
import 'package:tooapp_dashboard/src/features/admin_read/presentation/provider_edit_page.dart';
import 'package:tooapp_dashboard/src/features/categories/data/category_repository.dart';
import 'package:tooapp_dashboard/src/features/categories/models/admin_category.dart';

class _AdminReads extends AdminReadRepository {
  _AdminReads()
    : super(ApiClient(baseUrl: 'https://api.invalid', session: AdminSession()));

  Map<String, Object?>? updated;

  @override
  Future<AdminProvider> updateProvider(
    String providerProfileId, {
    Map<String, Object?>? user,
    Map<String, Object?>? providerProfile,
  }) async {
    updated = {
      if (user != null && user.isNotEmpty) 'user': user,
      if (providerProfile != null && providerProfile.isNotEmpty)
        'providerProfile': providerProfile,
    };
    return _provider();
  }
}

class _Categories extends CategoryRepository {
  _Categories()
    : super(ApiClient(baseUrl: 'https://api.invalid', session: AdminSession()));

  @override
  Future<List<AdminCategory>> list({
    CategoryStatus? status,
    bool? active,
  }) async => const [
    AdminCategory(
      id: 'category-1',
      name: 'Electricidad',
      iconUrl: null,
      status: CategoryStatus.approved,
      isActive: true,
      createdAt: null,
      primaryProviders: null,
      secondaryProviders: null,
    ),
  ];
}

AdminProvider _provider() => AdminProvider(
  id: 'provider-1',
  userId: 'user-1',
  firstName: 'Ana',
  lastName: 'Pérez',
  email: null,
  phone: '5551234',
  avatarUrl: null,
  accountActive: true,
  locality: null,
  primaryCategory: 'Electricidad',
  primaryCategoryId: 'category-1',
  isAvailable: false,
  shiftEndsAt: null,
  lastPulseAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
  bio: 'Biografía actual',
  experienceYears: 4,
  isMatriculado: false,
  matriculaNumber: null,
  coverageRadiusKm: 20,
  minPrice: 1000,
  chargesConsultation: false,
  consultationPrice: null,
  issuesInvoice: false,
  invoiceType: 'NONE',
);

void main() {
  testWidgets('patches only changed provider profile fields', (tester) async {
    final repository = _AdminReads();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdminProviderEditPage(
            repository: repository,
            categoriesRepository: _Categories(),
            provider: _provider(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final bioField = find.byKey(const Key('provider-edit-bio'));
    await tester.enterText(bioField, 'Nueva biografía');
    await tester.scrollUntilVisible(
      find.text('Guardar cambios'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Guardar cambios'));
    await tester.pumpAndSettle();

    expect(repository.updated, {
      'providerProfile': {'bio': 'Nueva biografía'},
    });
    expect(repository.updated!['providerProfile'], isNot(contains('dni')));
    expect(
      repository.updated!['providerProfile'],
      isNot(contains('baseLocation')),
    );
    expect(
      repository.updated!['providerProfile'],
      isNot(contains('isAvailable')),
    );
  });

  testWidgets(
    'patches permitted personal fields in the separate user section',
    (tester) async {
      final repository = _AdminReads();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdminProviderEditPage(
              repository: repository,
              categoriesRepository: _Categories(),
              provider: _provider(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final nameField = find.byKey(const Key('provider-edit-first-name'));
      await tester.enterText(nameField, 'Ana María');
      await tester.scrollUntilVisible(
        find.text('Guardar cambios'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Guardar cambios'));
      await tester.pumpAndSettle();

      expect(repository.updated, {
        'user': {'firstName': 'Ana María'},
      });
    },
  );
}
