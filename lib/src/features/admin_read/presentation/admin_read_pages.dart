import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../categories/data/category_repository.dart';
import '../../categories/models/admin_category.dart';
import '../../../core/network/api_failure.dart';
import '../../../core/widgets/async_state_view.dart';
import '../data/admin_read_repository.dart';
import '../models/admin_read_models.dart';
import 'user_edit_page.dart';
import 'provider_edit_page.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({required this.repository, super.key});
  final AdminReadRepository repository;

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  bool? _active;

  @override
  Widget build(BuildContext context) => _AdminReadTablePage<AdminUser>(
    key: ValueKey(_active),
    title: 'Usuarios',
    searchLabel: 'Buscar por nombre o correo',
    header: DropdownButton<bool?>(
      value: _active,
      hint: const Text('Estado de cuenta'),
      items: const [
        DropdownMenuItem(value: null, child: Text('Todos los estados')),
        DropdownMenuItem(value: true, child: Text('Activa')),
        DropdownMenuItem(value: false, child: Text('Inactiva')),
      ],
      onChanged: (value) => setState(() => _active = value),
    ),
    load: (page, query) =>
        widget.repository.users(page: page, query: query, active: _active),
    tableBuilder: (items) => SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Nombre')),
            DataColumn(label: Text('Correo')),
            DataColumn(label: Text('Localidad')),
            DataColumn(label: Text('Cuenta')),
            DataColumn(label: Text('Alta')),
          ],
          rows: [
            for (final user in items)
              DataRow(
                onSelectChanged: (_) => context.go('/users/${user.id}'),
                cells: [
                  DataCell(Text(user.fullName)),
                  DataCell(Text(user.email ?? 'No disponible')),
                  DataCell(Text(user.locality ?? 'No disponible')),
                  DataCell(Text(user.isAccountActive ? 'Activa' : 'Inactiva')),
                  DataCell(Text(_dateText(user.createdAt))),
                ],
              ),
          ],
        ),
      ),
    ),
  );
}

class AdminUserDetailPage extends StatelessWidget {
  const AdminUserDetailPage({
    required this.repository,
    required this.userId,
    super.key,
  });
  final AdminReadRepository repository;
  final String userId;

  @override
  Widget build(BuildContext context) => _AdminReadDetailPage<AdminUser>(
    title: 'Detalle del usuario',
    load: () => repository.user(userId),
    actions: (user, reload) => [
      TextButton.icon(
        onPressed: () => context.go('/users'),
        icon: const Icon(Icons.arrow_back),
        label: const Text('Volver a usuarios'),
      ),
      OutlinedButton.icon(
        onPressed: () async {
          final saved = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) =>
                  AdminUserEditPage(repository: repository, user: user),
            ),
          );
          if (saved == true) await reload();
        },
        icon: const Icon(Icons.edit_outlined),
        label: const Text('Editar perfil'),
      ),
      OutlinedButton.icon(
        onPressed: () =>
            _changeAccountStatus(context, repository, user, reload),
        icon: Icon(
          user.isAccountActive ? Icons.block : Icons.check_circle_outline,
        ),
        label: Text(
          user.isAccountActive ? 'Desactivar cuenta' : 'Activar cuenta',
        ),
      ),
    ],
    fields: (user) => [
      MapEntry('Nombre', user.fullName),
      MapEntry('Correo electrónico', user.email ?? 'Dato no disponible'),
      MapEntry('Teléfono', user.phone ?? 'Dato no disponible'),
      MapEntry('Localidad', user.locality ?? 'Dato no disponible'),
      MapEntry(
        'Estado de cuenta',
        user.isAccountActive ? 'Activa' : 'Inactiva',
      ),
      MapEntry('Fecha de alta', _dateText(user.createdAt)),
      MapEntry('Última actualización', _dateText(user.updatedAt)),
    ],
  );
}

class AdminProvidersPage extends StatefulWidget {
  const AdminProvidersPage({
    required this.repository,
    this.categoriesRepository,
    this.onlyAvailable = false,
    super.key,
  });
  final AdminReadRepository repository;
  final CategoryRepository? categoriesRepository;
  final bool onlyAvailable;

  @override
  State<AdminProvidersPage> createState() => _AdminProvidersPageState();
}

class _AdminProvidersPageState extends State<AdminProvidersPage> {
  bool? _available;
  String? _categoryId;
  List<AdminCategory> _categories = const [];

