import '../../../core/network/api_client.dart';
import '../models/admin_read_models.dart' hide JsonObject;

class AdminReadRepository {
  const AdminReadRepository(this._client);
  final ApiClient _client;

  Future<AdminReadPage<AdminUser>> users({
    required int page,
    String? query,
    bool? active,
  }) async => AdminReadPage.fromJson(
    await _client.get(
      '/admin/users',
      query: {
        'page': page,
        'limit': 20,
        if (query != null && query.isNotEmpty) 'q': query,
        if (active != null) 'isAccountActive': active.toString(),
      },
    ),
    AdminUser.fromJson,
  );

  Future<AdminUser> user(String id) async =>
      AdminUser.fromJson(await _client.get('/admin/users/$id'));

  Future<JsonObject> updateUser(
    String id, {
    required String firstName,
    required String lastName,
    required String? email,
    required String phone,
    required String? avatarUrl,
  }) => _client.patch(
    '/admin/users/$id',
    body: {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'avatarUrl': avatarUrl,
    },
  );

  Future<JsonObject> setUserAccountActive(String id, bool isAccountActive) =>
      _client.patch(
        '/admin/users/$id/account-status',
        body: {'isAccountActive': isAccountActive},
      );

  Future<AdminProvider> updateProvider(
    String providerProfileId, {
    JsonObject? user,
    JsonObject? providerProfile,
  }) async => AdminProvider.fromJson(
    await _client.patch(
      '/admin/providers/$providerProfileId',
      body: {
        if (user != null && user.isNotEmpty) 'user': user,
        if (providerProfile != null && providerProfile.isNotEmpty)
          'providerProfile': providerProfile,
      },
    ),
  );

  Future<AdminReadPage<AdminProvider>> providers({
    required int page,
    String? query,
    String? categoryId,
    bool? available,
  }) async => AdminReadPage.fromJson(
    await _client.get(
      '/admin/providers',
      query: {
        'page': page,
        'limit': 20,
        if (query != null && query.isNotEmpty) 'q': query,
        'categoryId': ?categoryId,
        if (available != null) 'isAvailable': available.toString(),
      },
    ),
    AdminProvider.fromJson,
  );

  Future<AdminProvider> provider(String id) async =>
      AdminProvider.fromJson(await _client.get('/admin/providers/$id'));

  Future<AdminReadPage<AdminReview>> reviews({
    required int page,
    String? providerProfileId,
    int? rating,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async => AdminReadPage.fromJson(
    await _client.get(
      '/admin/reviews',
      query: {
        'page': page,
        'limit': 20,
        'providerProfileId': ?providerProfileId,
        'rating': ?rating,
        if (dateFrom case final value?) 'dateFrom': value.toIso8601String(),
        if (dateTo case final value?) 'dateTo': value.toIso8601String(),
      },
    ),
    AdminReview.fromJson,
  );

  Future<AdminReadPage<AdminReview>> providerReviews({
    required String providerProfileId,
    required int page,
  }) async => AdminReadPage.fromJson(
    await _client.get(
      '/admin/providers/$providerProfileId/reviews',
      query: {'page': page, 'limit': 20},
    ),
    AdminReview.fromJson,
  );

  Future<AdminReadPage<AdminPortfolioImage>> portfolio({
    required int page,
    String? providerProfileId,
  }) async => AdminReadPage.fromJson(
    await _client.get(
      '/admin/portfolio',
      query: {
        'page': page,
        'limit': 20,
        'providerProfileId': ?providerProfileId,
      },
    ),
    AdminPortfolioImage.fromJson,
  );

  Future<AdminReadPage<AdminContact>> contacts({
    required int page,
    String? providerProfileId,
    String? categoryId,
    String? status,
  }) async => AdminReadPage.fromJson(
    await _client.get(
      '/admin/contact-intents',
      query: {
        'page': page,
        'limit': 20,
        'providerProfileId': ?providerProfileId,
        'categoryId': ?categoryId,
        'status': ?status,
      },
    ),
    AdminContact.fromJson,
  );

  Future<AdminContact> contact(String id) async =>
      AdminContact.fromJson(await _client.get('/admin/contact-intents/$id'));

  Future<AdminReadPage<AdminMembershipTier>> memberships({
    required int page,
    String? query,
  }) async => AdminReadPage.fromJson(
    await _client.get(
      '/admin/membership-tiers',
      query: {
        'page': page,
        'limit': 20,
        if (query != null && query.isNotEmpty) 'q': query,
      },
    ),
    AdminMembershipTier.fromJson,
  );

  Future<AdminMembershipTier> membership(String id) async =>
      AdminMembershipTier.fromJson(
        await _client.get('/admin/membership-tiers/$id'),
      );
}
