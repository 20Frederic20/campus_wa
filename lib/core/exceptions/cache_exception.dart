class CacheException implements Exception {
  // Optionnel : pour des codes d'erreur spécifiques (e.g., 'CACHE_WRITE_FAILED')

  const CacheException(this.message, {this.code});
  final String message;
  final String? code;

  @override
  String toString() =>
      'CacheException: $message${code != null ? ' (Code: $code)' : ''}';
}
