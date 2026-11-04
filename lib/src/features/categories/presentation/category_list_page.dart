import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/network/api_failure.dart';
import '../../../core/widgets/async_state_view.dart';
import '../data/category_repository.dart';
import '../models/admin_category.dart';
import 'category_form_page.dart';
import 'category_unify_dialog.dart';

class CategoryListPage extends StatefulWidget {
  const CategoryListPage({required this.repository, super.key});
  final CategoryRepository repository;

  @override
  State<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  List<AdminCategory>? _categories;
  CategoryStatus? _status;
  bool? _active;
  bool _loading = true;
  bool _forbidden = false;
  String? _error;
  final Set<String> _mutatingIds = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _forbidden = false;
    });
    try {
      final result = await widget.repository.list(
        status: _status,
        active: _active,
      );
      if (mounted) setState(() => _categories = result);
    } on ApiFailure catch (failure) {
      if (mounted) {
        setState(() {
          _forbidden =
              failure.kind == ApiFailureKind.forbidden ||
              failure.kind == ApiFailureKind.unauthorized;
          _error = failure.message;
        });
      }
    } on Object {
      if (mounted) {
        setState(() => _error = 'No se pudieron cargar las categorías.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _unify() async {
    final items = _categories;
    if (items == null) return;
    final result = await showDialog<UnifyCategoryResult>(
      context: context,
      builder: (_) =>
          CategoryUnifyDialog(categories: items, repository: widget.repository),
    );
    if (!mounted || result == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Unificación confirmada por el servidor. Prestadores actualizados: ${result.updatedProvidersCount}.',
        ),
      ),
    );
    await _load();
  }

  Future<void> _create() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CategoryFormPage(repository: widget.repository),
      ),
    );
    if (saved == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Categoría creada por el servidor.')),
        );
      }
      await _load();
    }
  }

  Future<void> _edit(AdminCategory category) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            CategoryFormPage(repository: widget.repository, category: category),
      ),
    );
    if (saved == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Categoría actualizada por el servidor.'),
          ),
        );
      }
      await _load();
    }
  }

  Future<void> _setActive(AdminCategory category) async {
    final nextActive = !category.isActive;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(nextActive ? 'Activar categoría' : 'Desactivar categoría'),
        content: Text(
          '¿Confirmas ${nextActive ? 'activar' : 'desactivar'} “${category.name}”?',
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
    if (confirmed != true || !mounted) return;
    setState(() => _mutatingIds.add(category.id));
    try {
      final updated = await widget.repository.setActive(
        category.id,
        nextActive,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Categoría ${updated.isActive ? 'activada' : 'desactivada'} por el servidor.',
          ),
        ),
      );
      await _load();
    } on ApiFailure catch (failure) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(failure.message)));
      }
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo cambiar el estado de la categoría.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _mutatingIds.remove(category.id));
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(28),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            Text(
              'Categorías y oficios',
              style: Theme.of(context).textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: _forbidden || _loading ? null : _create,
                  icon: const Icon(Icons.add),
                  label: const Text('Nueva categoría'),
                ),
                OutlinedButton.icon(
                  onPressed: _categories == null || _forbidden ? null : _unify,
                  icon: const FaIcon(FontAwesomeIcons.codeBranch),
                  label: const Text('Unificar'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            DropdownButton<CategoryStatus?>(
              value: _status,
              hint: const Text('Todos los estados'),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Todos los estados'),
                ),
                for (final status in CategoryStatus.values)
                  DropdownMenuItem(value: status, child: Text(status.apiValue)),
              ],
              onChanged: (value) {
                setState(() => _status = value);
                _load();
              },
            ),
            DropdownButton<bool?>(
              value: _active,
              hint: const Text('Cualquier actividad'),
              items: const [
                DropdownMenuItem(
                  value: null,
                  child: Text('Cualquier actividad'),
                ),
                DropdownMenuItem(value: true, child: Text('Activas')),
                DropdownMenuItem(value: false, child: Text('Inactivas')),
              ],
              onChanged: (value) {
                setState(() => _active = value);
                _load();
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _loading
              ? const AsyncStateView(
                  state: AsyncViewState.loading,
                  child: SizedBox.shrink(),
                )
              : _forbidden
              ? const AsyncStateView(
                  state: AsyncViewState.forbidden,
                  child: SizedBox.shrink(),
                )
              : _error != null
              ? AsyncStateView(
                  state: AsyncViewState.error,
                  message: _error,
                  onRetry: _load,
                  child: const SizedBox.shrink(),
                )
              : _categories == null || _categories!.isEmpty
              ? const AsyncStateView(
                  state: AsyncViewState.empty,
                  child: SizedBox.shrink(),
                )
              : Card(
                  clipBehavior: Clip.antiAlias,
                  child: _CategoryTable(
                    categories: _categories!,
                    busyIds: _mutatingIds,
                    onEdit: _edit,
                    onSetActive: _setActive,
                  ),
                ),
        ),
      ],
    ),
  );
}

class _CategoryTable extends StatelessWidget {
  const _CategoryTable({
    required this.categories,
    required this.busyIds,
    required this.onEdit,
    required this.onSetActive,
  });
  final List<AdminCategory> categories;
  final Set<String> busyIds;
  final ValueChanged<AdminCategory> onEdit;
  final ValueChanged<AdminCategory> onSetActive;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Nombre')),
          DataColumn(label: Text('Estado')),
          DataColumn(label: Text('Activa')),
          DataColumn(label: Text('Prestadores primarios')),
          DataColumn(label: Text('Prestadores secundarios')),
          DataColumn(label: Text('Creada')),
          DataColumn(label: Text('Acciones')),
        ],
        rows: [
          for (final item in categories)
            DataRow(
              cells: [
                DataCell(Text(item.name)),
                DataCell(Text(item.status.apiValue)),
                DataCell(Text(item.isActive ? 'Sí' : 'No')),
                DataCell(
                  Text(item.primaryProviders?.toString() ?? 'No disponible'),
                ),
                DataCell(
                  Text(item.secondaryProviders?.toString() ?? 'No disponible'),
                ),
                DataCell(
                  Text(item.createdAt?.toLocal().toString() ?? 'No disponible'),
                ),
                DataCell(
                  Wrap(
                    spacing: 4,
                    children: [
                      IconButton(
                        tooltip: 'Editar ${item.name}',
                        onPressed: busyIds.contains(item.id)
                            ? null
                            : () => onEdit(item),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: item.isActive
                            ? 'Desactivar ${item.name}'
                            : 'Activar ${item.name}',
                        onPressed: busyIds.contains(item.id)
                            ? null
                            : () => onSetActive(item),
                        icon: Icon(
                          item.isActive ? Icons.toggle_on : Icons.toggle_off,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    ),
  );
}
