import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tooapp_dashboard/src/core/network/api_client.dart';
import 'package:tooapp_dashboard/src/core/network/api_failure.dart';
import 'package:tooapp_dashboard/src/core/session/admin_session.dart';
import 'package:tooapp_dashboard/src/features/admin_read/data/admin_read_repository.dart';
import 'package:tooapp_dashboard/src/features/admin_read/models/admin_read_models.dart';
import 'package:tooapp_dashboard/src/features/admin_read/presentation/admin_read_pages.dart';
import 'package:tooapp_dashboard/src/features/categories/data/category_repository.dart';
import 'package:tooapp_dashboard/src/features/categories/models/admin_category.dart';

class _Reads extends AdminReadRepository {
  _Reads()
    : super(ApiClient(baseUrl: 'https://api.invalid', session: AdminSession()));

  int? requestedRating;
  String? requestedProvider;
  DateTime? requestedFrom;
  DateTime? requestedTo;
  bool userActive = true;
  ApiFailure? userListFailure;
  bool emptyUsers = false;
  String? requestedCategoryId;
  bool? requestedAvailability;

  @override
  Future<AdminReadPage<AdminUser>> users({
    required int page,
    String? query,
    bool? active,
  }) async {
    if (userListFailure != null) throw userListFailure!;
    final items = emptyUsers ? <AdminUser>[] : [_user()];
    return AdminReadPage(
      items: items,
      page: page,
      limit: 20,
      total: items.length,
    );
  }

  @override
  Future<AdminUser> user(String id) async => _user(active: userActive);

  @override
  Future<Map<String, Object?>> setUserAccountActive(
    String id,
    bool isAccountActive,
  ) async {
    userActive = isAccountActive;
    return {'id': id, 'isAccountActive': isAccountActive};
  }

  @override
  Future<AdminReadPage<AdminProvider>> providers({
    required int page,
    String? query,
    String? categoryId,
    bool? available,
  }) async => _providerPage(page, categoryId, available);

  Future<AdminReadPage<AdminProvider>> _providerPage(
    int page,
    String? categoryId,
    bool? available,
  ) async {
    requestedCategoryId = categoryId;
    requestedAvailability = available;
    return AdminReadPage(items: [_provider()], page: page, limit: 20, total: 1);
  }

  @override
  Future<AdminProvider> provider(String id) async => _provider();

  @override
  Future<AdminReadPage<AdminPortfolioImage>> portfolio({
    required int page,
    String? providerProfileId,
  }) async => AdminReadPage(
    items: [
      AdminPortfolioImage(
        id: 'image-1',
        providerProfileId: 'provider-1',
        imageUrl: 'https://example.test/image.jpg',
        createdAt: DateTime.utc(2026),
        providerName: 'Ana Pérez',
      ),
    ],
    page: page,
    limit: 20,
    total: 1,
  );