  @override
  void initState() {
    super.initState();
    _available = widget.onlyAvailable ? true : null;
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    if (widget.onlyAvailable || widget.categoriesRepository == null) return;
    try {
      final result = await widget.categoriesRepository!.list(active: true);
      if (mounted) setState(() => _categories = result);
    } on Object {
      // The provider list remains usable without the optional category filter.
    }
  }

  @override
  Widget build(BuildContext context) => _AdminReadTablePage<AdminProvider>(
    key: ValueKey((_available, _categoryId)),
    title: widget.onlyAvailable ? 'Prestadores disponibles' : 'Prestadores',
    searchLabel: 'Buscar por nombre o correo',
    header: Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        if (widget.onlyAvailable)
          const Chip(label: Text('Disponibilidad vigente'))
        else
          DropdownButton<bool?>(
            value: _available,
            hint: const Text('Disponibilidad'),
            items: const [
              DropdownMenuItem(value: null, child: Text('Cualquiera')),
              DropdownMenuItem(value: true, child: Text('Disponibles')),
              DropdownMenuItem(value: false, child: Text('No disponibles')),
            ],
            onChanged: (value) => setState(() => _available = value),
          ),
        if (!widget.onlyAvailable && _categories.isNotEmpty)
          DropdownButton<String?>(
            value: _categoryId,
            hint: const Text('Categoría'),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('Todas las categorías'),
              ),
              for (final category in _categories)
                DropdownMenuItem(
                  value: category.id,
                  child: Text(category.name),
                ),
            ],
            onChanged: (value) => setState(() => _categoryId = value),
          ),
      ],
    ),
    load: (page, query) => widget.repository.providers(
      page: page,
      query: query,
      categoryId: _categoryId,
      available: _available,
    ),
    tableBuilder: (items) => SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Nombre')),
            DataColumn(label: Text('Correo')),
            DataColumn(label: Text('Categoría')),
            DataColumn(label: Text('Localidad')),
            DataColumn(label: Text('Disponibilidad')),
            DataColumn(label: Text('Hasta')),
          ],
          rows: [
            for (final provider in items)
              DataRow(
                onSelectChanged: (_) => context.go('/providers/${provider.id}'),
                cells: [
                  DataCell(Text(provider.fullName)),
                  DataCell(Text(provider.email ?? 'No disponible')),
                  DataCell(Text(provider.primaryCategory)),
                  DataCell(Text(provider.locality ?? 'No disponible')),
                  DataCell(
                    Text(provider.isAvailable ? 'Disponible' : 'No disponible'),
                  ),
                  DataCell(
                    Text(
                      provider.shiftEndsAt == null
                          ? 'No disponible'
                          : _dateText(provider.shiftEndsAt!),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    ),
  );
}

class AdminProviderDetailPage extends StatelessWidget {
  const AdminProviderDetailPage({
    required this.repository,
    required this.categoriesRepository,
    required this.providerId,
    super.key,
  });
  final AdminReadRepository repository;
  final CategoryRepository? categoriesRepository;
  final String providerId;

  @override
  Widget build(BuildContext context) => _AdminReadDetailPage<AdminProvider>(
    title: 'Ficha del prestador',
    load: () => repository.provider(providerId),
    extra: (_) => FutureBuilder<AdminReadPage<AdminReview>>(
      future: repository.providerReviews(
        providerProfileId: providerId,
        page: 1,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const ListTile(
            title: Text('Resumen de reseñas no disponible'),
          );
        }
        final summary = snapshot.data;
        if (summary == null) return const LinearProgressIndicator();
        return ListTile(
          title: Text(
            'Calificación promedio: ${summary.ratingAverage?.toStringAsFixed(1) ?? 'Dato no disponible'}',
          ),
          subtitle: Text('Total de reseñas: ${summary.total}'),
        );
      },
    ),
    fields: (provider) => [
      MapEntry('Nombre', provider.fullName),
      MapEntry('Correo electrónico', provider.email ?? 'Dato no disponible'),
      MapEntry('Teléfono', provider.phone ?? 'Dato no disponible'),
      MapEntry('Cuenta', provider.accountActive ? 'Activa' : 'Inactiva'),
      MapEntry('Categoría principal', provider.primaryCategory),
      MapEntry(
        'Categorías secundarias',
        provider.secondaryCategories.isEmpty
            ? 'Ninguna'
            : provider.secondaryCategories.join(', '),
      ),
      MapEntry(
        'Disponibilidad actual',
        provider.isAvailable ? 'Disponible' : 'No disponible',
      ),
      MapEntry(
        'Disponible hasta',
        provider.shiftEndsAt == null
            ? 'Dato no disponible'
            : _dateText(provider.shiftEndsAt!),
      ),
      MapEntry('Último pulso', _dateText(provider.lastPulseAt)),
      MapEntry('Localidad', provider.locality ?? 'Dato no disponible'),
      MapEntry('Biografía', provider.bio ?? 'Dato no disponible'),
      MapEntry(
        'Experiencia (años)',
        provider.experienceYears?.toString() ?? 'Dato no disponible',
      ),
      MapEntry(
        'Matriculado',
        provider.isMatriculado == null
            ? 'Dato no disponible'
            : provider.isMatriculado!
            ? 'Sí'
            : 'No',
      ),
      MapEntry('Matrícula', provider.matriculaNumber ?? 'Dato no disponible'),
      MapEntry(
        'Precio mínimo indicativo',
        provider.minPrice?.toString() ?? 'Dato no disponible',
      ),
      MapEntry(
        'Cobra consulta',
        provider.chargesConsultation == null
            ? 'Dato no disponible'
            : provider.chargesConsultation!
            ? 'Sí'
            : 'No',
      ),
      MapEntry(
        'Precio de consulta',
        provider.consultationPrice?.toString() ?? 'Dato no disponible',
      ),
      MapEntry(
        'Emite comprobante',
        provider.issuesInvoice == null
            ? 'Dato no disponible'
            : provider.issuesInvoice!
            ? 'Sí'
            : 'No',
      ),
      MapEntry(
        'Tipo de comprobante',
        provider.invoiceType ?? 'Dato no disponible',
      ),
      MapEntry(
        'Membresía',
        provider.membershipTier ?? 'Sin membresía asociada',
      ),
      MapEntry(
        'Imágenes de portafolio',
        provider.portfolioImagesCount?.toString() ?? 'Dato no disponible',
      ),
    ],
    actions: (provider, reload) => [
      TextButton.icon(
        onPressed: () => context.go('/providers'),
        icon: const Icon(Icons.arrow_back),
        label: const Text('Volver a prestadores'),
      ),
      OutlinedButton.icon(
        onPressed: categoriesRepository == null
            ? null
            : () async {
                final saved = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => AdminProviderEditPage(
                      repository: repository,
                      categoriesRepository: categoriesRepository!,
                      provider: provider,
                    ),
                  ),
                );
                if (saved == true) await reload();
              },
        icon: const Icon(Icons.edit_outlined),
        label: const Text('Editar perfil'),
      ),
      OutlinedButton.icon(
        onPressed: () =>
            _changeProviderAccountStatus(context, repository, provider, reload),
        icon: Icon(
          provider.accountActive ? Icons.block : Icons.check_circle_outline,
        ),
        label: Text(
          provider.accountActive ? 'Desactivar cuenta' : 'Activar cuenta',
        ),
      ),
      OutlinedButton.icon(
        onPressed: () => context.go('/providers/$providerId/portfolio'),
        icon: const FaIcon(FontAwesomeIcons.images),
        label: const Text('Ver portafolio'),
      ),
      OutlinedButton.icon(
        onPressed: () => context.go('/providers/$providerId/reviews'),
        icon: const FaIcon(FontAwesomeIcons.star),
        label: const Text('Ver reseñas'),
      ),
      OutlinedButton.icon(
        onPressed: () => context.go('/providers/$providerId/billing'),
        icon: const Icon(Icons.receipt_long_outlined),
        label: const Text('Tarifas y facturación'),
      ),
      OutlinedButton.icon(
        onPressed: () => context.go('/providers/$providerId/availability'),
        icon: const Icon(Icons.schedule_outlined),
        label: const Text('Disponibilidad'),
      ),
      OutlinedButton.icon(
        onPressed: () => context.go('/providers/$providerId/location'),
        icon: const Icon(Icons.location_on_outlined),
        label: const Text('Ubicación'),
      ),
    ],
  );
}

