import 'dart:convert';

import 'package:dio/dio.dart';

import '../session/admin_session.dart';
import 'api_failure.dart';

typedef JsonObject = Map<String, Object?>;

class ApiClient {
  ApiClient({required String baseUrl, required this.session, Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: baseUrl,
              headers: const {
                'accept': 'application/json',
                'content-type': 'application/json',
              },
            ),
          ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = session.accessToken;
          if (token != null) options.headers['Authorization'] = 'Bearer $token';
          handler.next(options);
        },
      ),
    );
  }

  final Dio _dio;
  final AdminSession session;

  Future<JsonObject> get(String path, {Map<String, Object?>? query}) async {
    final response = await _request(
      () => _dio.get<Object?>(path, queryParameters: query),
    );
    return _readEnvelope(response.data);
  }

  Future<JsonObject> post(String path, {JsonObject? body}) async {
    final response = await _request(() => _dio.post<Object?>(path, data: body));
    return _readEnvelope(response.data);
  }

  Future<JsonObject> patch(String path, {JsonObject? body}) async {
    final response = await _request(
      () => _dio.patch<Object?>(path, data: body),
    );
    return _readEnvelope(response.data);
  }

  Future<Response<Object?>> _request(
    Future<Response<Object?>> Function() send,
  ) async {
    try {
      return await send();
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      if (status == 401 && session.accessToken != null) {
        try {
          await session.renew(_dio);
          try {
            return await send();
          } on DioException catch (retryError) {
            throw _failure(retryError);
          }
        } on Object {
          throw const ApiFailure(
            ApiFailureKind.unauthorized,
            'La sesión expiró.',
            statusCode: 401,
          );
        }
      }
      throw _failure(error);
    }
  }

  ApiFailure _failure(DioException error) {
    final status = error.response?.statusCode;
    if (status == 401) {
      return ApiFailure(
        ApiFailureKind.unauthorized,
        'La sesión no está autorizada.',
        statusCode: status,
      );
    }
    if (status == 403) {
      return ApiFailure(
        ApiFailureKind.forbidden,
        'No tienes permiso para esta operación.',
        statusCode: status,
      );
    }
    if (status != null && status >= 500) {
      return ApiFailure(
        ApiFailureKind.server,
        'El servidor no pudo completar la solicitud.',
        statusCode: status,
      );
    }
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return const ApiFailure(
        ApiFailureKind.network,
        'No se pudo conectar con el servidor.',
      );
    }
    return ApiFailure(
      ApiFailureKind.unknown,
      'No se pudo completar la solicitud.',
      statusCode: status,
    );
  }

  JsonObject _readEnvelope(Object? raw) {
    Object? decoded = raw;
    if (raw is String) {
      try {
        decoded = jsonDecode(raw);
      } on FormatException {
        throw const ApiFailure(
          ApiFailureKind.invalidResponse,
          'El servidor devolvió una respuesta inválida.',
        );
      }
    }
    if (decoded is! Map<String, Object?> || !decoded.containsKey('data')) {
      throw const ApiFailure(
        ApiFailureKind.invalidResponse,
        'El servidor devolvió una respuesta inválida.',
      );
    }
    final data = decoded['data'];
    if (data is Map<String, Object?>) return data;
    if (data is List<Object?>) {
      return <String, Object?>{
        'value': data,
        if (decoded['page'] is int) 'page': decoded['page'],
        if (decoded['limit'] is int) 'limit': decoded['limit'],
        if (decoded['total'] is int) 'total': decoded['total'],
        if (decoded.containsKey('ratingAverage'))
          'ratingAverage': decoded['ratingAverage'],
      };
    }
    return <String, Object?>{'value': data};
  }
}
