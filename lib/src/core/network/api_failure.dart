enum ApiFailureKind {
  unauthorized,
  forbidden,
  network,
  server,
  invalidResponse,
  unknown,
}

class ApiFailure implements Exception {
  const ApiFailure(this.kind, this.message, {this.statusCode});

  final ApiFailureKind kind;
  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
