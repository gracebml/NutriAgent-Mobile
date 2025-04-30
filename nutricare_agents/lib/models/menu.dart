import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'meal.dart';

/// Represents a full meal plan for a day
/// Based on DailyMenuSchema from the web app
class DailyMenu extends Equatable {
  /// Breakfast meals
  final List<Meal> breakfast;
  
  /// Lunch meals
  final List<Meal> lunch;
  
  /// Dinner meals
  final List<Meal> dinner;
  
  /// Optional snacks
  final List<Meal>? snacks;
  
  /// Original preferences/request that generated this menu
  final String? originalPreferences;
  
  /// Date when this menu was created
  final DateTime? createdAt;
  
  /// User ID who created/owns this menu
  final String? createdBy;
  
  /// Title or name for this menu (optional)
  final String? title;

  /// Constructor
  const DailyMenu({
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    this.snacks,
    this.originalPreferences,
    this.createdAt,
    this.createdBy,
    this.title,
  });
  
  /// Create an empty daily menu
  static DailyMenu empty() {
    return const DailyMenu(
      breakfast: [],
      lunch: [],
      dinner: [],
      snacks: [],
    );
  }
  
  /// Get all meals in this daily menu as a single list
  List<Meal> get allMeals {
    final result = <Meal>[];
    result.addAll(breakfast);
    result.addAll(lunch);
    result.addAll(dinner);
    if (snacks != null) {
      result.addAll(snacks!);
    }
    return result;
  }
  
  /// Get the total calories for this daily menu
  int get totalCalories {
    return allMeals.fold(0, (sum, meal) => sum + (meal.calories ?? 0));
  }
  
  /// Get the total protein for this daily menu
  double get totalProtein {
    return allMeals.fold(0.0, (sum, meal) => sum + (meal.protein ?? 0));
  }
  
  /// Get the total carbs for this daily menu
  double get totalCarbs {
    return allMeals.fold(0.0, (sum, meal) => sum + (meal.carbs ?? 0));
  }
  
  /// Get the total fat for this daily menu
  double get totalFat {
    return allMeals.fold(0.0, (sum, meal) => sum + (meal.fat ?? 0));
  }
  
  /// Get all unique ingredients across all meals
  List<String> get allIngredients {
    final result = <String>{};
    for (final meal in allMeals) {
      result.addAll(meal.ingredients);
    }
    return result.toList();
  }
  
  /// Returns a map of meals by their type
  Map<MealType, List<Meal>> get mealsByType {
    return {
      MealType.breakfast: breakfast,
      MealType.lunch: lunch,
      MealType.dinner: dinner,
      MealType.snack: snacks ?? [],
    };
  }
  
