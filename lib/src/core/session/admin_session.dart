import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class AdminSession extends ChangeNotifier {
  String? accessToken;
  String? refreshToken;
  bool _renewing = false;
  Future<void>? _renewal;

  bool get isAuthenticated => accessToken != null && refreshToken != null;
  bool get isRenewing => _renewing;

  void establish({required String access, required String refresh}) {
    accessToken = access;
    refreshToken = refresh;
    notifyListeners();
  }

  void clear() {
    accessToken = null;
    refreshToken = null;
    notifyListeners();
  }

  Future<void> renew(Dio dio) => _renewal ??= _performRenewal(dio);

  Future<void> _performRenewal(Dio dio) async {
    final refresh = refreshToken;
    if (refresh == null) {
      clear();
      throw const _SessionFailure();
    }
    _renewing = true;
    try {
      final response = await dio.post<Object?>(
        '/auth/refresh',
        data: {'refreshToken': refresh},
      );
      final root = _object(response.data);
      final data = _object(root['data']);
      final access = data['accessToken'];
      final nextRefresh = data['refreshToken'];
      if (access is! String || nextRefresh is! String) {
        throw const _SessionFailure();
      }
      establish(access: access, refresh: nextRefresh);
    } on Object {
      clear();
      rethrow;
    } finally {
      _renewing = false;
      _renewal = null;
    }
  }

  static Map<String, Object?> _object(Object? value) {
    if (value is String) {
      try {
        value = jsonDecode(value);
      } on FormatException {
        throw const _SessionFailure();
      }
    }
    if (value is Map<String, Object?>) return value;
    throw const _SessionFailure();
  }
}

class _SessionFailure implements Exception {
  const _SessionFailure();
}
