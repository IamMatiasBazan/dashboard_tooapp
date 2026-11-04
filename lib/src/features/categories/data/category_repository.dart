import '../../../core/network/api_client.dart';
import '../models/admin_category.dart';

class CategoryRepository {
  const CategoryRepository(this._client);
  final ApiClient _client;

  Future<List<AdminCategory>> list({
    CategoryStatus? status,
    bool? active,
  }) async {
    final result = await _client.get(
      '/admin/categories',
      query: {
        if (status != null) 'status': status.apiValue,
        if (active != null) 'active': active.toString(),
      },
    );
    final values = result['value'];
    if (values is! List<Object?>) {
      throw const FormatException('Respuesta de categorías inválida.');
    }
    return values
        .map((item) {
          if (item is! Map<String, Object?>) {
            throw const FormatException('Respuesta de categoría inválida.');
          }
          return AdminCategory.fromJson(item);
        })
        .toList(growable: false);
  }

  Future<UnifyCategoryResult> unify({
    required String sourceCategoryId,
    required String targetCategoryId,
  }) async {
    final result = await _client.post(
      '/admin/categories/unify',
      body: {
        'sourceCategoryId': sourceCategoryId,
        'targetCategoryId': targetCategoryId,
      },
    );
    return UnifyCategoryResult.fromJson(result);
  }

  Future<AdminCategory> create({required String name, String? iconUrl}) async =>
      AdminCategory.fromJson(
        await _client.post(
          '/admin/categories',
          body: {'name': name, 'iconUrl': iconUrl},
        ),
      );

  Future<AdminCategory> update(
    String id, {
    required String name,
    String? iconUrl,
  }) async => AdminCategory.fromJson(
    await _client.patch(
      '/admin/categories/$id',
      body: {'name': name, 'iconUrl': iconUrl},
    ),
  );

  Future<AdminCategory> setActive(String id, bool isActive) async =>
      AdminCategory.fromJson(
        await _client.patch(
          '/admin/categories/$id/active',
          body: {'isActive': isActive},
        ),
      );
}

class UnifyCategoryResult {
  const UnifyCategoryResult({
    required this.message,
    required this.sourceCategoryId,
    required this.targetCategoryId,
    required this.updatedProvidersCount,
  });
  final String message;
  final String sourceCategoryId;
  final String targetCategoryId;
  final int updatedProvidersCount;

  factory UnifyCategoryResult.fromJson(Map<String, Object?> json) {
    final message = json['message'];
    final source = json['sourceCategoryId'];
    final target = json['targetCategoryId'];
    final count = json['updatedProvidersCount'];
    if (message is! String ||
        source is! String ||
        target is! String ||
        count is! int) {
      throw const FormatException('Respuesta de unificación inválida.');
    }
    return UnifyCategoryResult(
      message: message,
      sourceCategoryId: source,
      targetCategoryId: target,
      updatedProvidersCount: count,
    );
  }
}
