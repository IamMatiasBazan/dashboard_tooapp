import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tooapp_dashboard/src/core/network/api_client.dart';
import 'package:tooapp_dashboard/src/core/network/api_failure.dart';
import 'package:tooapp_dashboard/src/core/session/admin_session.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);
  final Future<ResponseBody> Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) => handler(options);

  @override
  void close({bool force = false}) {}
}

void main() {
  test('API failures expose safe categories without response payloads', () {
    const failure = ApiFailure(
      ApiFailureKind.forbidden,
      'No tienes permiso.',
      statusCode: 403,
    );
    expect(failure.kind, ApiFailureKind.forbidden);
    expect(failure.statusCode, 403);
    expect(failure.toString(), 'No tienes permiso.');
  });

  test('unwraps the API data envelope into typed JSON', () async {
    final client = ApiClient(
      baseUrl: 'https://api.example.invalid',
      session: AdminSession(),
      dio: Dio(BaseOptions(baseUrl: 'https://api.example.invalid'))
        ..httpClientAdapter = _FakeAdapter(
          (_) async => ResponseBody.fromString('{"data":{"active":true}}', 200),
        ),
    );
    expect(await client.get('/admin/resource'), {'active': true});
  });

  test(
    'renews once after 401 and retries with the rotated access token',
    () async {
      final session = AdminSession()
        ..establish(access: 'old-access', refresh: 'old-refresh');
      final observedAuthorization = <String?>[];
      var resourceAttempts = 0;
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.invalid'))
        ..httpClientAdapter = _FakeAdapter((options) async {
          if (options.path == '/auth/refresh') {
            return ResponseBody.fromString(
              '{"data":{"accessToken":"new-access","refreshToken":"new-refresh"}}',
              200,
            );
          }
          resourceAttempts++;
          observedAuthorization.add(
            options.headers['Authorization'] as String?,
          );
          if (resourceAttempts == 1) {
            return ResponseBody.fromString(
              '{"error":{"code":"UNAUTHORIZED"}}',
              401,
            );
          }
          return ResponseBody.fromString('{"data":{"ready":true}}', 200);
        });
      final client = ApiClient(
        baseUrl: 'https://api.example.invalid',
        session: session,
        dio: dio,
      );

      expect(await client.get('/admin/resource'), {'ready': true});
      expect(resourceAttempts, 2);
      expect(observedAuthorization, ['Bearer old-access', 'Bearer new-access']);
      expect(session.refreshToken, 'new-refresh');
    },
  );

  test('maps forbidden responses without exposing the response body', () async {
    final client = ApiClient(
      baseUrl: 'https://api.example.invalid',
      session: AdminSession(),
      dio: Dio(BaseOptions(baseUrl: 'https://api.example.invalid'))
        ..httpClientAdapter = _FakeAdapter(
          (_) async =>
              ResponseBody.fromString('{"message":"private detail"}', 403),
        ),
    );
    await expectLater(
      client.get('/admin/resource'),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.kind,
          'kind',
          ApiFailureKind.forbidden,
        ),
      ),
    );
  });

  test('maps server failures without exposing response details', () async {
    final client = ApiClient(
      baseUrl: 'https://api.example.invalid',
      session: AdminSession(),
      dio: Dio(BaseOptions(baseUrl: 'https://api.example.invalid'))
        ..httpClientAdapter = _FakeAdapter(
          (_) async =>
              ResponseBody.fromString('{"message":"internal secret"}', 500),
        ),
    );
    await expectLater(
      client.get('/admin/resource'),
      throwsA(
        isA<ApiFailure>()
            .having((failure) => failure.kind, 'kind', ApiFailureKind.server)
            .having(
              (failure) => failure.message,
              'safe message',
              'El servidor no pudo completar la solicitud.',
            ),
      ),
    );
  });

  test('maps connection failures into a safe network error', () async {
    final client = ApiClient(
      baseUrl: 'https://api.example.invalid',
      session: AdminSession(),
      dio: Dio(BaseOptions(baseUrl: 'https://api.example.invalid'))
        ..httpClientAdapter = _FakeAdapter(
          (options) async => throw DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
            message: 'private socket detail',
          ),
        ),
    );
    await expectLater(
      client.get('/admin/resource'),
      throwsA(
        isA<ApiFailure>()
            .having((failure) => failure.kind, 'kind', ApiFailureKind.network)
            .having(
              (failure) => failure.message,
              'safe message',
              'No se pudo conectar con el servidor.',
            ),
      ),
    );
  });

  test('clears in-memory tokens when a coordinated refresh fails', () async {
    final session = AdminSession()
      ..establish(access: 'expired-access', refresh: 'expired-refresh');
    final client = ApiClient(
      baseUrl: 'https://api.example.invalid',
      session: session,
      dio: Dio(BaseOptions(baseUrl: 'https://api.example.invalid'))
        ..httpClientAdapter = _FakeAdapter(
          (options) async =>
              ResponseBody.fromString('{"error":{"code":"UNAUTHORIZED"}}', 401),
        ),
    );
    await expectLater(
      client.get('/admin/resource'),
      throwsA(isA<ApiFailure>()),
    );
    expect(session.accessToken, isNull);
    expect(session.refreshToken, isNull);
  });
}
