import 'package:flutter/foundation.dart';

/// Configuration for AI services used in the NutriCare Agents app.
/// This class manages API endpoints, keys, and other settings for AI functionality.
class AIConfig {
  /// The base URL for the AI API
  final String apiUrl;
  
  /// The API key for authentication
  final String apiKey;
  
  /// The model to use for AI requests (e.g., 'gemini-2.0-flash')
  final String model;
  
  /// Maximum number of retries for failed API requests
  final int maxRetries;
  
  /// Timeout duration for API requests in seconds
  final int timeoutSeconds;

  /// Creates a new AIConfig instance with the specified parameters.
  const AIConfig({
    required this.apiUrl,
    required this.apiKey,
    required this.model,
    this.maxRetries = 3,
    this.timeoutSeconds = 30,
  });

  /// Creates a production configuration using environment variables or defaults.
  factory AIConfig.production({
    required String apiKey,
    String? apiUrl,
    String? model,
  }) {
    return AIConfig(
      apiUrl: apiUrl ?? 'https://api.nutricare.com',
      apiKey: apiKey,
      model: model ?? 'gemini-2.0-flash',
    );
  }

  /// Creates a development configuration for testing.
  factory AIConfig.development() {
    return const AIConfig(
      apiUrl: 'http://localhost:3000',
      apiKey: 'dev-api-key',
      model: 'gemini-2.0-flash',
      maxRetries: 1,
      timeoutSeconds: 60,
    );
  }

  /// Creates a mock configuration for testing without actual API calls.
  factory AIConfig.mock() {
    return const AIConfig(
      apiUrl: 'mock://api.nutricare.com',
      apiKey: 'mock-api-key',
      model: 'mock-model',
      maxRetries: 0,
      timeoutSeconds: 5,
    );
  }

  /// Logs the current configuration (excluding sensitive information).
  void logConfig() {
    if (kDebugMode) {
      print('AI Configuration:');
      print('- API URL: $apiUrl');
      print('- Model: $model');
      print('- Max Retries: $maxRetries');
      print('- Timeout: $timeoutSeconds seconds');
      // Don't log the API key for security reasons
    }
  }
}
