enum AdminReportType {
  suggestion('SUGGESTION'),
  claim('CLAIM'),
  userReport('USER_REPORT');

  const AdminReportType(this.apiValue);
  final String apiValue;

  static AdminReportType parse(Object? value) =>
      AdminReportType.values.firstWhere(
        (type) => type.apiValue == value,
        orElse: () => throw const FormatException('Tipo de reporte inválido.'),
      );
}

class ReportAuthorSummary {
  const ReportAuthorSummary({required this.firstName, required this.lastName});
  final String firstName;
  final String lastName;

  factory ReportAuthorSummary.fromJson(Map<String, Object?> json) {
    final firstName = json['firstName'];
    final lastName = json['lastName'];
    if (firstName is! String || lastName is! String) {
      throw const FormatException('Datos del autor inválidos.');
    }
    return ReportAuthorSummary(firstName: firstName, lastName: lastName);
  }
}

class AdminReport {
  const AdminReport({
    required this.id,
    required this.type,
    required this.content,
    required this.isResolved,
    required this.createdAt,
    required this.updatedAt,
    required this.author,
  });

  final String id;
  final AdminReportType type;
  final String content;
  final bool isResolved;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ReportAuthorSummary? author;

  factory AdminReport.fromJson(Map<String, Object?> json) {
    final authorValue = json['author'];
    final author = authorValue == null
        ? null
        : authorValue is Map<String, Object?>
        ? ReportAuthorSummary.fromJson(authorValue)
        : throw const FormatException('Datos del autor inválidos.');
    return AdminReport(
      id: _string(json, 'id'),
      type: AdminReportType.parse(json['type']),
      content: _string(json, 'content'),
      isResolved: json['isResolved'] as bool,
      createdAt: _date(json, 'createdAt'),
      updatedAt: _date(json, 'updatedAt'),
      author: author,
    );
  }

  static String _string(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is String) return value;
    throw FormatException('Campo requerido inválido: $key');
  }

  static DateTime _date(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed;
    }
    throw FormatException('Fecha requerida inválida: $key');
  }
}
