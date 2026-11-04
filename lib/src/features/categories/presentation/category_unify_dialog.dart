import 'package:flutter/material.dart';

import '../../../core/network/api_failure.dart';
import '../data/category_repository.dart';
import '../models/admin_category.dart';

class CategoryUnifyDialog extends StatefulWidget {
  const CategoryUnifyDialog({
    required this.categories,
    required this.repository,
    super.key,
  });
  final List<AdminCategory> categories;
  final CategoryRepository repository;

  @override
  State<CategoryUnifyDialog> createState() => _CategoryUnifyDialogState();
}

class _CategoryUnifyDialogState extends State<CategoryUnifyDialog> {
  String? _source;
  String? _target;
  bool _saving = false;
  String? _error;

  AdminCategory? get _sourceCategory => _find(_source);
  AdminCategory? get _targetCategory => _find(_target);
  AdminCategory? _find(String? id) => id == null
      ? null
      : widget.categories.where((item) => item.id == id).firstOrNull;
  bool get _canSubmit =>
      !_saving &&
      _sourceCategory?.status == CategoryStatus.pending &&
      _targetCategory?.status == CategoryStatus.approved &&
      _source != _target;

  Future<void> _submit() async {
    final source = _sourceCategory;
    final target = _targetCategory;
    if (!_canSubmit || source == null || target == null) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final result = await widget.repository.unify(
        sourceCategoryId: source.id,
        targetCategoryId: target.id,
      );
      if (mounted) Navigator.of(context).pop(result);
    } on ApiFailure catch (error) {
      if (mounted) setState(() => _error = error.message);
    } on Object {
      if (mounted) {
        setState(
          () => _error = 'No se pudo confirmar la unificación. Revisa el estado y vuelve a intentar.',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Unificar categorías'),
    content: SizedBox(
      width: 480,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _source,
            decoration: const InputDecoration(
              labelText: 'Categoría de origen (PENDING)',
            ),
            items: [
              for (final item in widget.categories.where(
                (item) => item.status == CategoryStatus.pending,
              ))
                DropdownMenuItem(value: item.id, child: Text(item.name)),
            ],
            onChanged: _saving
                ? null
                : (value) => setState(() => _source = value),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _target,
            decoration: const InputDecoration(
              labelText: 'Categoría de destino (APPROVED)',
            ),
            items: [
              for (final item in widget.categories.where(
                (item) => item.status == CategoryStatus.approved,
              ))
                DropdownMenuItem(value: item.id, child: Text(item.name)),
            ],
            onChanged: _saving
                ? null
                : (value) => setState(() => _target = value),
          ),
          const SizedBox(height: 16),
          const Text(
            'La API reemplaza las relaciones de la categoría de origen con la de destino y elimina la categoría de origen. También reasigna los contactos relacionados. Esta acción requiere confirmación.',
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Semantics(
              liveRegion: true,
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.of(context).pop(),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: _canSubmit ? _submit : null,
        child: _saving
            ? const CircularProgressIndicator()
            : const Text('Confirmar unificación'),
      ),
    ],
  );
}