class AdminProviderBillingPage extends StatelessWidget {
  const AdminProviderBillingPage({
    required this.repository,
    required this.providerId,
    super.key,
  });
  final AdminReadRepository repository;
  final String providerId;

  @override
  Widget build(BuildContext context) => _AdminReadDetailPage<AdminProvider>(
    title: 'Tarifas y facturación',
    load: () => repository.provider(providerId),
    actions: (_, _) => [
      TextButton.icon(
        onPressed: () => context.go('/providers/$providerId'),
        icon: const Icon(Icons.arrow_back),
        label: const Text('Volver a ficha'),
      ),
    ],
    fields: (provider) => [
      MapEntry(
        'Precio mínimo indicativo',
        provider.minPrice?.toString() ?? 'Dato no disponible',
      ),
      MapEntry('Cobra consulta', _yesNo(provider.chargesConsultation)),
      MapEntry(
        'Precio de consulta',
        provider.consultationPrice?.toString() ?? 'Dato no disponible',
      ),
      MapEntry('Emite comprobante', _yesNo(provider.issuesInvoice)),
      MapEntry(
        'Tipo de comprobante',
        provider.invoiceType ?? 'Dato no disponible',
      ),
    ],
  );
}

class AdminProviderAvailabilityPage extends StatelessWidget {
  const AdminProviderAvailabilityPage({
    required this.repository,
    required this.providerId,
    super.key,
  });
  final AdminReadRepository repository;
  final String providerId;

