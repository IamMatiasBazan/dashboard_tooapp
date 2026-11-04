import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/admin_tokens.dart';

class AdminDestination {
  const AdminDestination(
    this.label,
    this.path,
    this.icon, {
    this.enabled = false,
  });
  final String label;
  final String path;
  final FaIconData icon;
  final bool enabled;
}

const dashboardDestination = AdminDestination(
  'Dashboard',
  '/',
  FontAwesomeIcons.gaugeHigh,
);
const usersDestination = AdminDestination(
  'Usuarios',
  '/users',
  FontAwesomeIcons.users,
  enabled: true,
);
const providersDestination = AdminDestination(
  'Prestadores',
  '/providers',
  FontAwesomeIcons.briefcase,
  enabled: true,
);
const categoriesDestination = AdminDestination(
  'Categorías y oficios',
  '/categories',
  FontAwesomeIcons.shapes,
  enabled: true,
);
const servicesDestination = AdminDestination(
  'Servicios y tarifas',
  '/services',
  FontAwesomeIcons.screwdriverWrench,
);
const portfoliosDestination = AdminDestination(
  'Portafolios',
  '/portfolios',
  FontAwesomeIcons.images,
  enabled: true,
);
const contactsDestination = AdminDestination(
  'Contactos',
  '/contacts',
  FontAwesomeIcons.addressBook,
  enabled: true,
);
const reviewsDestination = AdminDestination(
  'Reseñas',
  '/reviews',
  FontAwesomeIcons.star,
  enabled: true,
);
const availabilityDestination = AdminDestination(
  'Disponibilidad y ubicaciones',
  '/availability',
  FontAwesomeIcons.locationDot,
  enabled: true,
);
const membershipsDestination = AdminDestination(
  'Membresías',
  '/memberships',
  FontAwesomeIcons.idCard,
  enabled: true,
);
const reportsDestination = AdminDestination(
  'Reportes',
  '/reports',
  FontAwesomeIcons.flag,
  enabled: true,
);

const adminDestinations = <AdminDestination>[
  dashboardDestination,
  usersDestination,
  providersDestination,
  categoriesDestination,
  servicesDestination,
  portfoliosDestination,
  contactsDestination,
  reviewsDestination,
  availabilityDestination,
  membershipsDestination,
  reportsDestination,
];

class AdminNavSection {
  const AdminNavSection(this.label, this.icon, this.destinations);
  final String label;
  final FaIconData icon;
  final List<AdminDestination> destinations;
}

const adminNavSections = <AdminNavSection>[
  AdminNavSection('Personas', FontAwesomeIcons.users, [
    usersDestination,
    providersDestination,
  ]),
  AdminNavSection('Catálogo', FontAwesomeIcons.layerGroup, [
    categoriesDestination,
    servicesDestination,
    portfoliosDestination,
  ]),
  AdminNavSection('Actividad', FontAwesomeIcons.chartLine, [
    contactsDestination,
    reviewsDestination,
    availabilityDestination,
  ]),
  AdminNavSection('Administración', FontAwesomeIcons.sliders, [
    membershipsDestination,
    reportsDestination,
  ]),
];

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({
    required this.currentPath,
    this.compact = false,
    super.key,
  });
  final String currentPath;
  final bool compact;

  bool _sectionContainsCurrentPath(AdminNavSection section) =>
      section.destinations.any((item) => item.path == currentPath);

  Future<void> _showSection(
    BuildContext context,
    AdminNavSection section,
  ) async {
    final selectedPath = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(12),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Text(
                section.label,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            for (final destination in section.destinations)
              ListTile(
                leading: FaIcon(destination.icon, size: 18),
                title: Text(destination.label),
                trailing: destination.enabled
                    ? null
                    : const FaIcon(FontAwesomeIcons.lock, size: 14),
                enabled: destination.enabled,
                selected: destination.path == currentPath,
                onTap: destination.enabled
                    ? () => Navigator.pop(context, destination.path)
                    : null,
              ),
          ],
        ),
      ),
    );
    if (selectedPath != null && context.mounted) context.go(selectedPath);
  }

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(color: AdminTokens.brandBlueDark),
    child: compact
        ? Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: _BrandMark(compact: true, inverse: true),
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  children: [
                    IconButton(
                      tooltip: 'Dashboard',
                      onPressed: () => context.go('/'),
                      icon: const FaIcon(FontAwesomeIcons.gaugeHigh),
                    ),
                    const SizedBox(height: 8),
                    const Divider(
                      color: Colors.white24,
                      indent: 16,
                      endIndent: 16,
                    ),
                    for (final section in adminNavSections)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: IconButton(
                          tooltip: section.label,
                          onPressed: () => _showSection(context, section),
                          icon: FaIcon(section.icon),
                          color: _sectionContainsCurrentPath(section)
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.82),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          )
        : Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 22, 16, 18),
                child: _BrandMark(inverse: true),
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(10, 14, 10, 18),
                  children: [
                    _buildDestination(context, dashboardDestination),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 18, 16, 6),
                      child: Text(
                        'MÓDULOS',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    for (final section in adminNavSections)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                            splashColor: Colors.white10,
                            highlightColor: Colors.white10,
                          ),
                          child: Material(
                            color: AdminTokens.brandBlueDark,
                            child: ExpansionTile(
                              key: PageStorageKey(section.label),
                              initiallyExpanded: _sectionContainsCurrentPath(
                                section,
                              ),
                              leading: FaIcon(section.icon, size: 17),
                              iconColor: Colors.white70,
                              collapsedIconColor: Colors.white70,
                              textColor: Colors.white,
                              collapsedTextColor: Colors.white70,
                              tilePadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              childrenPadding: const EdgeInsets.only(left: 12),
                              title: Text(section.label),
                              children: [
                                for (final destination in section.destinations)
                                  _buildDestination(
                                    context,
                                    destination,
                                    nested: true,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
  );

  Widget _buildDestination(
    BuildContext context,
    AdminDestination destination, {
    bool nested = false,
  }) => Padding(
    padding: EdgeInsets.fromLTRB(nested ? 8 : 0, 2, 0, 2),
    child: Material(
      color: AdminTokens.brandBlueDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: FaIcon(destination.icon, size: 17),
        title: Text(
          destination.label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: destination.enabled
            ? null
            : Tooltip(
                message: 'Capacidad aún no disponible',
                child: FaIcon(
                  FontAwesomeIcons.lock,
                  size: 14,
                  color: Colors.white.withValues(alpha: 0.52),
                ),
              ),
        selected: destination.path == currentPath,
        enabled: true,
        onTap: destination.enabled ? () => context.go(destination.path) : null,
        selectedTileColor: Colors.white.withValues(alpha: 0.16),
        textColor: Colors.white.withValues(alpha: 0.82),
        selectedColor: Colors.white,
        iconColor: Colors.white.withValues(alpha: 0.82),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({this.compact = false, this.inverse = false});
  final bool compact;
  final bool inverse;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: compact
        ? MainAxisAlignment.center
        : MainAxisAlignment.start,
    children: [
      Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: inverse ? Colors.white : AdminTokens.brandBlue,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Text(
          'TÖÖ',
          style: TextStyle(
            color: inverse ? AdminTokens.brandBlueDark : Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      if (!compact) ...[
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TÖÖ Admin',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 2),
              Text(
                'Consola administrativa',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    ],
  );
}
