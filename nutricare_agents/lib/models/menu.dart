import 'package:nutricare_agents/models/menu_item.dart';

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