  @override
  Widget build(BuildContext context) => _AdminReadDetailPage<AdminProvider>(
    title: 'Disponibilidad del prestador',
    load: () => repository.provider(providerId),
    actions: (_, _) => [
      TextButton.icon(
        onPressed: () => context.go('/providers/$providerId'),
        icon: const Icon(Icons.arrow_back),
        label: const Text('Volver a ficha'),
      ),
    ],
    fields: (provider) {
      final currentlyAvailable =
          provider.isAvailable &&
          provider.shiftEndsAt != null &&
          provider.shiftEndsAt!.isAfter(DateTime.now());
      return [
        MapEntry('Estado', currentlyAvailable ? 'Disponible' : 'No disponible'),
        MapEntry(
          'Disponible hasta',
          provider.shiftEndsAt == null
              ? 'Dato no disponible'
              : _dateText(provider.shiftEndsAt!),
        ),
        MapEntry(
          'Origen de ubicación informado',
          provider.availabilityLocationSource ?? 'Dato no disponible',
        ),
        MapEntry('Última actualización', _dateText(provider.lastPulseAt)),
      ];
    },
  );
}

class AdminProviderLocationPage extends StatelessWidget {
  const AdminProviderLocationPage({
    required this.repository,
    required this.providerId,
    super.key,
  });
  final AdminReadRepository repository;
  final String providerId;

  @override
  Widget build(BuildContext context) => _AdminReadDetailPage<AdminProvider>(
    title: 'Ubicación del prestador',
    load: () => repository.provider(providerId),
    actions: (_, _) => [
      TextButton.icon(
        onPressed: () => context.go('/providers/$providerId'),
        icon: const Icon(Icons.arrow_back),
        label: const Text('Volver a ficha'),
      ),
    ],
    fields: (provider) => [
      MapEntry('Localidad', provider.locality ?? 'Dato no disponible'),
      const MapEntry('Ubicación precisa', 'No disponible para la consola'),
    ],
  );
}

class AdminPortfolioPage extends StatelessWidget {
  const AdminPortfolioPage({
    required this.repository,
    this.providerProfileId,
    super.key,
  });
  final AdminReadRepository repository;
  final String? providerProfileId;

  @override
  Widget build(BuildContext context) =>
      _AdminReadTablePage<AdminPortfolioImage>(
        title: providerProfileId == null
            ? 'Portafolios'
            : 'Portafolio del prestador',
        searchable: false,
        load: (page, _) => repository.portfolio(
          page: page,
          providerProfileId: providerProfileId,
        ),
        tableBuilder: (items) => SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Prestador')),
                DataColumn(label: Text('Imagen')),
                DataColumn(label: Text('Fecha')),
              ],
              rows: [
                for (final image in items)
                  DataRow(
                    onSelectChanged: (_) =>
                        context.go('/providers/${image.providerProfileId}'),
                    cells: [
                      DataCell(Text(image.providerName)),
                      DataCell(Text(image.imageUrl)),
                      DataCell(Text(_dateText(image.createdAt))),
                    ],
                  ),
              ],
            ),
          ),
        ),
      );
}

class AdminReviewsPage extends StatefulWidget {
  const AdminReviewsPage({
    required this.repository,
    this.providerProfileId,
    super.key,
  });
  final AdminReadRepository repository;
  final String? providerProfileId;

  @override
  State<AdminReviewsPage> createState() => _AdminReviewsPageState();
}

class _AdminReviewsPageState extends State<AdminReviewsPage> {
  int? _rating;
  DateTime? _dateFrom;
  DateTime? _dateTo;
  final _providerId = TextEditingController();

