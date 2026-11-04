import 'package:flutter/material.dart';

import '../../../core/network/api_failure.dart';
import '../../categories/data/category_repository.dart';
import '../../categories/models/admin_category.dart';
import '../data/admin_read_repository.dart';
import '../models/admin_read_models.dart';

class AdminProviderEditPage extends StatefulWidget {
  const AdminProviderEditPage({
    required this.repository,
    required this.categoriesRepository,
    required this.provider,
    super.key,
  });

  final AdminReadRepository repository;
  final CategoryRepository categoriesRepository;
  final AdminProvider provider;

  @override
  State<AdminProviderEditPage> createState() => _AdminProviderEditPageState();
}

class _AdminProviderEditPageState extends State<AdminProviderEditPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _avatarUrl;
  late final TextEditingController _bio;
  late final TextEditingController _experience;
  late final TextEditingController _matricula;
  late final TextEditingController _coverageRadius;
  late final TextEditingController _minPrice;
  late final TextEditingController _consultationPrice;
  List<AdminCategory> _categories = const [];
  String? _categoryId;
  bool? _isMatriculado;
  bool? _chargesConsultation;
  bool? _issuesInvoice;
  String? _invoiceType;
  bool _loadingCategories = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final provider = widget.provider;
    _firstName = TextEditingController(text: provider.firstName);
    _lastName = TextEditingController(text: provider.lastName);
    _email = TextEditingController(text: provider.email ?? '');
    _phone = TextEditingController(text: provider.phone ?? '');
    _avatarUrl = TextEditingController(text: provider.avatarUrl ?? '');
    _bio = TextEditingController(text: provider.bio ?? '');
    _experience = TextEditingController(
      text: provider.experienceYears?.toString() ?? '',
    );
    _matricula = TextEditingController(text: provider.matriculaNumber ?? '');
    _coverageRadius = TextEditingController(
      text: provider.coverageRadiusKm?.toString() ?? '',
    );
    _minPrice = TextEditingController(
      text: provider.minPrice?.toString() ?? '',
    );
    _consultationPrice = TextEditingController(
      text: provider.consultationPrice?.toString() ?? '',
    );
    _categoryId = provider.primaryCategoryId;
    _isMatriculado = provider.isMatriculado;
    _chargesConsultation = provider.chargesConsultation;
    _issuesInvoice = provider.issuesInvoice;
    _invoiceType = provider.invoiceType;
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await widget.categoriesRepository.list();
      if (mounted) setState(() => _categories = categories);
    } on Object {
      if (mounted) {
        setState(() => _error = 'No se pudieron cargar las categorías.');
      }
    } finally {
      if (mounted) setState(() => _loadingCategories = false);
    }
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    _avatarUrl.dispose();
    _bio.dispose();
    _experience.dispose();
    _matricula.dispose();
    _coverageRadius.dispose();
    _minPrice.dispose();
    _consultationPrice.dispose();
    super.dispose();
  }

  String? _integer(String? value, {bool required = false}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return required ? 'Este campo es obligatorio.' : null;
    final number = int.tryParse(text);
    if (number == null || number < 0) {
      return 'Ingresa un entero mayor o igual a 0.';
    }
    return null;
  }

  int? _nullableInt(String value) =>
      value.trim().isEmpty ? null : int.parse(value.trim());

  String? _requiredText(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Este campo es obligatorio.';
    if (text.length > 100) return 'Usa hasta 100 caracteres.';
    return null;
  }

  String? _phoneValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Este campo es obligatorio.';
    if (text.length > 30) return 'Usa hasta 30 caracteres.';
    return null;
  }

  String? _emailValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    if (!RegExp(r'^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$').hasMatch(text)) {
      return 'Ingresa un correo válido.';
    }
    return null;
  }

  String? _urlValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final uri = Uri.tryParse(text);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      return 'Ingresa una URL válida.';
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final old = widget.provider;
    final user = <String, Object?>{};
    final firstName = _firstName.text.trim();
    if (firstName != old.firstName) user['firstName'] = firstName;
    final lastName = _lastName.text.trim();
    if (lastName != old.lastName) user['lastName'] = lastName;
    final email = _email.text.trim();
    if (email != (old.email ?? '')) {
      user['email'] = email.isEmpty ? null : email;
    }
    final phone = _phone.text.trim();
    if (phone != (old.phone ?? '')) user['phone'] = phone;
    final avatarUrl = _avatarUrl.text.trim();
    if (avatarUrl != (old.avatarUrl ?? '')) {
      user['avatarUrl'] = avatarUrl.isEmpty ? null : avatarUrl;
    }
    final fields = <String, Object?>{};
    if (_categoryId != old.primaryCategoryId) {
      fields['primaryCategoryId'] = _categoryId;
    }
    if (_bio.text.trim() != (old.bio ?? '')) fields['bio'] = _bio.text.trim();
    final experience = _nullableInt(_experience.text);
    if (experience != old.experienceYears) {
      fields['experienceYears'] = experience;
    }
    if (_isMatriculado != old.isMatriculado) {
      fields['isMatriculado'] = _isMatriculado;
    }
    if (_matricula.text.trim() != (old.matriculaNumber ?? '')) {
      fields['matriculaNumber'] = _matricula.text.trim().isEmpty
          ? null
          : _matricula.text.trim();
    }
    final coverage = _nullableInt(_coverageRadius.text);
    if (coverage != old.coverageRadiusKm) fields['coverageRadiusKm'] = coverage;
    final minPrice = _nullableInt(_minPrice.text);
    if (minPrice != old.minPrice) fields['minPrice'] = minPrice;
    if (_chargesConsultation != old.chargesConsultation) {
      fields['chargesConsultation'] = _chargesConsultation;
    }
    final consultationPrice = _nullableInt(_consultationPrice.text);
    if (consultationPrice != old.consultationPrice) {
      fields['consultationPrice'] = consultationPrice;
    }
    if (_issuesInvoice != old.issuesInvoice) {
      fields['issuesInvoice'] = _issuesInvoice;
    }
    if (_invoiceType != old.invoiceType && _invoiceType != null) {
      fields['invoiceType'] = _invoiceType;
    }
    if (fields.isEmpty && user.isEmpty) {
      Navigator.of(context).pop(false);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.repository.updateProvider(
        widget.provider.id,
        user: user,
        providerProfile: fields,
      );
      if (mounted) Navigator.of(context).pop(true);
    } on ApiFailure catch (failure) {
      if (mounted) setState(() => _error = failure.message);
    } on Object {
      if (mounted) {
        setState(() => _error = 'No se pudo guardar el perfil del prestador.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _nullableBoolField({
    required String label,
    required bool? value,
    required ValueChanged<bool?> onChanged,
  }) => DropdownButtonFormField<bool?>(
    initialValue: value,
    decoration: InputDecoration(labelText: label),
    items: const [
      DropdownMenuItem<bool?>(value: null, child: Text('Sin dato')),
      DropdownMenuItem<bool?>(value: true, child: Text('Sí')),
      DropdownMenuItem<bool?>(value: false, child: Text('No')),
    ],
    onChanged: _saving ? null : onChanged,
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Editar perfil del prestador')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: _loadingCategories
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    TextFormField(
                      key: const Key('provider-edit-first-name'),
                      controller: _firstName,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                      validator: _requiredText,
                      enabled: !_saving,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _lastName,
                      decoration: const InputDecoration(labelText: 'Apellido'),
                      validator: _requiredText,
                      enabled: !_saving,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _email,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                      ),
                      validator: _emailValidator,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !_saving,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phone,
                      decoration: const InputDecoration(labelText: 'Teléfono'),
                      validator: _phoneValidator,
                      keyboardType: TextInputType.phone,
                      enabled: !_saving,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _avatarUrl,
                      decoration: const InputDecoration(
                        labelText: 'URL de imagen de perfil',
                      ),
                      validator: _urlValidator,
                      keyboardType: TextInputType.url,
                      enabled: !_saving,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Perfil profesional',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _categoryId,
                      decoration: const InputDecoration(
                        labelText: 'Oficio principal',
                      ),
                      items: [
                        for (final category in _categories)
                          DropdownMenuItem(
                            value: category.id,
                            child: Text(category.name),
                          ),
                      ],
                      validator: (value) => value == null
                          ? 'Selecciona una categoría activa.'
                          : null,
                      onChanged: _saving
                          ? null
                          : (value) => setState(() => _categoryId = value),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      key: const Key('provider-edit-bio'),
                      controller: _bio,
                      maxLength: 5000,
                      maxLines: 5,
                      decoration: const InputDecoration(labelText: 'Biografía'),
                      enabled: !_saving,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _experience,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Años de experiencia',
                      ),
                      validator: _integer,
                      enabled: !_saving,
                    ),
                    const SizedBox(height: 12),
                    _nullableBoolField(
                      label: 'Matriculado',
                      value: _isMatriculado,
                      onChanged: (value) =>
                          setState(() => _isMatriculado = value),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _matricula,
                      maxLength: 50,
                      decoration: const InputDecoration(labelText: 'Matrícula'),
                      enabled: !_saving,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _coverageRadius,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Radio de cobertura (km)',
                      ),
                      validator: _integer,
                      enabled: !_saving,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _minPrice,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Precio mínimo indicativo',
                      ),
                      validator: _integer,
                      enabled: !_saving,
                    ),
                    const SizedBox(height: 12),
                    _nullableBoolField(
                      label: 'Cobra consulta',
                      value: _chargesConsultation,
                      onChanged: (value) =>
                          setState(() => _chargesConsultation = value),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _consultationPrice,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Precio de consulta',
                      ),
                      validator: _integer,
                      enabled: !_saving,
                    ),
                    const SizedBox(height: 12),
                    _nullableBoolField(
                      label: 'Emite comprobante',
                      value: _issuesInvoice,
                      onChanged: (value) =>
                          setState(() => _issuesInvoice = value),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _invoiceType,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de comprobante',
                      ),
                      items: const [
                        DropdownMenuItem(value: 'NONE', child: Text('NONE')),
                        DropdownMenuItem(
                          value: 'FACTURA_C',
                          child: Text('FACTURA_C'),
                        ),
                        DropdownMenuItem(
                          value: 'FACTURA_A_B',
                          child: Text('FACTURA_A_B'),
                        ),
                        DropdownMenuItem(value: 'OTHER', child: Text('OTHER')),
                      ],
                      onChanged: _saving
                          ? null
                          : (value) => setState(() => _invoiceType = value),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
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
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
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
