enum CategoryStatus {
  approved('APPROVED'),
  pending('PENDING'),
  rejected('REJECTED');

  const CategoryStatus(this.apiValue);
  final String apiValue;

  static CategoryStatus parse(Object? value) =>
      CategoryStatus.values.firstWhere(
        (status) => status.apiValue == value,
        orElse: () =>
            throw const FormatException('Estado de categoría inválido.'),
      );
}

class AdminCategory {
  const AdminCategory({
    required this.id,
    required this.name,
    required this.iconUrl,
    required this.status,
    required this.isActive,
    required this.createdAt,
    required this.primaryProviders,
    required this.secondaryProviders,
  });

  final String id;
  final String name;
  final String? iconUrl;
  final CategoryStatus status;
  final bool isActive;
  final DateTime? createdAt;
  final int? primaryProviders;
  final int? secondaryProviders;

  factory AdminCategory.fromJson(Map<String, Object?> json) {
    final count = json['_count'];
    final countJson = count is Map<String, Object?> ? count : null;
    return AdminCategory(
      id: _requiredString(json, 'id'),
      name: _requiredString(json, 'name'),
      iconUrl: json['iconUrl'] as String?,
      status: CategoryStatus.parse(json['status']),
      isActive: json['isActive'] as bool,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      primaryProviders: countJson?['primaryProviders'] as int?,
      secondaryProviders: countJson?['secondaryProviders'] as int?,
    );
  }

  static String _requiredString(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is String) return value;
    throw FormatException('Campo requerido inválido: $key');
  }
}