  @override
  Future<AdminReadPage<AdminReview>> reviews({
    required int page,
    String? providerProfileId,
    int? rating,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    requestedProvider = providerProfileId;
    requestedRating = rating;
    requestedFrom = dateFrom;
    requestedTo = dateTo;
    return AdminReadPage(items: [_review()], page: page, limit: 20, total: 1);
  }

  @override
  Future<AdminReadPage<AdminReview>> providerReviews({
    required String providerProfileId,
    required int page,
  }) async => AdminReadPage(
    items: [_review()],
    page: page,
    limit: 20,
    total: 1,
    ratingAverage: 4.5,
  );

  @override
  Future<AdminReadPage<AdminContact>> contacts({
    required int page,
    String? providerProfileId,
    String? categoryId,
    String? status,
  }) async =>
      AdminReadPage(items: [_contact()], page: page, limit: 20, total: 1);

  @override
  Future<AdminContact> contact(String id) async => _contact();

  @override
  Future<AdminReadPage<AdminMembershipTier>> memberships({
    required int page,
    String? query,
  }) async =>
      AdminReadPage(items: [_membership()], page: page, limit: 20, total: 1);

  @override
  Future<AdminMembershipTier> membership(String id) async => _membership();
}

AdminUser _user({bool active = true}) => AdminUser(
  id: 'user-1',
  firstName: 'Ana',
  lastName: 'Pérez',
  email: 'ana@example.com',
  isAccountActive: active,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
  locality: 'Córdoba',
  phone: '5551234',
  avatarUrl: null,
);

AdminProvider _provider({DateTime? shiftEndsAt}) => AdminProvider(
  id: 'provider-1',
  userId: 'user-1',
  firstName: 'Ana',
  lastName: 'Pérez',
  email: 'ana@example.com',
  phone: '5551234',
  accountActive: true,
  locality: 'Córdoba',
  primaryCategory: 'Electricidad',
  primaryCategoryId: 'category-1',
  isAvailable: true,
  shiftEndsAt: shiftEndsAt ?? DateTime.now().add(const Duration(hours: 1)),
  availabilityLocationSource: 'BASE',
  lastPulseAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
  minPrice: 1000,
  issuesInvoice: true,
  invoiceType: 'FACTURA_C',
);

AdminReview _review() => AdminReview(
  id: 'review-1',
  contactIntentId: 'contact-1',
  direction: 'CLIENT_TO_PROVIDER',
  rating: 5,
  comment: 'Buen trabajo',
  createdAt: DateTime.utc(2026),
  author: 'Ana Pérez',
  targetName: 'Luis Gómez',
);

AdminContact _contact() => AdminContact(
  id: 'contact-1',
  clientName: 'Ana Pérez',
  providerName: 'Luis Gómez',
  category: 'Electricidad',
  status: 'PENDING',
  scheduledFor: null,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

AdminMembershipTier _membership() => AdminMembershipTier(
  id: 'tier-1',
  name: 'Inicial',
  description: null,
  price: 0,
  createdAt: DateTime.utc(2026),
);

void main() {
  testWidgets('user list keeps phone out of list rows', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: AdminUsersPage(repository: _Reads())),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Ana Pérez'), findsOneWidget);
    expect(find.text('ana@example.com'), findsOneWidget);
    expect(find.text('5551234'), findsNothing);
  });