  /// Get meals for a specific meal type
  List<Meal> getMealsByType(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return breakfast;
      case MealType.lunch:
        return lunch;
      case MealType.dinner:
        return dinner;
      case MealType.snack:
        return snacks ?? [];
    }
  }
  
  /// Set meals for a specific meal type
  DailyMenu updateMealsByType(MealType type, List<Meal> meals) {
    switch (type) {
      case MealType.breakfast:
        return copyWith(breakfast: meals);
      case MealType.lunch:
        return copyWith(lunch: meals);
      case MealType.dinner:
        return copyWith(dinner: meals);
      case MealType.snack:
        return copyWith(snacks: meals);
    }
  }
  
  /// Create a copy of this DailyMenu with the given fields replaced
  DailyMenu copyWith({
    List<Meal>? breakfast,
    List<Meal>? lunch,
    List<Meal>? dinner,
    List<Meal>? snacks,
    String? originalPreferences,
    DateTime? createdAt,
    String? createdBy,
    String? title,
  }) {
    return DailyMenu(
      breakfast: breakfast ?? this.breakfast,
      lunch: lunch ?? this.lunch,
      dinner: dinner ?? this.dinner,
      snacks: snacks ?? this.snacks,
      originalPreferences: originalPreferences ?? this.originalPreferences,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      title: title ?? this.title,
    );
  }
  
  /// Convert the DailyMenu to a Map
  Map<String, dynamic> toMap() {
    return {
      'breakfast': breakfast.map((meal) => meal.toMap()).toList(),
      'lunch': lunch.map((meal) => meal.toMap()).toList(),
      'dinner': dinner.map((meal) => meal.toMap()).toList(),
      'snacks': snacks?.map((meal) => meal.toMap()).toList(),
      'originalPreferences': originalPreferences,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'createdBy': createdBy,
      'title': title,
    };
  }
  
  /// Create a DailyMenu from a map
  factory DailyMenu.fromMap(Map<String, dynamic> map) {
    return DailyMenu(
      breakfast: (map['breakfast'] as List<dynamic>?)
          ?.map((item) => Meal.fromMap(item as Map<String, dynamic>))
          .toList() ?? [],
      lunch: (map['lunch'] as List<dynamic>?)
          ?.map((item) => Meal.fromMap(item as Map<String, dynamic>))
          .toList() ?? [],
      dinner: (map['dinner'] as List<dynamic>?)
          ?.map((item) => Meal.fromMap(item as Map<String, dynamic>))
          .toList() ?? [],
      snacks: (map['snacks'] as List<dynamic>?)
          ?.map((item) => Meal.fromMap(item as Map<String, dynamic>))
          .toList(),
      originalPreferences: map['originalPreferences'] as String?,
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] as Timestamp).toDate() 
          : null,
      createdBy: map['createdBy'] as String?,
      title: map['title'] as String?,
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() => toMap();
  
  /// Create from JSON
  factory DailyMenu.fromJson(Map<String, dynamic> json) => DailyMenu.fromMap(json);
  
  @override
  List<Object?> get props => [
    breakfast,
    lunch,
    dinner,
    snacks,
    originalPreferences,
    createdAt,
    createdBy,
    title,
  ];
  
  @override
  String toString() {
    return 'DailyMenu(breakfast: ${breakfast.length}, lunch: ${lunch.length}, dinner: ${dinner.length}, snacks: ${snacks?.length ?? 0})';
  }
}

/// Represents days of the week
enum Weekday {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday;
  
  /// Get the display name for this day in Vietnamese
  String get displayName {
    switch (this) {
      case Weekday.monday:
        return 'Thứ Hai';
      case Weekday.tuesday:
        return 'Thứ Ba';
      case Weekday.wednesday:
        return 'Thứ Tư';
      case Weekday.thursday:
        return 'Thứ Năm';
      case Weekday.friday:
        return 'Thứ Sáu';
      case Weekday.saturday:
        return 'Thứ Bảy';
      case Weekday.sunday:
        return 'Chủ Nhật';
    }
  }
  
  /// Get the weekday from a string (case-insensitive)
  static Weekday? fromString(String value) {
    final lowerValue = value.toLowerCase();
    return Weekday.values.firstWhere(
      (day) => day.name.toLowerCase() == lowerValue,
      orElse: () => Weekday.values.firstWhere(
        (day) => day.displayName.toLowerCase() == lowerValue,
        orElse: () => throw ArgumentError('Invalid weekday: $value'),
      ),
    );
  }
}

/// Represents a meal plan for a full week
/// Based on WeeklyMenuSchema from the web app
class WeeklyMenu extends Equatable {
  /// Menu for Monday
  final DailyMenu? monday;
  
  /// Menu for Tuesday
  final DailyMenu? tuesday;
  
  /// Menu for Wednesday
  final DailyMenu? wednesday;
  
  /// Menu for Thursday
  final DailyMenu? thursday;
  
  /// Menu for Friday
  final DailyMenu? friday;
  
  /// Menu for Saturday
  final DailyMenu? saturday;
  
  /// Menu for Sunday
  final DailyMenu? sunday;
  
  /// Original preferences/request that generated this menu
  final String? originalPreferences;
  
  /// Date when this menu was created
  final DateTime? createdAt;
  
  /// User ID who created/owns this menu
  final String? createdBy;
  
  /// Title or name for this menu (optional)
  final String? title;

