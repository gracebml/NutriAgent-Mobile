import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// Các model dữ liệu
class MenuItem {
  final String name;
  final List<String> ingredients;
  final String preparation;
  final String? estimatedCost;
  final int? calories;
  final double? protein;
  final double? carbs;
  final double? fat;
  final List<String>? healthBenefits;

  MenuItem({
    required this.name,
    required this.ingredients,
    required this.preparation,
    this.estimatedCost,
    this.calories,
    this.protein,
    this.carbs,
    this.fat,
    this.healthBenefits,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      name: json['name'] as String,
      ingredients: List<String>.from(json['ingredients']),
      preparation: json['preparation'] as String,
      estimatedCost: json['estimatedCost'] as String?,
      calories: json['calories'] as int?,
      protein: json['protein'] as double?,
      carbs: json['carbs'] as double?,
      fat: json['fat'] as double?,
      healthBenefits: json['healthBenefits'] != null
          ? List<String>.from(json['healthBenefits'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'ingredients': ingredients,
      'preparation': preparation,
      if (estimatedCost != null) 'estimatedCost': estimatedCost,
      if (calories != null) 'calories': calories,
      if (protein != null) 'protein': protein,
      if (carbs != null) 'carbs': carbs,
      if (fat != null) 'fat': fat,
      if (healthBenefits != null) 'healthBenefits': healthBenefits,
    };
  }
}

class DailyMenu {
  final List<MenuItem> breakfast;
  final List<MenuItem> lunch;
  final List<MenuItem> dinner;
  final List<MenuItem>? snacks;

  DailyMenu({
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    this.snacks,
  });

  factory DailyMenu.fromJson(Map<String, dynamic> json) {
    return DailyMenu(
      breakfast: (json['breakfast'] as List)
          .map((item) => MenuItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      lunch: (json['lunch'] as List)
          .map((item) => MenuItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      dinner: (json['dinner'] as List)
          .map((item) => MenuItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      snacks: json['snacks'] != null
          ? (json['snacks'] as List)
              .map((item) => MenuItem.fromJson(item as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'breakfast': breakfast.map((item) => item.toJson()).toList(),
      'lunch': lunch.map((item) => item.toJson()).toList(),
      'dinner': dinner.map((item) => item.toJson()).toList(),
      if (snacks != null) 'snacks': snacks!.map((item) => item.toJson()).toList(),
    };
  }
}

class WeeklyMenu {
  final DailyMenu? monday;
  final DailyMenu? tuesday;
  final DailyMenu? wednesday;
  final DailyMenu? thursday;
  final DailyMenu? friday;
  final DailyMenu? saturday;
  final DailyMenu? sunday;

  WeeklyMenu({
    this.monday,
    this.tuesday,
    this.wednesday,
    this.thursday,
    this.friday,
    this.saturday,
    this.sunday,
  });

  factory WeeklyMenu.fromJson(Map<String, dynamic> json) {
    return WeeklyMenu(
      monday: json['Monday'] != null
          ? DailyMenu.fromJson(json['Monday'] as Map<String, dynamic>)
          : null,
      tuesday: json['Tuesday'] != null
          ? DailyMenu.fromJson(json['Tuesday'] as Map<String, dynamic>)
          : null,
      wednesday: json['Wednesday'] != null
          ? DailyMenu.fromJson(json['Wednesday'] as Map<String, dynamic>)
          : null,
      thursday: json['Thursday'] != null
          ? DailyMenu.fromJson(json['Thursday'] as Map<String, dynamic>)
          : null,
      friday: json['Friday'] != null
          ? DailyMenu.fromJson(json['Friday'] as Map<String, dynamic>)
          : null,
      saturday: json['Saturday'] != null
          ? DailyMenu.fromJson(json['Saturday'] as Map<String, dynamic>)
          : null,
      sunday: json['Sunday'] != null
          ? DailyMenu.fromJson(json['Sunday'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (monday != null) 'Monday': monday!.toJson(),
      if (tuesday != null) 'Tuesday': tuesday!.toJson(),
      if (wednesday != null) 'Wednesday': wednesday!.toJson(),
      if (thursday != null) 'Thursday': thursday!.toJson(),
      if (friday != null) 'Friday': friday!.toJson(),
      if (saturday != null) 'Saturday': saturday!.toJson(),
      if (sunday != null) 'Sunday': sunday!.toJson(),
    };
  }
}

class Citation {
  final String? title;
  final String uri;

  Citation({
    this.title,
    required this.uri,
  });

  factory Citation.fromJson(Map<String, dynamic> json) {
    return Citation(
      title: json['title'] as String?,
      uri: json['uri'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (title != null) 'title': title,
      'uri': uri,
    };
  }
}

class StepTrace {
  final String stepName;
  final String status; // 'success', 'error', 'skipped'
  final dynamic inputData;
  final Map<String, dynamic>? outputData;
  final String? errorDetails;
  final int? durationMs;

  StepTrace({
    required this.stepName,
    required this.status,
    this.inputData,
    this.outputData,
    this.errorDetails,
    this.durationMs,
  });

  factory StepTrace.fromJson(Map<String, dynamic> json) {
    return StepTrace(
      stepName: json['stepName'] as String,
      status: json['status'] as String,
      inputData: json['inputData'],
      outputData: json['outputData'] != null
          ? Map<String, dynamic>.from(json['outputData'])
          : null,
      errorDetails: json['errorDetails'] as String?,
      durationMs: json['durationMs'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stepName': stepName,
      'status': status,
      if (inputData != null) 'inputData': inputData,
      if (outputData != null) 'outputData': outputData,
      if (errorDetails != null) 'errorDetails': errorDetails,
      if (durationMs != null) 'durationMs': durationMs,
    };
  }
}

class GenerateMenuResponse {
  final dynamic menu; // Có thể là DailyMenu hoặc WeeklyMenu
  final String? feedbackRequest;
  final List<StepTrace> trace;
  final String menuType; // 'daily' hoặc 'weekly'
  final List<Citation>? citations;
  final String? searchSuggestionHtml;

  GenerateMenuResponse({
    this.menu,
    this.feedbackRequest,
    required this.trace,
    required this.menuType,
    this.citations,
    this.searchSuggestionHtml,
  });

  factory GenerateMenuResponse.fromJson(Map<String, dynamic> json) {
    return GenerateMenuResponse(
      menu: json['menu'] != null
          ? json['menuType'] == 'daily'
              ? DailyMenu.fromJson(json['menu'] as Map<String, dynamic>)
              : WeeklyMenu.fromJson(json['menu'] as Map<String, dynamic>)
          : null,
      feedbackRequest: json['feedbackRequest'] as String?,
      trace: (json['trace'] as List)
          .map((item) => StepTrace.fromJson(item as Map<String, dynamic>))
          .toList(),
      menuType: json['menuType'] as String,
      citations: json['citations'] != null
          ? (json['citations'] as List)
              .map((item) => Citation.fromJson(item as Map<String, dynamic>))
              .toList()
          : null,
      searchSuggestionHtml: json['searchSuggestionHtml'] as String?,
    );
  }
}

// Lớp chính để gọi API và xử lý kết quả
class MenuGenerator {
  final String apiUrl;
  final String apiKey;

  MenuGenerator({
    required this.apiUrl,
    required this.apiKey,
  });

  // Phương thức chính để tạo thực đơn từ sở thích
  Future<GenerateMenuResponse> generateMenuFromPreferences({
    required String preferences,
    required String menuType, // 'daily' hoặc 'weekly'
  }) async {
    try {
      // Chuẩn bị dữ liệu gửi đi
      final Map<String, dynamic> requestData = {
        'preferences': preferences,
        'menuType': menuType,
      };

      // Gọi API
      final response = await http.post(
        Uri.parse('$apiUrl/api/generate-menu'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode(requestData),
      );

      // Kiểm tra kết quả
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return GenerateMenuResponse.fromJson(responseData);
      } else {
        throw Exception('Lỗi API: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      // Xử lý lỗi
      if (kDebugMode) {
        print('Lỗi khi tạo thực đơn: $e');
      }
      rethrow;
    }
  }

  // Phương thức phụ để phân tích văn bản thực đơn thành cấu trúc dữ liệu
  Future<dynamic> parseMenuText({
    required String menuText,
    required String menuType, // 'daily' hoặc 'weekly'
  }) async {
    try {
      // Chuẩn bị dữ liệu gửi đi
      final Map<String, dynamic> requestData = {
        'menuText': menuText,
        'menuType': menuType,
      };

      // Gọi API
      final response = await http.post(
        Uri.parse('$apiUrl/api/parse-menu-text'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode(requestData),
      );

      // Kiểm tra kết quả
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        
        // Trả về cấu trúc dữ liệu phù hợp với loại thực đơn
        if (menuType == 'daily') {
          return DailyMenu.fromJson(responseData);
        } else {
          return WeeklyMenu.fromJson(responseData);
        }
      } else {
        throw Exception('Lỗi API: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      // Xử lý lỗi
      if (kDebugMode) {
        print('Lỗi khi phân tích văn bản thực đơn: $e');
      }
      rethrow;
    }
  }

  // Phương thức mô phỏng để tạo thực đơn mẫu (sử dụng khi không có API)
  Future<GenerateMenuResponse> generateSampleMenu({
    required String menuType, // 'daily' hoặc 'weekly'
  }) async {
    // Tạo dữ liệu mẫu
    if (menuType == 'daily') {
      final dailyMenu = DailyMenu(
        breakfast: [
          MenuItem(
            name: 'Phở gà',
            ingredients: ['Bánh phở', 'Thịt gà', 'Hành, gừng', 'Gia vị'],
            preparation: 'Ninh xương gà làm nước dùng. Luộc thịt gà, xé nhỏ. Trần bánh phở. Bày phở ra tô, thêm thịt gà và chan nước dùng. Ăn kèm rau thơm.',
            estimatedCost: 'Khoảng 40.000đ',
            calories: 450,
            protein: 25.5,
            carbs: 65.0,
            fat: 10.2,
            healthBenefits: ['Cung cấp protein', 'Dễ tiêu hóa', 'Tăng cường năng lượng buổi sáng'],
          ),
        ],
        lunch: [
          MenuItem(
            name: 'Cơm gà lá chanh',
            ingredients: ['Gạo', 'Thịt gà', 'Lá chanh', 'Gia vị'],
            preparation: 'Ướp thịt gà với gia vị, lá chanh. Nấu cơm. Chiên gà. Trình bày cơm với gà và rau sống kèm theo.',
            estimatedCost: 'Khoảng 35.000đ',
            calories: 550,
            protein: 30.0,
            carbs: 70.0,
            fat: 15.5,
          ),
        ],
        dinner: [
          MenuItem(
            name: 'Canh chua cá lóc',
            ingredients: ['Cá lóc', 'Đậu bắp', 'Dứa', 'Me chua', 'Rau ngổ'],
            preparation: 'Nấu nước dùng chua từ me. Thêm cá lóc đã sơ chế. Cho rau củ vào nấu chín. Nêm nếm gia vị vừa ăn.',
            estimatedCost: 'Khoảng 50.000đ',
            calories: 320,
            protein: 22.0,
            carbs: 15.0,
            fat: 8.0,
          ),
        ],
      );

      return GenerateMenuResponse(
        menu: dailyMenu,
        feedbackRequest: 'Bạn thấy thực đơn này có phù hợp không? Bạn muốn thay đổi gì?',
        trace: [
          StepTrace(
            stepName: 'Bước 1: Tìm kiếm Thông tin (RAG)',
            status: 'success',
            durationMs: 1200,
          ),
          StepTrace(
            stepName: 'Bước 2: Lập Kế hoạch & Suy luận (Reasoning)',
            status: 'success',
            durationMs: 800,
          ),
          StepTrace(
            stepName: 'Bước 3: Tạo Nội dung Thực đơn',
            status: 'success',
            durationMs: 1500,
          ),
        ],
        menuType: 'daily',
      );
    } else {
      // Tạo menu tuần mẫu
      final weeklyMenu = WeeklyMenu(
        monday: DailyMenu(
          breakfast: [
            MenuItem(
              name: 'Bánh mì thịt',
              ingredients: ['Bánh mì', 'Thịt heo', 'Rau sống', 'Gia vị'],
              preparation: 'Ướp thịt với gia vị, nướng chín. Kẹp vào bánh mì với rau sống và nước sốt.',
              estimatedCost: 'Khoảng 20.000đ',
              calories: 350,
              protein: 15.0,
              carbs: 45.0,
              fat: 12.0,
            ),
          ],
          lunch: [
            MenuItem(
              name: 'Bún chả',
              ingredients: ['Bún', 'Thịt heo', 'Rau sống', 'Nước mắm pha'],
              preparation: 'Ướp thịt với gia vị, nướng chín. Ăn kèm với bún, rau sống và nước mắm pha.',
              estimatedCost: 'Khoảng 35.000đ',
              calories: 450,
              protein: 25.0,
              carbs: 60.0,
              fat: 15.0,
            ),
          ],
          dinner: [
            MenuItem(
              name: 'Cá kho tộ',
              ingredients: ['Cá lóc', 'Nước mắm', 'Đường', 'Ớt', 'Hành'],
              preparation: 'Ướp cá với gia vị. Kho cá với nước mắm, đường, ớt, hành cho đến khi cá chín mềm và nước kho cạn sệt.',
              estimatedCost: 'Khoảng 45.000đ',
              calories: 380,
              protein: 30.0,
              carbs: 10.0,
              fat: 18.0,
            ),
          ],
        ),
        tuesday: DailyMenu(
          breakfast: [
            MenuItem(
              name: 'Cháo trắng thịt bằm',
              ingredients: ['Gạo', 'Thịt heo bằm', 'Hành phi', 'Gia vị'],
              preparation: 'Nấu cháo từ gạo. Xào thịt bằm với gia vị. Cho thịt lên cháo và rắc hành phi.',
              estimatedCost: 'Khoảng 25.000đ',
              calories: 300,
              protein: 18.0,
              carbs: 40.0,
              fat: 8.0,
            ),
          ],
          lunch: [
            MenuItem(
              name: 'Cơm sườn nướng',
              ingredients: ['Gạo', 'Sườn heo', 'Gia vị ướp', 'Dưa chua'],
              preparation: 'Ướp sườn với gia vị, nướng chín. Ăn kèm với cơm và dưa chua.',
              estimatedCost: 'Khoảng 40.000đ',
              calories: 550,
              protein: 28.0,
              carbs: 65.0,
              fat: 20.0,
            ),
          ],
          dinner: [
            MenuItem(
              name: 'Canh khổ qua nhồi thịt',
              ingredients: ['Khổ qua', 'Thịt heo bằm', 'Nấm mèo', 'Gia vị'],
              preparation: 'Nhồi thịt bằm vào khổ qua. Nấu canh với nước dùng xương.',
              estimatedCost: 'Khoảng 35.000đ',
              calories: 320,
              protein: 22.0,
              carbs: 15.0,
              fat: 12.0,
            ),
          ],
        ),
      );

      return GenerateMenuResponse(
        menu: weeklyMenu,
        feedbackRequest: 'Bạn thấy thực đơn tuần này có phù hợp không? Bạn muốn thay đổi gì?',
        trace: [
          StepTrace(
            stepName: 'Bước 1: Tìm kiếm Thông tin (RAG)',
            status: 'success',
            durationMs: 1500,
          ),
          StepTrace(
            stepName: 'Bước 2: Lập Kế hoạch & Suy luận (Reasoning)',
            status: 'success',
            durationMs: 1200,
          ),
          StepTrace(
            stepName: 'Bước 3: Tạo Nội dung Thực đơn',
            status: 'success',
            durationMs: 2500,
          ),
        ],
        menuType: 'weekly',
      );
    }
  }
}