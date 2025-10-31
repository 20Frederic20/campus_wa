import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class ApiService {
  
  // Constructeur privé
  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // Ajout des intercepteurs uniquement en mode debug
    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseHeader: true,  // Ajout des headers de réponse
          responseBody: true,
          error: true,
          compact: false,        // Format plus détaillé
          maxWidth: 90,         // Largeur maximale du log
          logPrint: (obj) {     // Personnalisation de l'affichage
            debugPrint('🌐 API Call: $obj');
          },
        ),
      );

      // Ajout d'un intercepteur personnalisé pour plus de détails
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            debugPrint('📤 Sending request to: ${options.uri}');
            return handler.next(options);
          },
          onResponse: (response, handler) {
            debugPrint('📥 Response received from: ${response.requestOptions.uri}');
            debugPrint('⏱️ Response time: ${response.requestOptions.extra['timeStamp']}');
            return handler.next(response);
          },
          onError: (error, handler) {
            debugPrint('❌ Error on: ${error.requestOptions.uri}');
            debugPrint('❌ Error message: ${error.message}');
            return handler.next(error);
          },
        ),
      );
    }

    // Ajout d'un intercepteur pour mesurer le temps de réponse
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.extra['timeStamp'] = DateTime.now();
          return handler.next(options);
        },
        onResponse: (response, handler) {
          final startTime = response.requestOptions.extra['timeStamp'] as DateTime;
          final endTime = DateTime.now();
          final duration = endTime.difference(startTime);
          response.requestOptions.extra['timeStamp'] = '${duration.inMilliseconds}ms';
          return handler.next(response);
        },
      ),
    );

    // Gestion des erreurs globales
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          // Vous pouvez ajouter une logique de rafraîchissement de token ici si nécessaire
          return handler.next(error);
        },
      ),
    );
  }

  static final ApiService _instance = ApiService._internal();
  late final Dio _dio;
  final String _baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  // Factory constructor pour retourner toujours la même instance
  factory ApiService() => _instance;

  // Méthode pour mettre à jour le token d'authentification
  void updateAuthToken(String? token) {
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  // Méthodes HTTP avec gestion d'erreur
  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? params,
    Map<String, dynamic>? headers,
  }) async {
    try {
      return await _dio.get(
        endpoint,
        queryParameters: params,
        options: headers != null ? Options(headers: headers) : null,
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<Response> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? params,
    Map<String, dynamic>? headers,
  }) async {
    try {
      return await _dio.post(
        endpoint,
        data: data,
        queryParameters: params,
        options: headers != null ? Options(headers: headers) : null,
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<Response> put(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? params,
    Map<String, dynamic>? headers,
  }) async {
    try {
      return await _dio.put(
        endpoint,
        data: data,
        queryParameters: params,
        options: headers != null ? Options(headers: headers) : null,
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<Response> delete(
    String endpoint, {
    Map<String, dynamic>? params,
    Map<String, dynamic>? headers,
  }) async {
    try {
      return await _dio.delete(
        endpoint,
        queryParameters: params,
        options: headers != null ? Options(headers: headers) : null,
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Gestion personnalisée des erreurs
  void _handleError(DioException e) {
    if (e.response != null) {
      // La requête a été faite et le serveur a répondu avec un statut d'erreur
      debugPrint('Erreur API:');
      debugPrint('Status: ${e.response?.statusCode}');
      debugPrint('Données: ${e.response?.data}');
      debugPrint('Headers: ${e.response?.headers}');
    } else {
      // Quelque chose s'est mal passé lors de la requête
      debugPrint('Erreur lors de la requête: ${e.message}');
    }
  }
}
