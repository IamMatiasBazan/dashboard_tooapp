import 'package:flutter/material.dart';

import '../../../core/network/api_failure.dart';
import '../data/admin_read_repository.dart';
import '../models/admin_read_models.dart';

class AdminUserEditPage extends StatefulWidget {
  const AdminUserEditPage({
    required this.repository,
    required this.user,
    super.key,
  });

  final AdminReadRepository repository;
  final AdminUser user;

  @override
  State<AdminUserEditPage> createState() => _AdminUserEditPageState();
}

class _AdminUserEditPageState extends State<AdminUserEditPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _avatarUrl;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _firstName = TextEditingController(text: widget.user.firstName);
    _lastName = TextEditingController(text: widget.user.lastName);
    _email = TextEditingController(text: widget.user.email ?? '');
    _phone = TextEditingController(text: widget.user.phone ?? '');
    _avatarUrl = TextEditingController(text: widget.user.avatarUrl ?? '');
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    _avatarUrl.dispose();
    super.dispose();
  }

  String? _requiredName(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty || text.length > 100) {
      return 'Campo requerido, máximo 100 caracteres.';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isNotEmpty &&
        !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(text)) {
      return 'Ingresa un correo válido.';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty || text.length > 30) {
      return 'Ingresa un teléfono (máximo 30 caracteres).';
    }
    return null;
  }

  String? _validateAvatarUrl(String? value) {
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
      await widget.repository.updateUser(
        widget.user.id,
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        email: _email.text.trim().isEmpty ? null : _email.text.trim(),
        phone: _phone.text.trim(),
        avatarUrl: _avatarUrl.text.trim().isEmpty
            ? null
            : _avatarUrl.text.trim(),
      );
      if (mounted) Navigator.of(context).pop(true);
    } on ApiFailure catch (failure) {
      if (mounted) setState(() => _error = failure.message);
    } on Object {
      if (mounted) setState(() => _error = 'No se pudo guardar el perfil.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Editar usuario')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              TextFormField(
                controller: _firstName,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: _requiredName,
                enabled: !_saving,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lastName,
                decoration: const InputDecoration(labelText: 'Apellido'),
                validator: _requiredName,
                enabled: !_saving,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                ),
                validator: _validateEmail,
                enabled: !_saving,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Teléfono'),
                validator: _validatePhone,
                enabled: !_saving,
              ),
              const SizedBox(height: 8),
              const Text(
                'El teléfono se muestra solo en esta ficha administrativa.',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _avatarUrl,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'URL de imagen de perfil',
                ),
                validator: _validateAvatarUrl,
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
                        : const Text('Guardar cambios'),
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
