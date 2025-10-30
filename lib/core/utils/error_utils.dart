import 'package:dio/dio.dart';

String getErrorMessage(dynamic error) {
  if (error is String) return error;
  
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Délai de connexion dépassé. Vérifiez votre connexion internet.';
      case DioExceptionType.sendTimeout:
        return 'Délai d\'envoi dépassé. Veuillez réessayer.';
      case DioExceptionType.receiveTimeout:
        return 'Délai de réponse dépassé. Le serveur met trop de temps à répondre.';
      case DioExceptionType.badResponse:
        return _handleResponseError(error.response);
      case DioExceptionType.cancel:
        return 'Requête annulée';
      case DioExceptionType.unknown:
      default:
        return 'Erreur de connexion. Vérifiez votre connexion internet.';
    }
  }
  
  return 'Une erreur est survenue. Veuillez réessayer.';
}

String _handleResponseError(Response? response) {
  if (response == null) return 'Aucune réponse du serveur';
  
  switch (response.statusCode) {
    case 400:
      return 'Requête incorrecte';
    case 401:
      return 'Non autorisé. Veuillez vous reconnecter.';
    case 403:
      return 'Accès refusé';
    case 404:
      return 'Ressource non trouvée';
    case 500:
      return 'Erreur interne du serveur';
    case 502:
      return 'Mauvaise passerelle';
    case 503:
      return 'Service indisponible';
    case 504:
      return 'Délai de réponse du serveur dépassé';
    default:
      return 'Erreur ${response.statusCode}';
  }
}