  @override
  void dispose() {
    _providerId.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool from}) async {
    final firstDate = from ? DateTime(2000) : (_dateFrom ?? DateTime(2000));
    final lastDate = from ? (_dateTo ?? DateTime.now()) : DateTime.now();
    final proposed = from
        ? (_dateFrom ?? DateTime.now())
        : (_dateTo ?? DateTime.now());
    final initialDate = proposed.isBefore(firstDate)
        ? firstDate
        : proposed.isAfter(lastDate)
        ? lastDate
        : proposed;
    final selected = await showDatePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDate: initialDate,
    );
    if (selected != null) {
      setState(() {
        if (from) {
          _dateFrom = selected;
        } else {
          _dateTo = selected;
        }
      });
    }
  }

  Future<AdminReadPage<AdminReview>> _loadGlobalReviews(int page) async {
    final providerId = _providerId.text.trim();
    if (providerId.isNotEmpty &&
        !RegExp(
          r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-8][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
        ).hasMatch(providerId)) {
      throw const FormatException(
        'El ID de prestador debe ser un UUID válido.',
      );
    }
    if (_dateFrom != null && _dateTo != null && _dateFrom!.isAfter(_dateTo!)) {
      throw const FormatException(
        'La fecha inicial no puede superar la fecha final.',
      );
    }
    return widget.repository.reviews(
      page: page,
      providerProfileId: providerId.isEmpty ? null : providerId,
      rating: _rating,
      dateFrom: _dateFrom,
      dateTo: _dateTo,
    );
  }

  @override
  Widget build(BuildContext context) {
    final providerId = widget.providerProfileId;
    final table = _AdminReadTablePage<AdminReview>(
      key: ValueKey((
        _rating,
        _providerId.text,
        _dateFrom,
        _dateTo,
        providerId,
      )),
      title: providerId == null ? 'Reseñas' : 'Reseñas del prestador',
      searchable: false,
      header: providerId == null
          ? Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                DropdownButton<int?>(
                  value: _rating,
                  hint: const Text('Calificación'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Todas')),
                    for (var value = 1; value <= 5; value++)
                      DropdownMenuItem(
                        value: value,
                        child: Text('$value estrellas'),
                      ),
                  ],
                  onChanged: (value) => setState(() => _rating = value),
                ),
                SizedBox(
                  width: 260,
                  child: TextField(
                    controller: _providerId,
                    decoration: const InputDecoration(
                      labelText: 'ID de prestador',
                    ),
                    onSubmitted: (_) => setState(() {}),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => _pickDate(from: true),
                  icon: const Icon(Icons.calendar_today_outlined),
                  label: Text(
                    _dateFrom == null ? 'Desde' : _dateText(_dateFrom!),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => _pickDate(from: false),
                  icon: const Icon(Icons.calendar_today_outlined),
                  label: Text(_dateTo == null ? 'Hasta' : _dateText(_dateTo!)),
                ),
              ],
            )
          : const SizedBox.shrink(),
      load: (page, _) => providerId == null
          ? _loadGlobalReviews(page)
          : widget.repository.providerReviews(
              providerProfileId: providerId,
              page: page,
            ),
      tableBuilder: (items) => SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Autor')),
              DataColumn(label: Text('Prestador')),
              DataColumn(label: Text('Calificación')),
              DataColumn(label: Text('Comentario')),
              DataColumn(label: Text('Fecha')),
            ],
            rows: [
              for (final review in items)
                DataRow(
                  cells: [
                    DataCell(Text(review.author)),
                    DataCell(Text(review.targetName ?? 'Prestador actual')),
                    DataCell(
                      Text(review.rating?.toString() ?? 'Sin calificación'),
                    ),
                    DataCell(Text(review.comment ?? 'Sin comentario')),
                    DataCell(Text(_dateText(review.createdAt))),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
    if (providerId == null) return table;
    return Column(
      children: [
        FutureBuilder<AdminReadPage<AdminReview>>(
          future: widget.repository.providerReviews(
            providerProfileId: providerId,
            page: 1,
          ),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const ListTile(
                title: Text('Resumen de reseñas no disponible'),
              );
            }
            final summary = snapshot.data;
            if (summary == null) return const LinearProgressIndicator();
            final average = summary.ratingAverage;
            return ListTile(
              title: Text(
                'Promedio: ${average?.toStringAsFixed(1) ?? 'Dato no disponible'}',
              ),
              subtitle: Text('Total de reseñas: ${summary.total}'),
            );
          },
        ),
        Expanded(child: table),
      ],
    );
  }
}

