import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'ai_service.dart';

/// Class for handling menu modification suggestions based on user feedback.
class MenuModifier {
  /// The AI service to use for API calls
  final AIService aiService;

  /// Creates a new MenuModifier with the specified AI service.
  MenuModifier({required this.aiService});

  /// Suggests modifications to a menu based on user feedback.
  /// 
  /// [menu] - The current menu as a string
  /// [feedback] - User feedback on the menu
  /// [userPreferences] - Optional user preferences to consider
  Future<MenuModificationResult> suggestMenuModifications({
    required String menu,
    required String feedback,
    String? userPreferences,
  }) async {
    try {
      // Prepare request data
      final Map<String, dynamic> requestData = {
        'menu': menu,
        'feedback': feedback,
        if (userPreferences != null) 'userPreferences': userPreferences,
      };

      // Call API
      final response = await aiService.post(
        endpoint: 'api/suggest-menu-modifications',
        data: requestData,
      );

      // Parse response
      return MenuModificationResult.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error suggesting menu modifications: $e');
      }
      rethrow;
    }
  }

  /// Parses a modified menu string into a structured format.
  /// This is useful when the API returns a text-based menu that needs to be converted
  /// to a structured format for display in the app.
  /// 
  /// [menuString] - The menu string to parse
  /// [menuType] - The type of menu ('daily' or 'weekly')
  Future<dynamic> parseModifiedMenuText({
    required String menuString,
    required String menuType,
  }) async {
    try {
      // Prepare request data
      final Map<String, dynamic> requestData = {
        'menuText': menuString,
        'menuType': menuType,
      };

      // Call API
      final response = await aiService.post(
        endpoint: 'api/parse-menu-text',
        data: requestData,
      );

      // Return the parsed menu structure
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing modified menu text: $e');
      }
      rethrow;
    }
  }
}

/// Result of a menu modification suggestion.
class MenuModificationResult {
  /// The modified menu as a string, formatted using Markdown
  final String modifiedMenu;
  
  /// The reasoning behind the modifications, formatted using Markdown
  final String reasoning;

  /// Creates a new MenuModificationResult.
  MenuModificationResult({
    required this.modifiedMenu,
    required this.reasoning,
  });

  /// Creates a MenuModificationResult from a JSON object.
  factory MenuModificationResult.fromJson(Map<String, dynamic> json) {
    return MenuModificationResult(
      modifiedMenu: json['modifiedMenu'] as String,
      reasoning: json['reasoning'] as String,
    );
  }

  /// Converts this result to a JSON object.
  Map<String, dynamic> toJson() {
    return {
      'modifiedMenu': modifiedMenu,
      'reasoning': reasoning,
    };
  }
}
