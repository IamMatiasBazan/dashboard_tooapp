import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'responsive_admin_layout.dart';

class AdminScaffold extends StatelessWidget {
  const AdminScaffold({required this.child, this.onLogout, super.key});
  final Widget child;
  final Future<bool> Function()? onLogout;

  @override
  Widget build(BuildContext context) => ResponsiveAdminLayout(
    currentPath: GoRouterState.of(context).uri.path,
    onLogout: onLogout == null
        ? null
        : () async {
            final confirmed = await onLogout!();
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  confirmed ? 'Sesión cerrada y revocación confirmada.' : 'Sesión local cerrada; no se confirmó la revocación remota.',
                ),
              ),
            );
            context.go('/login');
          },
    child: child,
  );
}
