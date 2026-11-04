import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/session/admin_session.dart';
import '../../features/access/data/auth_repository.dart';
import '../../features/access/presentation/login_page.dart';
import '../../features/admin_read/data/admin_read_repository.dart';
import '../../features/admin_read/presentation/admin_read_pages.dart';
import '../../features/categories/data/category_repository.dart';
import '../../features/categories/presentation/category_list_page.dart';
import '../../features/reports/data/report_repository.dart';
import '../../features/reports/presentation/report_list_page.dart';
import '../layout/admin_scaffold.dart';

GoRouter createAdminRouter({
  required AdminSession session,
  required AuthRepository? auth,
  required CategoryRepository? categories,
  required ReportRepository? reports,
  required AdminReadRepository? adminRead,
}) => GoRouter(
  initialLocation: '/login',
  refreshListenable: session,
  redirect: (context, state) {
    final atLogin = state.matchedLocation == '/login';
    if (!session.isAuthenticated && !atLogin) return '/login';
    if (session.isAuthenticated && atLogin) return '/';
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) =>
          LoginPage(auth: auth, onAuthenticated: () => context.go('/')),
    ),
    ShellRoute(
      builder: (context, state, child) =>
          AdminScaffold(onLogout: auth?.logout, child: child),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const _UnavailablePage(
            title: 'Dashboard',
            reason: 'Los indicadores esperan una definición de métricas y un contrato administrativo.',
          ),
        ),
        GoRoute(
          path: '/users',
          builder: (context, state) => adminRead == null
              ? _connectionPage('Usuarios')
              : AdminUsersPage(repository: adminRead),
        ),
        GoRoute(
          path: '/users/:userId',
          builder: (context, state) => adminRead == null
              ? _connectionPage('Detalle del usuario')
              : AdminUserDetailPage(
                  repository: adminRead,
                  userId: state.pathParameters['userId']!,
                ),
        ),
        GoRoute(
          path: '/providers',
          builder: (context, state) => adminRead == null
              ? _connectionPage('Prestadores')
              : AdminProvidersPage(
                  repository: adminRead,
                  categoriesRepository: categories,
                ),
        ),
        GoRoute(
          path: '/providers/:providerProfileId',
          builder: (context, state) => adminRead == null
              ? _connectionPage('Ficha del prestador')
              : AdminProviderDetailPage(
                  repository: adminRead,
                  categoriesRepository: categories,
                  providerId: state.pathParameters['providerProfileId']!,
                ),
        ),
        GoRoute(
          path: '/providers/:providerProfileId/portfolio',
          builder: (context, state) => adminRead == null
              ? _connectionPage('Portafolio del prestador')
              : AdminPortfolioPage(
                  repository: adminRead,
                  providerProfileId: state.pathParameters['providerProfileId'],
                ),
        ),
        GoRoute(
          path: '/providers/:providerProfileId/reviews',
          builder: (context, state) => adminRead == null
              ? _connectionPage('Reseñas del prestador')
              : AdminReviewsPage(
                  repository: adminRead,
                  providerProfileId: state.pathParameters['providerProfileId'],
                ),
        ),
        GoRoute(
          path: '/providers/:providerProfileId/billing',
          builder: (context, state) => adminRead == null
              ? _connectionPage('Tarifas y facturación')
              : AdminProviderBillingPage(
                  repository: adminRead,
                  providerId: state.pathParameters['providerProfileId']!,
                ),
        ),
        GoRoute(
          path: '/providers/:providerProfileId/availability',
          builder: (context, state) => adminRead == null
              ? _connectionPage('Disponibilidad del prestador')
              : AdminProviderAvailabilityPage(
                  repository: adminRead,
                  providerId: state.pathParameters['providerProfileId']!,
                ),
        ),
        GoRoute(
          path: '/providers/:providerProfileId/location',
          builder: (context, state) => adminRead == null
              ? _connectionPage('Ubicación del prestador')
              : AdminProviderLocationPage(
                  repository: adminRead,
                  providerId: state.pathParameters['providerProfileId']!,
                ),
        ),
        GoRoute(
          path: '/categories',
          builder: (context, state) => categories == null
              ? _connectionPage('Categorías y oficios')
              : CategoryListPage(repository: categories),
        ),
        GoRoute(
          path: '/services',
          builder: (context, state) => const _UnavailablePage(
            title: 'Servicios y tarifas',
            reason: 'El modelo actual no tiene una entidad de servicios publicados.',
          ),
        ),
        GoRoute(
          path: '/portfolios',
          builder: (context, state) => adminRead == null
              ? _connectionPage('Portafolios')
              : AdminPortfolioPage(repository: adminRead),
        ),
        GoRoute(
          path: '/contacts',
          builder: (context, state) => adminRead == null
              ? _connectionPage('Contactos')
              : AdminContactsPage(repository: adminRead),
        ),
        GoRoute(
          path: '/contacts/:contactIntentId',
          builder: (context, state) => adminRead == null
              ? _connectionPage('Detalle del contacto')
              : AdminContactDetailPage(
                  repository: adminRead,
                  contactId: state.pathParameters['contactIntentId']!,
                ),
        ),
        GoRoute(
          path: '/reviews',
          builder: (context, state) => adminRead == null
              ? _connectionPage('Reseñas')
              : AdminReviewsPage(repository: adminRead),
        ),
        GoRoute(
          path: '/availability',
          builder: (context, state) => adminRead == null
              ? _connectionPage('Disponibilidad y ubicaciones')
              : AdminProvidersPage(repository: adminRead, onlyAvailable: true),
        ),
        GoRoute(
          path: '/memberships',
          builder: (context, state) => adminRead == null
              ? _connectionPage('Membresías')
              : AdminMembershipsPage(repository: adminRead),
        ),
        GoRoute(
          path: '/memberships/:tierId',
          builder: (context, state) => adminRead == null
              ? _connectionPage('Detalle de membresía')
              : AdminMembershipDetailPage(
                  repository: adminRead,
                  tierId: state.pathParameters['tierId']!,
                ),
        ),
        GoRoute(
          path: '/reports',
          builder: (context, state) => reports == null
              ? _connectionPage('Reportes')
              : ReportListPage(repository: reports),
        ),
      ],
    ),
  ],
);

Widget _connectionPage(String title) => _UnavailablePage(
  title: title,
  reason: 'Configura la conexión con la API para consultar este módulo.',
);

class _UnavailablePage extends StatelessWidget {
  const _UnavailablePage({required this.title, required this.reason});
  final String title;
  final String reason;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info_outline,
            size: 40,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(reason, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}
