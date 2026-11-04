import '../../../core/network/api_client.dart';
import '../models/admin_report.dart';

class ReportRepository {
  const ReportRepository(this._client);
  final ApiClient _client;

  Future<List<AdminReport>> list({
    bool? isResolved,
    AdminReportType? type,
  }) async {
    final result = await _client.get(
      '/admin/reports',
      query: {
        if (isResolved != null) 'isResolved': isResolved.toString(),
        if (type != null) 'type': type.apiValue,
      },
    );
    final values = result['value'];
    if (values is! List<Object?>) {
      throw const FormatException('Respuesta de reportes inválida.');
    }
    return values
        .map((item) {
          if (item is! Map<String, Object?>) {
            throw const FormatException('Reporte inválido.');
          }
          return AdminReport.fromJson(item);
        })
        .toList(growable: false);
  }

  Future<AdminReport> resolve(String id) async {
    final result = await _client.patch('/admin/reports/$id/resolve');
    return AdminReport.fromJson(result);
  }
}
