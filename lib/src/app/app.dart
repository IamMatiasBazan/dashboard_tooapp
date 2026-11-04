import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/config/admin_config.dart';
import '../core/network/api_client.dart';
import '../core/session/admin_session.dart';
import '../core/session/session_provider.dart';
import '../core/theme/admin_theme.dart';
import '../features/access/data/auth_repository.dart';
import '../features/categories/data/category_repository.dart';
import '../features/admin_read/data/admin_read_repository.dart';
import '../features/reports/data/report_repository.dart';
import 'router/admin_router.dart';

class AdminApp extends StatefulWidget {
  const AdminApp({super.key});
  @override
  State<AdminApp> createState() => _AdminAppState();
}

class _AdminAppState extends State<AdminApp> {
  late final AdminSession _session = AdminSession();
  late final SessionProvider _sessionProvider = SessionProvider(_session);
  late final AuthRepository? _auth = AdminConfig.apiBaseUrl.isEmpty
      ? null
      : AuthRepository(
          dio: Dio(BaseOptions(baseUrl: AdminConfig.apiBaseUrl)),
          session: _session,
        );
  late final CategoryRepository? _categories = AdminConfig.apiBaseUrl.isEmpty
      ? null
      : CategoryRepository(
          ApiClient(baseUrl: AdminConfig.apiBaseUrl, session: _session),
        );
  late final ReportRepository? _reports = AdminConfig.apiBaseUrl.isEmpty
      ? null
      : ReportRepository(
          ApiClient(baseUrl: AdminConfig.apiBaseUrl, session: _session),
        );
  late final AdminReadRepository? _adminRead = AdminConfig.apiBaseUrl.isEmpty
      ? null
      : AdminReadRepository(
          ApiClient(baseUrl: AdminConfig.apiBaseUrl, session: _session),
        );
  late final _router = createAdminRouter(
    session: _session,
    auth: _auth,
    categories: _categories,
    reports: _reports,
    adminRead: _adminRead,
  );

  @override
  void dispose() {
    _router.dispose();
    _sessionProvider.dispose();
    _session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      ChangeNotifierProvider<SessionProvider>.value(
        value: _sessionProvider,
        child: MaterialApp.router(
          title: 'TÖÖ Admin',
          theme: AdminTheme.light,
          routerConfig: _router,
        ),
      );
}