class AdminContactsPage extends StatefulWidget {
  const AdminContactsPage({required this.repository, super.key});
  final AdminReadRepository repository;

  @override
  State<AdminContactsPage> createState() => _AdminContactsPageState();
}

class _AdminContactsPageState extends State<AdminContactsPage> {
  String? _status;
  static const statuses = ['PENDING', 'SCHEDULED', 'COMPLETED', 'CANCELLED'];

  @override
  Widget build(BuildContext context) => _AdminReadTablePage<AdminContact>(
    key: ValueKey(_status),
    title: 'Contactos',
    searchable: false,
    header: DropdownButton<String?>(
      value: _status,
      hint: const Text('Estado'),
      items: [
        const DropdownMenuItem(value: null, child: Text('Todos los estados')),
        for (final status in statuses)
          DropdownMenuItem(value: status, child: Text(status)),
      ],
      onChanged: (value) => setState(() => _status = value),
    ),
    load: (page, _) => widget.repository.contacts(page: page, status: _status),
    tableBuilder: (items) => SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Usuario')),
            DataColumn(label: Text('Prestador')),
            DataColumn(label: Text('Categoría')),
            DataColumn(label: Text('Estado')),
            DataColumn(label: Text('Programado')),
            DataColumn(label: Text('Recibido')),
          ],
          rows: [
            for (final contact in items)
              DataRow(
                onSelectChanged: (_) => context.go('/contacts/${contact.id}'),
                cells: [
                  DataCell(Text(contact.clientName)),
                  DataCell(Text(contact.providerName)),
                  DataCell(Text(contact.category)),
                  DataCell(Text(contact.status)),
                  DataCell(
                    Text(
                      contact.scheduledFor == null
                          ? 'No disponible'
                          : _dateText(contact.scheduledFor!),
                    ),
                  ),
                  DataCell(Text(_dateText(contact.createdAt))),
                ],
              ),
          ],
        ),
      ),
    ),
  );
}

class AdminContactDetailPage extends StatelessWidget {
  const AdminContactDetailPage({
    required this.repository,
    required this.contactId,
    super.key,
  });
  final AdminReadRepository repository;
  final String contactId;

  @override
  Widget build(BuildContext context) => _AdminReadDetailPage<AdminContact>(
    title: 'Detalle del contacto',
    load: () => repository.contact(contactId),
    actions: (_, _) => [
      TextButton.icon(
        onPressed: () => context.go('/contacts'),
        icon: const Icon(Icons.arrow_back),
        label: const Text('Volver a contactos'),
      ),
    ],
    fields: (contact) => [
      MapEntry('Usuario', contact.clientName),
      MapEntry('Prestador', contact.providerName),
      MapEntry('Categoría', contact.category),
      MapEntry('Estado', contact.status),
      MapEntry(
        'Programado',
        contact.scheduledFor == null
            ? 'Dato no disponible'
            : _dateText(contact.scheduledFor!),
      ),
      MapEntry('Recibido', _dateText(contact.createdAt)),
      MapEntry('Actualizado', _dateText(contact.updatedAt)),
    ],
  );
}

class AdminMembershipsPage extends StatelessWidget {
  const AdminMembershipsPage({required this.repository, super.key});
  final AdminReadRepository repository;

  @override
  Widget build(BuildContext context) =>
      _AdminReadTablePage<AdminMembershipTier>(
        title: 'Membresías',
        searchLabel: 'Buscar membresía',
        load: (page, query) => repository.memberships(page: page, query: query),
        tableBuilder: (items) => SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Nombre')),
                DataColumn(label: Text('Descripción')),
                DataColumn(label: Text('Precio del tier')),
                DataColumn(label: Text('Creada')),
              ],
              rows: [
                for (final tier in items)
                  DataRow(
                    onSelectChanged: (_) =>
                        context.go('/memberships/${tier.id}'),
                    cells: [
                      DataCell(Text(tier.name)),
                      DataCell(Text(tier.description ?? 'No disponible')),
                      DataCell(Text(tier.price.toString())),
                      DataCell(Text(_dateText(tier.createdAt))),
                    ],
                  ),
              ],
            ),
          ),
        ),
      );
}

class AdminMembershipDetailPage extends StatelessWidget {
  const AdminMembershipDetailPage({
    required this.repository,
    required this.tierId,
    super.key,
  });
  final AdminReadRepository repository;
  final String tierId;