  /// Constructor
  const WeeklyMenu({
    this.monday,
    this.tuesday,
    this.wednesday,
    this.thursday,
    this.friday,
    this.saturday,
    this.sunday,
    this.originalPreferences,
    this.createdAt,
    this.createdBy,
    this.title,
  });
  
  /// Create an empty weekly menu
  static WeeklyMenu empty() {
    return const WeeklyMenu();
  }
  
  /// Get all daily menus in this weekly menu as a map
  Map<Weekday, DailyMenu?> get dailyMenus {
    return {
      Weekday.monday: monday,
      Weekday.tuesday: tuesday,
      Weekday.wednesday: wednesday,
      Weekday.thursday: thursday,
      Weekday.friday: friday,
      Weekday.saturday: saturday,
      Weekday.sunday: sunday,
    };
  }
  
  /// Get a daily menu for a specific day of the week
  DailyMenu? getDailyMenu(Weekday day) {
    switch (day) {
      case Weekday.monday:
        return monday;
      case Weekday.tuesday:
        return tuesday;
      case Weekday.wednesday:
        return wednesday;
      case Weekday.thursday:
        return thursday;
      case Weekday.friday:
        return friday;
      case Weekday.saturday:
        return saturday;
      case Weekday.sunday:
        return sunday;
    }
  }
  
  /// Set a daily menu for a specific day of the week
  WeeklyMenu updateDailyMenu(Weekday day, DailyMenu menu) {
    switch (day) {
      case Weekday.monday:
        return copyWith(monday: menu);
      case Weekday.tuesday:
        return copyWith(tuesday: menu);
      case Weekday.wednesday:
        return copyWith(wednesday: menu);
      case Weekday.thursday:
        return copyWith(thursday: menu);
      case Weekday.friday:
        return copyWith(friday: menu);
      case Weekday.saturday:
        return copyWith(saturday: menu);
      case Weekday.sunday:
        return copyWith(sunday: menu);
    }
  }
  
  /// Get all meals from all days as a single list
  List<Meal> get allMeals {
    final result = <Meal>[];
    dailyMenus.values.forEach((dailyMenu) {
      if (dailyMenu != null) {
        result.addAll(dailyMenu.allMeals);
      }
    });
    return result;
  }
  
  /// Get all unique ingredients across all meals
  List<String> get allIngredients {
    final result = <String>{};
    dailyMenus.values.forEach((dailyMenu) {
      if (dailyMenu != null) {
        result.addAll(dailyMenu.allIngredients);
      }
    });
    return result.toList();
  }
  
  /// Create a copy of this WeeklyMenu with the given fields replaced
  WeeklyMenu copyWith({
    DailyMenu? monday,
    DailyMenu? tuesday,
    DailyMenu? wednesday,
    DailyMenu? thursday,
    DailyMenu? friday,
    DailyMenu? saturday,
    DailyMenu? sunday,
    String? originalPreferences,
    DateTime? createdAt,
    String? createdBy,
    String? title,
  }) {
    return WeeklyMenu(
      monday: monday ?? this.monday,
      tuesday: tuesday ?? this.tuesday,
      wednesday: wednesday ?? this.wednesday,
      thursday: thursday ?? this.thursday,
      friday: friday ?? this.friday,
      saturday: saturday ?? this.saturday,
      sunday: sunday ?? this.sunday,
      originalPreferences: originalPreferences ?? this.originalPreferences,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      title: title ?? this.title,
    );
  }
  
  /// Convert the WeeklyMenu to a Map
  Map<String, dynamic> toMap() {
    return {
      'monday': monday?.toMap(),
      'tuesday': tuesday?.toMap(),
      'wednesday': wednesday?.toMap(),
      'thursday': thursday?.toMap(),
      'friday': friday?.toMap(),
      'saturday': saturday?.toMap(),
      'sunday': sunday?.toMap(),
      'originalPreferences': originalPreferences,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'createdBy': createdBy,
      'title': title,
    };
  }
  
