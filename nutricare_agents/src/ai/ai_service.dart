import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'ai_config.dart';

/// Service class for interacting with AI APIs.
/// This class handles API requests, error handling, and response parsing.
class AIService {
  /// The configuration for the AI service
  final AIConfig config;
  
  /// HTTP client for making API requests
  final http.Client _client;

  /// Creates a new AIService with the specified configuration.
  AIService({
    required this.config,
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// Disposes resources used by the service.
  void dispose() {
    _client.close();
  }

  /// Makes a POST request to the specified endpoint with the given data.
  /// 
  /// [endpoint] - The API endpoint to call (without the base URL)
  /// [data] - The request payload as a Map
  /// [headers] - Additional headers to include in the request
  Future<Map<String, dynamic>> post({
    required String endpoint,
    required Map<String, dynamic> data,
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('${config.apiUrl}/$endpoint');
    final requestHeaders = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${config.apiKey}',
      ...?headers,
    };

    try {
      int attempts = 0;
      http.Response? response;
      Exception? lastError;

      while (attempts < config.maxRetries) {
        attempts++;
        try {
          response = await _client
              .post(
                url,
                headers: requestHeaders,
                body: jsonEncode(data),
              )
              .timeout(Duration(seconds: config.timeoutSeconds));
          break; // Success, exit retry loop
        } catch (e) {
          lastError = e is Exception ? e : Exception(e.toString());
          if (kDebugMode) {
            print('API request attempt $attempts failed: $e');
          }
          if (attempts >= config.maxRetries) {
            rethrow;
          }
          // Wait before retrying (exponential backoff)
          await Future.delayed(Duration(milliseconds: 500 * attempts * attempts));
        }
      }

      if (response == null) {
        throw lastError ?? Exception('Unknown error occurred during API request');
      }

      final responseBody = utf8.decode(response.bodyBytes);
      final responseData = jsonDecode(responseBody) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        final errorMessage = responseData['error'] ?? 'Unknown error';
        throw Exception('API error (${response.statusCode}): $errorMessage');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in API request to $endpoint: $e');
      }
      rethrow;
    }
  }

  /// Makes a GET request to the specified endpoint.
  /// 
  /// [endpoint] - The API endpoint to call (without the base URL)
  /// [queryParams] - Query parameters to include in the URL
  /// [headers] - Additional headers to include in the request
  Future<Map<String, dynamic>> get({
    required String endpoint,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('${config.apiUrl}/$endpoint').replace(
      queryParameters: queryParams?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );

    final requestHeaders = {
      'Authorization': 'Bearer ${config.apiKey}',
      ...?headers,
    };

    try {
      int attempts = 0;
      http.Response? response;
      Exception? lastError;

      while (attempts < config.maxRetries) {
        attempts++;
        try {
          response = await _client
              .get(
                uri,
                headers: requestHeaders,
              )
              .timeout(Duration(seconds: config.timeoutSeconds));
          break; // Success, exit retry loop
        } catch (e) {
          lastError = e is Exception ? e : Exception(e.toString());
          if (kDebugMode) {
            print('API request attempt $attempts failed: $e');
          }
          if (attempts >= config.maxRetries) {
            rethrow;
          }
          // Wait before retrying (exponential backoff)
          await Future.delayed(Duration(milliseconds: 500 * attempts * attempts));
        }
      }

      if (response == null) {
        throw lastError ?? Exception('Unknown error occurred during API request');
      }

      final responseBody = utf8.decode(response.bodyBytes);
      final responseData = jsonDecode(responseBody) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        final errorMessage = responseData['error'] ?? 'Unknown error';
        throw Exception('API error (${response.statusCode}): $errorMessage');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in API request to $endpoint: $e');
      }
      rethrow;
    }
  }
}
