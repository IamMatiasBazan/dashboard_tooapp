import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../core/theme/admin_tokens.dart';
import 'admin_drawer.dart';

enum AdminViewport { mobile, tablet, desktop }

AdminViewport viewportForWidth(double width) {
  if (width < 768) return AdminViewport.mobile;
  if (width < 1200) return AdminViewport.tablet;
  return AdminViewport.desktop;
}

class ResponsiveAdminLayout extends StatefulWidget {
  const ResponsiveAdminLayout({
    required this.currentPath,
    required this.child,
    this.onLogout,
    super.key,
  });

  final String currentPath;
  final Widget child;
  final VoidCallback? onLogout;

  @override
  State<ResponsiveAdminLayout> createState() => _ResponsiveAdminLayoutState();
}

class _ResponsiveAdminLayoutState extends State<ResponsiveAdminLayout> {
  bool _tabletExpanded = false;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final viewport = viewportForWidth(constraints.maxWidth);
      if (viewport == AdminViewport.mobile) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('TÖÖ Admin'),
            surfaceTintColor: Colors.transparent,
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: Divider(height: 1, color: AdminTokens.border),
            ),
            actions: [
              if (widget.onLogout != null)
                IconButton(
                  tooltip: 'Cerrar sesión',
                  onPressed: widget.onLogout,
                  icon: const FaIcon(FontAwesomeIcons.arrowRightFromBracket),
                ),
            ],
          ),
          drawer: Drawer(
            width: 300,
            child: SafeArea(
              child: AdminDrawer(currentPath: widget.currentPath),
            ),
          ),
          body: widget.child,
        );
      }

      final isDesktop = viewport == AdminViewport.desktop;
      return Scaffold(
        backgroundColor: AdminTokens.page,
        body: Row(
          children: [
            if (isDesktop)
              SizedBox(
                width: 272,
                child: AdminDrawer(currentPath: widget.currentPath),
              )
            else
              SizedBox(
                width: _tabletExpanded ? 272 : 80,
                child: _tabletExpanded
                    ? Column(
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              tooltip: 'Contraer navegación',
                              onPressed: () =>
                                  setState(() => _tabletExpanded = false),
                              icon: const Icon(Icons.chevron_left),
                            ),
                          ),
                          Expanded(
                            child: AdminDrawer(currentPath: widget.currentPath),
                          ),
                        ],
                      )
                    : AdminDrawer(
                        currentPath: widget.currentPath,
                        compact: true,
                      ),
              ),
            if (!isDesktop && !_tabletExpanded)
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  tooltip: 'Expandir navegación',
                  onPressed: () => setState(() => _tabletExpanded = true),
                  icon: const Icon(Icons.chevron_right),
                ),
              ),
            Expanded(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      height: 64,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: const BoxDecoration(
                        color: AdminTokens.surface,
                        border: Border(
                          bottom: BorderSide(color: AdminTokens.border),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (widget.onLogout != null)
                            TextButton.icon(
                              onPressed: widget.onLogout,
                              icon: const FaIcon(
                                FontAwesomeIcons.arrowRightFromBracket,
                                size: 16,
                              ),
                              label: const Text('Cerrar sesión'),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: widget.child,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