  /// Create a WeeklyMenu from a map
  factory WeeklyMenu.fromMap(Map<String, dynamic> map) {
    return WeeklyMenu(
      monday: map['monday'] != null 
          ? DailyMenu.fromMap(map['monday'] as Map<String, dynamic>) 
          : null,
      tuesday: map['tuesday'] != null 
          ? DailyMenu.fromMap(map['tuesday'] as Map<String, dynamic>) 
          : null,
      wednesday: map['wednesday'] != null 
          ? DailyMenu.fromMap(map['wednesday'] as Map<String, dynamic>) 
          : null,
      thursday: map['thursday'] != null 
          ? DailyMenu.fromMap(map['thursday'] as Map<String, dynamic>) 
          : null,
      friday: map['friday'] != null 
          ? DailyMenu.fromMap(map['friday'] as Map<String, dynamic>) 
          : null,
      saturday: map['saturday'] != null 
          ? DailyMenu.fromMap(map['saturday'] as Map<String, dynamic>) 
          : null,
      sunday: map['sunday'] != null 
          ? DailyMenu.fromMap(map['sunday'] as Map<String, dynamic>) 
          : null,
      originalPreferences: map['originalPreferences'] as String?,
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] as Timestamp).toDate() 
          : null,
      createdBy: map['createdBy'] as String?,
      title: map['title'] as String?,
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() => toMap();
  
  /// Create from JSON
  factory WeeklyMenu.fromJson(Map<String, dynamic> json) => WeeklyMenu.fromMap(json);
  
  @override
  List<Object?> get props => [
    monday,
    tuesday,
    wednesday,
    thursday,
    friday,
    saturday,
    sunday,
    originalPreferences,
    createdAt,
    createdBy,
    title,
  ];
  
  @override
  String toString() {
    int daysCount = dailyMenus.values.where((menu) => menu != null).length;
    return 'WeeklyMenu(days: $daysCount${title != null ? ', title: $title' : ''})';
  }
}

/// Represents a generated menu, which can be either daily or weekly
/// Based on AnyMenuSchema from the web app
class GeneratedMenu extends Equatable {
  /// The type of menu (daily or weekly)
  final MenuType type;
  
  /// The daily menu (if type is daily)
  final DailyMenu? dailyMenu;
  
  /// The weekly menu (if type is weekly)
  final WeeklyMenu? weeklyMenu;
  
  /// Original preferences/request that generated this menu
  final String? originalPreferences;
  
  /// Feedback request generated by AI
  final String? feedbackRequest;
  
  /// Date when this menu was created
  final DateTime? createdAt;
  
  /// User ID who created/owns this menu
  final String? createdBy;
  
  /// Title or name for this menu (optional)
  final String? title;
  
  /// Constructor
  const GeneratedMenu({
    required this.type,
    this.dailyMenu,
    this.weeklyMenu,
    this.originalPreferences,
    this.feedbackRequest,
    this.createdAt,
    this.createdBy,
    this.title,
  }) : assert(
    (type == MenuType.daily && dailyMenu != null && weeklyMenu == null) || 
    (type == MenuType.weekly && weeklyMenu != null && dailyMenu == null),
    'Either dailyMenu or weeklyMenu must be provided, but not both',
  );
  
  /// Create a daily GeneratedMenu
  factory GeneratedMenu.daily({
    required DailyMenu menu,
    String? originalPreferences,
    String? feedbackRequest,
    DateTime? createdAt,
    String? createdBy,
    String? title,
  }) {
    return GeneratedMenu(
      type: MenuType.daily,
      dailyMenu: menu,
      originalPreferences: originalPreferences,
      feedbackRequest: feedbackRequest,
      createdAt: createdAt,
      createdBy: createdBy,
      title: title,
    );
  }
  
  /// Create a weekly GeneratedMenu
  factory GeneratedMenu.weekly({
    required WeeklyMenu menu,
    String? originalPreferences,
    String? feedbackRequest,
    DateTime? createdAt,
    String? createdBy,
    String? title,
  }) {
    return GeneratedMenu(
      type: MenuType.weekly,
      weeklyMenu: menu,
      originalPreferences: originalPreferences,
      feedbackRequest: feedbackRequest,
      createdAt: createdAt,
      createdBy: createdBy,
      title: title,
    );
  }
  
