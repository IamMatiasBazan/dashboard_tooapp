import 'package:dio/dio.dart';

import '../../../core/session/admin_session.dart';

class AuthRepository {
  AuthRepository({required this._dio, required this._session});

  final Dio _dio;
  final AdminSession _session;

  Future<void> login({required String email, required String password}) async {
    final response = await _dio.post<Object?>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    final root = _asObject(response.data);
    final data = _asObject(root['data']);
    final user = _asObject(data['user']);
    if (user['role'] != 'ADMIN') {
      _session.clear();
      throw const AuthFailure('Esta cuenta no tiene acceso administrativo.');
    }
    final access = data['accessToken'];
    final refresh = data['refreshToken'];
    if (access is! String || refresh is! String) {
      throw const AuthFailure('Respuesta de autenticación inválida.');
    }
    _session.establish(access: access, refresh: refresh);
  }

  Future<bool> logout() async {
    final access = _session.accessToken;
    final refresh = _session.refreshToken;
    var remotelyConfirmed = false;
    try {
      if (access != null && refresh != null) {
        final response = await _dio.post<Object?>(
          '/auth/logout',
          data: {'refreshToken': refresh},
          options: Options(headers: {'Authorization': 'Bearer $access'}),
        );
        remotelyConfirmed = response.statusCode == 204;
      }
    } on DioException {
      remotelyConfirmed = false;
    } finally {
      _session.clear();
    }
    return remotelyConfirmed;
  }

  static Map<String, Object?> _asObject(Object? value) {
    if (value is Map<String, Object?>) return value;
    throw const AuthFailure('Respuesta de autenticación inválida.');
  }
}

class AuthFailure implements Exception {
  const AuthFailure(this.message);
  final String message;
  @override
  String toString() => message;
}
