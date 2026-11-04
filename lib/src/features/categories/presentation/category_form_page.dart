import 'package:flutter/material.dart';

import '../../../core/network/api_failure.dart';
import '../data/category_repository.dart';
import '../models/admin_category.dart';

class CategoryFormPage extends StatefulWidget {
  const CategoryFormPage({required this.repository, this.category, super.key});

  final CategoryRepository repository;
  final AdminCategory? category;

  @override
  State<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends State<CategoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _iconUrl;
  bool _saving = false;
  String? _error;

  bool get _isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.category?.name ?? '');
    _iconUrl = TextEditingController(text: widget.category?.iconUrl ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _iconUrl.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';
    if (name.length < 2 || name.length > 100) {
      return 'Usa entre 2 y 100 caracteres.';
    }
    return null;
  }

  String? _validateUrl(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final uri = Uri.tryParse(text);
    if (uri == null ||
        !uri.hasAuthority ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      return 'Ingresa una URL válida.';
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final url = _iconUrl.text.trim();
      if (_isEditing) {
        await widget.repository.update(
          widget.category!.id,
          name: _name.text.trim(),
          iconUrl: url.isEmpty ? null : url,
        );
      } else {
        await widget.repository.create(
          name: _name.text.trim(),
          iconUrl: url.isEmpty ? null : url,
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiFailure catch (failure) {
      if (mounted) setState(() => _error = failure.message);
    } on Object {
      if (mounted) setState(() => _error = 'No se pudo guardar la categoría.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(_isEditing ? 'Editar categoría' : 'Nueva categoría'),
    ),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              TextFormField(
                controller: _name,
                maxLength: 100,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: _validateName,
                enabled: !_saving,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _iconUrl,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'URL del ícono (opcional)',
                ),
                validator: _validateUrl,
                enabled: !_saving,
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 24),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 12,
                children: [
                  OutlinedButton(
                    onPressed: _saving
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  FilledButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Guardar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