  @override
  Widget build(BuildContext context) =>
      _AdminReadDetailPage<AdminMembershipTier>(
        title: 'Detalle de membresía',
        load: () => repository.membership(tierId),
        actions: (_, _) => [
          TextButton.icon(
            onPressed: () => context.go('/memberships'),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Volver a membresías'),
          ),
        ],
        fields: (tier) => [
          MapEntry('Nombre', tier.name),
          MapEntry('Descripción', tier.description ?? 'Dato no disponible'),
          MapEntry('Precio del tier', tier.price.toString()),
          MapEntry('Creada', _dateText(tier.createdAt)),
        ],
      );
}

class _AdminReadTablePage<T> extends StatefulWidget {
  const _AdminReadTablePage({
    required this.title,
    required this.load,
    required this.tableBuilder,
    this.searchLabel,
    this.searchable = true,
    this.header,
    super.key,
  });

  final String title;
  final Future<AdminReadPage<T>> Function(int page, String query) load;
  final Widget Function(List<T>) tableBuilder;
  final String? searchLabel;
  final bool searchable;
  final Widget? header;

  @override
  State<_AdminReadTablePage<T>> createState() => _AdminReadTablePageState<T>();
}

class _AdminReadTablePageState<T> extends State<_AdminReadTablePage<T>> {
  final _searchController = TextEditingController();
  AdminReadPage<T>? _result;
  ApiFailure? _failure;
  String? _unexpectedError;
  int _page = 1;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load({int? page}) async {
    final requestedPage = page ?? _page;
    setState(() {
      _loading = true;
      _failure = null;
      _unexpectedError = null;
    });
    try {
      final result = await widget.load(
        requestedPage,
        _searchController.text.trim(),
      );
      if (mounted) {
        setState(() {
          _page = result.page;
          _result = result;
        });
      }
    } on ApiFailure catch (failure) {
      if (mounted) setState(() => _failure = failure);
    } on Object {
      if (mounted) {
        setState(
          () => _unexpectedError =
              'No se pudo cargar ${widget.title.toLowerCase()}.',
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.title,
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (widget.searchable)
                    SizedBox(
                      width: 340,
                      child: TextField(
                        controller: _searchController,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _load(page: 1),
                        decoration: InputDecoration(
                          labelText: widget.searchLabel ?? 'Buscar',
                          prefixIcon: const FaIcon(
                            FontAwesomeIcons.magnifyingGlass,
                            size: 16,
                          ),
                          suffixIcon: IconButton(
                            tooltip: 'Buscar',
                            onPressed: () => _load(page: 1),
                            icon: const FaIcon(
                              FontAwesomeIcons.arrowRight,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (widget.header != null) widget.header!,
                  OutlinedButton.icon(
                    onPressed: _loading ? null : _load,
                    icon: const FaIcon(FontAwesomeIcons.rotate, size: 16),
                    label: const Text('Actualizar'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _loading
                ? const AsyncStateView(
                    state: AsyncViewState.loading,
                    child: SizedBox.shrink(),
                  )
                : _failure?.kind == ApiFailureKind.forbidden ||
                      _failure?.kind == ApiFailureKind.unauthorized
                ? const AsyncStateView(
                    state: AsyncViewState.forbidden,
                    child: SizedBox.shrink(),
                  )
                : _failure != null || _unexpectedError != null
                ? AsyncStateView(
                    state: AsyncViewState.error,
                    message: _failure?.message ?? _unexpectedError,
                    onRetry: _load,
                    child: const SizedBox.shrink(),
                  )
                : result == null || result.items.isEmpty
                ? const AsyncStateView(
                    state: AsyncViewState.empty,
                    child: SizedBox.shrink(),
                  )
                : Card(
                    clipBehavior: Clip.antiAlias,
                    child: widget.tableBuilder(result.items),
                  ),
          ),
          if (result != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Página ${result.page} · ${result.total} registros'),
                IconButton(
                  tooltip: 'Página anterior',
                  onPressed: _loading || result.page <= 1
                      ? null
                      : () => _load(page: result.page - 1),
                  icon: const Icon(Icons.chevron_left),
                ),
                IconButton(
                  tooltip: 'Página siguiente',
                  onPressed:
                      _loading || result.page * result.limit >= result.total
                      ? null
                      : () => _load(page: result.page + 1),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _AdminReadDetailPage<T> extends StatefulWidget {
  const _AdminReadDetailPage({
    required this.title,
    required this.load,
    required this.fields,
    this.actions,
    this.extra,
  });
  final String title;
  final Future<T> Function() load;
  final List<MapEntry<String, String>> Function(T) fields;
  final List<Widget> Function(T, Future<void> Function())? actions;
  final Widget Function(T)? extra;

  @override
  State<_AdminReadDetailPage<T>> createState() =>
      _AdminReadDetailPageState<T>();
}

class _AdminReadDetailPageState<T> extends State<_AdminReadDetailPage<T>> {
  T? _value;
  ApiFailure? _failure;
  String? _unexpectedError;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failure = null;
      _unexpectedError = null;
    });
    try {
      final value = await widget.load();
      if (mounted) setState(() => _value = value);
    } on ApiFailure catch (failure) {
      if (mounted) setState(() => _failure = failure);
    } on Object {
      if (mounted) {
        setState(() => _unexpectedError = 'No se pudo cargar el detalle.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final forbidden =
        _failure?.kind == ApiFailureKind.forbidden ||
        _failure?.kind == ApiFailureKind.unauthorized;
    final value = _value;

    return Padding(
      padding: const EdgeInsets.all(28),
      child: _loading
          ? const AsyncStateView(
              state: AsyncViewState.loading,
              child: SizedBox.shrink(),
            )
          : forbidden
          ? const AsyncStateView(
              state: AsyncViewState.forbidden,
              child: SizedBox.shrink(),
            )
          : _failure != null || _unexpectedError != null
          ? AsyncStateView(
              state: AsyncViewState.error,
              message: _failure?.message ?? _unexpectedError,
              onRetry: _load,
              child: const SizedBox.shrink(),
            )
          : value == null
          ? const AsyncStateView(
              state: AsyncViewState.empty,
              child: SizedBox.shrink(),
            )
          : ListView(
              children: [
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                if (widget.actions != null) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.actions!(value, _load),
                  ),
                  const SizedBox(height: 12),
                ],
                for (final field in widget.fields(value))
                  Card(
                    child: ListTile(
                      title: Text(field.key),
                      subtitle: SelectableText(field.value),
                    ),
                  ),
                if (widget.extra != null) widget.extra!(value),
              ],
            ),
    );
  }
}

String _dateText(DateTime date) => date.toLocal().toString().split('.').first;

String _yesNo(bool? value) => value == null
    ? 'Dato no disponible'
    : value
    ? 'Sí'
    : 'No';

Future<void> _changeAccountStatus(
  BuildContext context,
  AdminReadRepository repository,
  AdminUser user,
  Future<void> Function() reload,
) async {
  final nextActive = !user.isAccountActive;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(nextActive ? 'Activar cuenta' : 'Desactivar cuenta'),
      content: Text(
        'Estado actual: ${user.isAccountActive ? 'Activa' : 'Inactiva'}. ¿Confirmas el cambio a ${nextActive ? 'activa' : 'inactiva'}?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Confirmar'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  try {
    final result = await repository.setUserAccountActive(user.id, nextActive);
    if (result['isAccountActive'] != nextActive) {
      throw const FormatException(
        'El servidor no confirmó el estado solicitado.',
      );
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Cuenta ${nextActive ? 'activada' : 'desactivada'} por el servidor.',
        ),
      ),
    );
    await reload();
  } on ApiFailure catch (failure) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(failure.message)));
    }
  } on Object {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo cambiar el estado de la cuenta.'),
        ),
      );
    }
  }
}

Future<void> _changeProviderAccountStatus(
  BuildContext context,
  AdminReadRepository repository,
  AdminProvider provider,
  Future<void> Function() reload,
) async {
  final nextActive = !provider.accountActive;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(nextActive ? 'Activar cuenta' : 'Desactivar cuenta'),
      content: Text(
        'Estado actual: ${provider.accountActive ? 'Activa' : 'Inactiva'}. ¿Confirmas el cambio a ${nextActive ? 'activa' : 'inactiva'}?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Confirmar'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  try {
    final result = await repository.setUserAccountActive(
      provider.userId,
      nextActive,
    );
    if (result['isAccountActive'] != nextActive) {
      throw const FormatException(
        'El servidor no confirmó el estado solicitado.',
      );
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Cuenta ${nextActive ? 'activada' : 'desactivada'} por el servidor.',
        ),
      ),
    );
    await reload();
  } on ApiFailure catch (failure) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(failure.message)));
    }
  } on Object {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo cambiar el estado de la cuenta.'),
        ),
      );
    }
  }
}