  testWidgets('user list separates empty data from forbidden access', (
    tester,
  ) async {
    final repository = _Reads()..emptyUsers = true;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: AdminUsersPage(repository: repository)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('No hay datos para mostrar.'), findsOneWidget);

    repository.userListFailure = const ApiFailure(
      ApiFailureKind.forbidden,
      'Forbidden',
      statusCode: 403,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: AdminUsersPage(repository: repository)),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('No tienes permiso para consultar esta información.'),
      findsOneWidget,
    );
    expect(find.text('No hay datos para mostrar.'), findsNothing);
  });

  testWidgets(
    'user detail shows authorized phone but no sensitive system data',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdminUserDetailPage(repository: _Reads(), userId: 'user-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('5551234'), findsOneWidget);
      expect(find.text('DNI'), findsNothing);
      expect(find.text('isDniVerified'), findsNothing);
      expect(find.textContaining('passwordHash'), findsNothing);
    },
  );

  testWidgets('user detail handles not found and nullable data', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdminUserDetailPage(
            repository: _ReadsWithMissingUser(),
            userId: 'missing',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Usuario no encontrado'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdminUserDetailPage(
            repository: _ReadsWithNullUser(),
            userId: 'user-1',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Dato no disponible').first,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Dato no disponible'), findsAtLeastNWidgets(1));
  });

  testWidgets('confirms account status change and reflects server result', (
    tester,
  ) async {
    final repository = _Reads();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdminUserDetailPage(repository: repository, userId: 'user-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Desactivar cuenta'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Estado actual: Activa'), findsOneWidget);
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(repository.userActive, isFalse);
    expect(find.text('Inactiva'), findsOneWidget);
    expect(find.text('Cuenta desactivada por el servidor.'), findsOneWidget);
  });

  testWidgets('provider list omits phone and detail derives review totals', (
    tester,
  ) async {
    final repository = _Reads();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: AdminProvidersPage(repository: repository)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Ana Pérez'), findsOneWidget);
    expect(find.text('5551234'), findsNothing);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdminProviderDetailPage(
            repository: repository,
            categoriesRepository: null,
            providerId: 'provider-1',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('5551234'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.textContaining('Calificación promedio:'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('Calificación promedio: 4.5'), findsOneWidget);
    expect(find.text('Total de reseñas: 1'), findsOneWidget);
    expect(find.text('DNI'), findsNothing);
    expect(find.text('passwordHash'), findsNothing);
  });

  testWidgets('provider list applies the declared category filter', (
    tester,
  ) async {
    final repository = _Reads();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdminProvidersPage(
            repository: repository,
            categoriesRepository: _CategoryReads(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButton<String?>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Electricidad').last);
    await tester.pumpAndSettle();
    expect(repository.requestedCategoryId, 'category-1');
  });

  testWidgets('expired availability is displayed as inactive', (tester) async {
    final repository = _ReadsWithExpiredAvailability();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdminProviderAvailabilityPage(
            repository: repository,
            providerId: 'provider-1',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('No disponible'), findsOneWidget);
    expect(find.text('BASE'), findsOneWidget);
  });

  testWidgets('billing and location screens show only modelled details', (
    tester,
  ) async {
    final repository = _Reads();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdminProviderBillingPage(
            repository: repository,
            providerId: 'provider-1',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Precio mínimo indicativo'), findsOneWidget);
    expect(find.text('FACTURA_C'), findsOneWidget);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdminProviderLocationPage(
            repository: repository,
            providerId: 'provider-1',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Córdoba'), findsOneWidget);
    expect(find.text('No disponible para la consola'), findsOneWidget);
  });

  testWidgets('global review filters are passed to the repository', (
    tester,
  ) async {
    final repository = _Reads();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: AdminReviewsPage(repository: repository)),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButton<int?>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('5 estrellas').last);
    await tester.pumpAndSettle();
    expect(repository.requestedRating, 5);
    expect(find.text('Buen trabajo'), findsOneWidget);
  });

  testWidgets('global reviews accept provider UUID and expose date filters', (
    tester,
  ) async {
    final repository = _Reads();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: AdminReviewsPage(repository: repository)),
      ),
    );
    await tester.pumpAndSettle();
    const providerId = '00000000-0000-4000-8000-000000000011';
    await tester.enterText(find.byType(TextField).first, providerId);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(repository.requestedProvider, providerId);
    expect(find.text('Desde'), findsOneWidget);
    expect(find.text('Hasta'), findsOneWidget);
  });

  testWidgets(
    'portfolio, contacts, contact detail and membership read screens render',
    (tester) async {
      final repository = _Reads();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AdminPortfolioPage(repository: repository)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('https://example.test/image.jpg'), findsOneWidget);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AdminContactsPage(repository: repository)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Ana Pérez'), findsOneWidget);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdminContactDetailPage(
              repository: repository,
              contactId: 'contact-1',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Luis Gómez'), findsOneWidget);
      expect(find.text('problemDescription'), findsNothing);
      expect(find.text('Conversación de WhatsApp'), findsNothing);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AdminMembershipsPage(repository: repository)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Inicial'), findsOneWidget);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdminMembershipDetailPage(
              repository: repository,
              tierId: 'tier-1',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Precio del tier'), findsOneWidget);
    },
  );
}

class _ReadsWithExpiredAvailability extends _Reads {
  @override
  Future<AdminProvider> provider(String id) async => _provider(
    shiftEndsAt: DateTime.now().subtract(const Duration(minutes: 1)),
  );
}

class _ReadsWithMissingUser extends _Reads {
  @override
  Future<AdminUser> user(String id) async => throw const ApiFailure(
    ApiFailureKind.unknown,
    'Usuario no encontrado',
    statusCode: 404,
  );
}

class _ReadsWithNullUser extends _Reads {
  @override
  Future<AdminUser> user(String id) async => AdminUser(
    id: id,
    firstName: 'Ana',
    lastName: 'Pérez',
    email: null,
    isAccountActive: true,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
    locality: null,
    phone: null,
    avatarUrl: null,
  );
}

class _CategoryReads extends CategoryRepository {
  _CategoryReads()
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
