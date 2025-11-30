class CacheException implements Exception {
  const CacheException(this.message, {this.code});
  final String message;
  final String? code;

  @override
  String toString() =>
      'CacheException: $message${code != null ? ' (Code: $code)' : ''}';
}