  /// Create an empty GeneratedMenu of the given type
  static GeneratedMenu empty(MenuType type) {
    return type == MenuType.daily
        ? GeneratedMenu.daily(menu: DailyMenu.empty())
        : GeneratedMenu.weekly(menu: WeeklyMenu.empty());
  }
  
  /// Get all meals in this generated menu as a single list
  List<Meal> get allMeals {
    if (type == MenuType.daily && dailyMenu != null) {
      return dailyMenu!.allMeals;
    } else if (type == MenuType.weekly && weeklyMenu != null) {
      return weeklyMenu!.allMeals;
    }
    return [];
  }
  
  /// Get all unique ingredients across all meals
  List<String> get allIngredients {
    if (type == MenuType.daily && dailyMenu != null) {
      return dailyMenu!.allIngredients;
    } else if (type == MenuType.weekly && weeklyMenu != null) {
      return weeklyMenu!.allIngredients;
    }
    return [];
  }
  
  /// Create a copy of this GeneratedMenu with the given fields replaced
  GeneratedMenu copyWith({
    MenuType? type,
    DailyMenu? dailyMenu,
    WeeklyMenu? weeklyMenu,
    String? originalPreferences,
    String? feedbackRequest,
    DateTime? createdAt,
    String? createdBy,
    String? title,
  }) {
    return GeneratedMenu(
      type: type ?? this.type,
      dailyMenu: type == MenuType.weekly ? null : (dailyMenu ?? this.dailyMenu),
      weeklyMenu: type == MenuType.daily ? null : (weeklyMenu ?? this.weeklyMenu),
      originalPreferences: originalPreferences ?? this.originalPreferences,
      feedbackRequest: feedbackRequest ?? this.feedbackRequest,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      title: title ?? this.title,
    );
  }
  
  /// Convert the GeneratedMenu to a Map
  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'dailyMenu': type == MenuType.daily ? dailyMenu?.toMap() : null,
      'weeklyMenu': type == MenuType.weekly ? weeklyMenu?.toMap() : null,
      'originalPreferences': originalPreferences,
      'feedbackRequest': feedbackRequest,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'createdBy': createdBy,
      'title': title,
    };
  }
  
  /// Create a GeneratedMenu from a map
  factory GeneratedMenu.fromMap(Map<String, dynamic> map) {
    final typeStr = map['type'] as String;
    final type = MenuType.values.firstWhere(
      (t) => t.name == typeStr,
      orElse: () => throw ArgumentError('Invalid menu type: $typeStr'),
    );
    
    return GeneratedMenu(
      type: type,
      dailyMenu: type == MenuType.daily && map['dailyMenu'] != null
          ? DailyMenu.fromMap(map['dailyMenu'] as Map<String, dynamic>)
          : null,
      weeklyMenu: type == MenuType.weekly && map['weeklyMenu'] != null
          ? WeeklyMenu.fromMap(map['weeklyMenu'] as Map<String, dynamic>)
          : null,
      originalPreferences: map['originalPreferences'] as String?,
      feedbackRequest: map['feedbackRequest'] as String?,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      createdBy: map['createdBy'] as String?,
      title: map['title'] as String?,
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() => toMap();
  
  /// Create from JSON
  factory GeneratedMenu.fromJson(Map<String, dynamic> json) => GeneratedMenu.fromMap(json);
  
  @override
  List<Object?> get props => [
    type,
    dailyMenu,
    weeklyMenu,
    originalPreferences,
    feedbackRequest,
    createdAt,
    createdBy,
    title,
  ];
  
  @override
  String toString() {
    return 'GeneratedMenu(type: ${type.name}, ${title != null ? 'title: $title' : ''})';
  }
}

/// Represents the type of menu
enum MenuType {
  daily,
  weekly;
  
  /// Get the display name in Vietnamese
  String get displayName {
    switch (this) {
      case MenuType.daily:
        return 'Thực đơn hàng ngày';
      case MenuType.weekly:
        return 'Thực đơn hàng tuần';
    }
  }
}